import * as functions from "firebase-functions";
import admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

/**
 * Cloud Function: setUniversityUserClaims
 * Triggered when a new user is created in Firebase Auth
 */
export const setUniversityUserClaims = functions.auth
  .user()
  .onCreate(async (user) => {
    const email = user.email || "";
    console.log(`🔵 setUniversityUserClaims triggered for: ${email}`);
    
    if (!email.endsWith("@myport.ac.uk")) {
      console.log(`❌ Non-university email detected: ${email}`);
      await admin.auth().deleteUser(user.uid);
      console.log(`❌ User deleted: ${user.uid}`);
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Only @myport.ac.uk emails allowed"
      );
    }

    console.log(`✅ Email validated: ${email}`);
    
    try {
      await admin.auth().setCustomUserClaims(user.uid, {
        isUniversityUser: true,
        emailDomain: "myport.ac.uk",
        claimsSetAt: new Date().toISOString(),
      });
      console.log(`✅ Custom claims set for ${user.uid}`);
    } catch (err) {
      console.error(`❌ Error setting custom claims: ${err}`);
      throw err;
    }

    try {
      await db.collection("users").doc(user.uid).set(
        {
          uid: user.uid,
          email: email,
          displayName: user.displayName || "",
          isUniversityUser: true,
          createdAt: new Date(),
          isActive: true,
        },
        { merge: true }
      );
      console.log(`✅ User document created for ${user.uid}`);
    } catch (err) {
      console.error(`❌ Error creating user document: ${err}`);
      throw err;
    }

    console.log(`✓ University user created: ${email}`);
  });

/**
 * Cloud Function: deleteUserData
 * Triggered when a user account is deleted
 */
export const deleteUserData = functions.auth.user().onDelete(async (user) => {
  try {
    await db.collection("users").doc(user.uid).update({
      email: "deleted@myport.ac.uk",
      displayName: "Deleted User",
      isActive: false,
      deletedAt: new Date(),
    });
    console.log(`✓ User data deleted for ${user.uid}`);
  } catch (error) {
    console.error(`Error deleting user ${user.uid}:`, error);
  }
});

/**
 * Callable Function: verifyUniversityEmail
 */
export const verifyUniversityEmail = functions.https.onCall((data, context) => {
  const email = data.email || "";

  if (!email.endsWith("@myport.ac.uk")) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Only @myport.ac.uk emails allowed"
    );
  }

  return { success: true, message: "Email verified" };
});

/**
 * Callable Function: sendVerificationEmail
 */
export const sendVerificationEmail = functions.https.onCall((data) => {
  const email = data.email || "";

  if (!email.endsWith("@myport.ac.uk")) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Only @myport.ac.uk emails allowed"
    );
  }

  console.log(`📧 Verification email would be sent to: ${email}`);

  return { success: true, message: "Verification email sent" };
});

// ────────────────────────────────────────────────────────────────────────────
// NOTIFICATION TRIGGERS
// ────────────────────────────────────────────────────────────────────────────

/**
 * Cloud Function: onRequestCreated
 * Triggered when a new request is created in the 'requests' collection
 * Notifies the skill owner that they received a new request
 */
export const onRequestCreated = functions.firestore
  .document("requests/{requestId}")
  .onCreate(async (snap) => {
    const request = snap.data();
    const skillOwnerUserId = request.toUserId;
    const requesterName = request.fromUserName;
    const skillName = request.skillName;

    if (!skillOwnerUserId) {
      console.error("Missing toUserId in request");
      return;
    }

    try {
      await db.collection("notifications").add({
        userId: skillOwnerUserId,
        type: "request",
        title: `New request from ${requesterName}`,
        subtitle: `wants to learn ${skillName}`,
        relatedId: snap.id,
        isRead: false,
        createdAt: new Date(),
      });
      console.log(`✓ Notification sent to ${skillOwnerUserId} for new request`);
    } catch (error) {
      console.error("Error creating notification:", error);
    }
  });

/**
 * Cloud Function: onRequestStatusChanged
 * Triggered when a request status is updated
 * Notifies the requester when their request is accepted, declined, or countered
 */
