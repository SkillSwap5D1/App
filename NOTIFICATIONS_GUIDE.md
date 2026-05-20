# Notifications System Implementation Guide

## Overview
The notifications system has been fully implemented to send real-time updates to users for requests, messages, reviews, and more. The system uses Firebase Cloud Messaging (FCM) for push notifications and Firestore for local notification storage.

## Components

### 1. **NotificationModel** (`lib/models/notification_model.dart`)
Data model for in-app notifications.

**Fields:**
- `id`: Unique notification ID
- `userId`: Recipient user ID
- `type`: Notification type (see below)
- `title`: Display title
- `subtitle`: Display subtitle/body
- `isRead`: Read status
- `createdAt`: Timestamp

**Supported Types:**
- `new_request` - New skill request received
- `request_accepted` - Request was accepted
- `request_declined` - Request was declined
- `request_completed` - Session was completed
- `countered` - Counter offer received
- `new_message` - New message in chat
- `review_submitted` - User submitted a review (pending)
- `review_published` - Reviews are now published

### 2. **NotificationService** (`lib/services/notification_service.dart`)
Manages all notification operations with Firebase.

**Key Methods:**
```dart
// Send notification to user
Future<void> sendNotification(
  String userId,
  String type,
  String title,
  String body,
  String relatedId,
)

// Get real-time stream of notifications
Stream<List<NotificationModel>> getNotifications(String userId)

// Get unread count stream
Stream<int> getUnreadCount(String userId)

// Mark single notification as read
Future<void> markRead(String notificationId)

// Mark all notifications as read
Future<void> markAllRead(String userId)

// Get device token for FCM
Future<String?> getDeviceToken()

// Subscribe/unsubscribe from topics
Future<void> subscribeToTopic(String topic)
Future<void> unsubscribeFromTopic(String topic)
```

**Initialization:**
```dart
final notificationService = NotificationService();
await notificationService.initialize();
```

### 3. **NotificationProvider** (`lib/providers/notification_provider.dart`)
State management for notifications using Provider pattern.

**State:**
- `notifications`: List of user's notifications
- `unreadCount`: Count of unread notifications
- `isLoading`: Loading state

**Methods:**
- `loadNotifications(userId)` - Load user's notifications
- `markAllAsRead(userId)` - Mark all as read
- `markOneAsRead(notificationId)` - Mark one as read
- `dispose()` - Cleanup

### 4. **NotificationsScreen** (`lib/screens/notifications/notifications_screen.dart`)
UI for displaying notifications.

**Features:**
- Real-time notification list
- Mark as read functionality
- Navigation to related screens based on notification type
- "Mark all as read" button

## Notification Triggers

### Request Events
**Location:** `lib/services/request_service.dart`

1. **New Request Sent** (`sendRequest()`)
   - Type: `new_request`
   - Sent to: Request recipient
   - Message: "New request from [requester]"

2. **Request Accepted** (`acceptRequest()`)
   - Type: `request_accepted`
   - Sent to: Request sender
   - Message: "Your request was accepted!"

3. **Request Declined** (`declineRequest()`)
   - Type: `request_declined`
   - Sent to: Request sender
   - Message: "Your request was declined"

4. **Request Completed** (`endRequest()`)
   - Type: `request_completed`
   - Sent to: Other participant
   - Message: "Request ended"

5. **Counter Offer** (`counterRequest()`)
   - Type: `countered`
   - Sent to: Request sender
   - Message: "Counter offer received"

### Message Events
**Location:** `lib/services/chat_service.dart`

**New Message** (`sendMessage()`)
- Type: `new_message`
- Sent to: Other conversation participant
- Message: "New message from [sender]"
- Body: Message preview (truncated to 50 chars)

### Review Events
**Location:** `lib/services/review_service.dart`

1. **Review Submitted** (`submitReview()`)
   - Type: `review_submitted`
   - Sent to: User being reviewed
   - Message: "[Reviewer] submitted a review"
   - Timing: Immediately when review is submitted

2. **Reviews Published** (`submitReview()` - when both users reviewed)
   - Type: `review_published`
   - Sent to: Both users
   - Message: "Your review was published!"
   - Timing: When second user submits their review

## Firebase Firestore Schema

### Notifications Collection
```
notifications/
  {notificationId}/
    id: string
    userId: string
    type: string
    title: string
    subtitle: string
    relatedId: string (request/message/review ID)
    isRead: boolean
    createdAt: timestamp
```

## Usage Examples

### Integrate NotificationProvider into App
```dart
// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
    // ... other providers
  ],
  child: MyApp(),
)
```

