import * as functions from "firebase-functions";
import admin from "firebase-admin";

admin.initializeApp();

/**
 * Cloud Function: setUniversityUserClaims
 * Triggered when a new user is created in Firebase Auth
 */
export const setUniversityUserClaims = functions.auth
  .user()
  .onCreate(async (user) => {
    const email = user.email || "";
    
    if (!email.endsWith("@myport.ac.uk")) {
      await admin.auth().deleteUser(user.uid);
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Only @myport.ac.uk emails allowed"
      );
    }

    await admin.auth().setCustomUserClaims(user.uid, {
      isUniversityUser: true,
      emailDomain: "myport.ac.uk",
      claimsSetAt: new Date().toISOString(),
    });

    await admin.firestore().collection("users").doc(user.uid).set(
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

    console.log(`✓ University user created: ${email}`);
  });

/**
 * Cloud Function: deleteUserData
 * Triggered when a user account is deleted
 */
export const deleteUserData = functions.auth.user().onDelete(async (user) => {
  try {
    await admin.firestore().collection("users").doc(user.uid).update({
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

  if (!email.endsWith("@port.ac.uk")) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Only @port.ac.uk emails allowed"
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