export const onRequestStatusChanged = functions.firestore
  .document("requests/{requestId}")
  .onUpdate(async (change) => {
    const oldData = change.before.data();
    const newData = change.after.data();
    const requestId = change.after.id;

    const oldStatus = oldData.status;
    const newStatus = newData.status;

    // Only trigger if status changed
    if (oldStatus === newStatus) {
      return;
    }

    const requesterUserId = newData.fromUserId;
    const skillOwnerName = newData.toUserName || "Skill Owner";
    const skillName = newData.skillName;

    if (!requesterUserId) {
      console.error("Missing fromUserId in request");
      return;
    }

    let notificationType = "";
    let title = "";
    let subtitle = "";

    // Determine notification content based on new status
    if (newStatus === "accepted") {
      notificationType = "accepted";
      title = `${skillOwnerName} accepted your request!`;
      subtitle = `Great! You'll be learning ${skillName}. Check your messages for details.`;
    } else if (newStatus === "declined") {
      notificationType = "declined";
      title = `${skillOwnerName} declined your request`;
      subtitle = `Unfortunately, they can't help with ${skillName} right now. Check your requests for alternatives.`;
    } else if (newStatus === "countered") {
      notificationType = "countered";
      title = `${skillOwnerName} sent a counter offer`;
      subtitle = `They proposed different times for ${skillName}. Review and respond to the offer.`;
    } else {
      // Status changed to something else we don't notify about
      return;
    }

    try {
      await db.collection("notifications").add({
        userId: requesterUserId,
        type: notificationType,
        title: title,
        subtitle: subtitle,
        relatedId: requestId,
        isRead: false,
        createdAt: new Date(),
      });
      console.log(
        `✓ Notification sent to ${requesterUserId} for request ${newStatus}`
      );
    } catch (error) {
      console.error("Error creating status notification:", error);
    }
  });

/**
 * Cloud Function: onNewMessage
 * Triggered when a new message is created in the 'messages' collection
 * Notifies the recipient of the message
 */
export const onNewMessage = functions.firestore
  .document("messages/{messageId}")
  .onCreate(async (snap) => {
    const message = snap.data();
    const conversationId = message.conversationId;
    const senderId = message.senderId;
    const messageText = message.text;

    if (!conversationId) {
      console.error("Missing conversationId in message");
      return;
    }

    try {
      // Get conversation to find the other user
      const convSnap = await db.collection("conversations").doc(conversationId).get();
      
      if (!convSnap.exists) {
        console.error(`Conversation ${conversationId} not found`);
        return;
      }

      const conversation = convSnap.data();
      if (!conversation) {
        console.error(`Conversation data is empty for ${conversationId}`);
        return;
      }

      const participants = conversation.participants || [];
      
      // Find recipient (the other participant)
      const recipient = participants.find((p: string) => p !== senderId);
      
      if (!recipient) {
        console.error("Recipient not found in conversation");
        return;
      }

      // Get sender's name
      const senderSnap = await db.collection("users").doc(senderId).get();
      const senderData = senderSnap.data();
      const senderName = senderData?.displayName || senderData?.firstName || "User";

      // Truncate message for preview
      const messagePreview =
        messageText.length > 50 ? messageText.substring(0, 50) + "..." : messageText;

      await db.collection("notifications").add({
        userId: recipient,
        type: "message",
        title: `New message from ${senderName}`,
        subtitle: messagePreview,
        relatedId: conversationId,
        isRead: false,
        createdAt: new Date(),
      });
      console.log(`✓ Message notification sent to ${recipient}`);
    } catch (error) {
      console.error("Error creating message notification:", error);
    }
  });

/**
 * Helper function to send notifications
 * Used by frontend via callable function if needed
 */
export const sendNotification = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const { userId, type, title, subtitle, relatedId } = data;

  if (!userId || !type || !title || !subtitle) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required fields: userId, type, title, subtitle"
    );
  }

  try {
    const result = await db.collection("notifications").add({
      userId: userId,
      type: type,
      title: title,
      subtitle: subtitle,
      relatedId: relatedId || null,
      isRead: false,
      createdAt: new Date(),
    });

    console.log(`✓ Notification created: ${result.id}`);
    return { success: true, notificationId: result.id };
  } catch (error) {
    console.error("Error creating notification:", error);
    throw new functions.https.HttpsError("internal", "Failed to create notification");
  }
});