### Initialize Notifications on App Start
```dart
// In main or app initialization
void initializeNotifications() async {
  final notificationService = NotificationService();
  await notificationService.initialize();
}
```

### Listen to Notifications in UI
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final currentUid = context.read<AuthProvider>().currentUser?.uid;
  if (currentUid != null) {
    context.read<NotificationProvider>().loadNotifications(currentUid);
  }
}
```

### Display Unread Count Badge
```dart
Consumer<NotificationProvider>(
  builder: (context, notifProvider, child) {
    if (notifProvider.unreadCount == 0) {
      return child!;
    }
    return Badge(
      label: Text(notifProvider.unreadCount.toString()),
      child: const Icon(Icons.notifications),
    );
  },
  child: const Icon(Icons.notifications),
)
```

## Notification Flow Diagrams

### Request Notification Flow
```
User A sends request → Notification written to Firestore
                    → NotificationProvider stream updates
                    → NotificationsScreen shows new item
                    → Badge count updates
                    → User B sees badge
                    → User B taps → navigates to requests
```

### Chat Notification Flow
```
User A sends message → Message written to Firestore
                    → Notification written to Firestore
                    → NotificationProvider stream updates
                    → User B gets real-time update
                    → Badge shows unread count
```

### Review Notification Flow
```
User A submits review → "review_submitted" notification sent to User B
                      → Wait for User B's review
                      → User B submits review
                      → Both reviews published
                      → "review_published" sent to both
                      → Ratings recalculated
                      → Profile updated
```

## Testing

### Manual Testing Checklist
- [ ] New request notification appears on recipient
- [ ] "Mark as read" button works
- [ ] "Mark all as read" updates all notifications
- [ ] Navigation to requests works from notification tap
- [ ] Chat notification appears when message sent
- [ ] Unread count badge displays correctly
- [ ] Review notification shows when review submitted
- [ ] Review published notification shows after mutual review
- [ ] Notifications persist in Firestore
- [ ] Notifications disappear when marked as read

### Testing Push Notifications
1. Install Firebase Messaging on test device
2. Get device token: `await NotificationService().getDeviceToken()`
3. Use Firebase Console to send test notification
4. Verify notification appears in foreground/background

## Firebase Security Rules

```javascript
match /notifications/{document=**} {
  allow read: if request.auth.uid == resource.data.userId;
  allow create: if request.auth.uid != null;
  allow update: if request.auth.uid == resource.data.userId && 
                   request.resource.data.userId == resource.data.userId;
  allow delete: if request.auth.uid == resource.data.userId;
}
```

## Advanced Features

### Topic Subscriptions (Future)
```dart
// Subscribe user to topic when they join
await notificationService.subscribeToTopic('all_users');
await notificationService.subscribeToTopic('skill_${skill}_learners');

// Send to topic
// This would require Cloud Functions or FCM API
```

### Scheduled Notifications (Future)
```dart
// Remind users about pending reviews after 2 days
// Implement with Cloud Functions and Cloud Scheduler
```

### Rich Notifications (Future)
```dart
// Add images, actions, custom sounds
// Requires flutter_local_notifications enhancement
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Notifications not appearing | Check Firestore security rules |
| Unread count not updating | Ensure stream subscription is active |
| Notifications not persisting | Verify Firestore collection exists |
| Navigation not working | Check AppRoutes match notification types |
| FCM token not received | Check device has Play Services installed |

## Implementation Status

✅ **Completed:**
- Notification data model
- Firestore integration
- Real-time stream setup
- Mark as read functionality
- Request notifications (new, accepted, declined, completed, countered)
- Message notifications
- Review notifications
- NotificationsScreen UI
- NotificationProvider state management

🟡 **Partial:**
- Foreground notification handling (logged but not visually shown)
- Background notification tap handling (structure ready, navigation pending)

❌ **Not Yet Implemented:**
- Local push notification display
- Deep linking on notification tap
- FCM topic-based notifications
- Scheduled notifications
- Rich notification formatting

## Next Steps

1. **Add Local Notification Display**: Use `flutter_local_notifications` to show in-app notifications
2. **Implement Deep Linking**: Navigate to correct screen when notification is tapped
3. **Add Notification Preferences**: Let users control notification types
4. **Create Notification History**: Optionally archive old notifications
5. **Add Notification Actions**: Quick actions like "Approve" from notification

---

**Status**: ✅ Core notifications system complete  
**Ready for**: Integration testing with real user flows  
**Next focus**: Local notification display and deep linking
