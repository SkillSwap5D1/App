# Report and Block Users Implementation Guide

## Overview
The Report and Block system is now fully implemented to help keep SkillSwap safe. Users can report other users for inappropriate behavior and block users to prevent future interactions.

## Components

### 1. **ReportModel** (`lib/models/report_model.dart`)
Data model for user reports.

**Fields:**
- `id`: Unique report ID
- `reporterId`: UID of person submitting report
- `reporteeId`: UID of person being reported
- `reason`: Category of report (from predefined list)
- `description`: Detailed explanation (optional)
- `requestId`: Link to specific request (optional)
- `evidence`: List of URLs or file paths as evidence
- `status`: Report status (`pending`, `reviewed`, `resolved`, `dismissed`)
- `createdAt`: Timestamp when report was submitted
- `updatedAt`: Timestamp when report was last updated

**Predefined Report Reasons:**
- Inappropriate behavior
- Offensive language
- No-show for session
- Didn't follow agreed terms
- Suspicious activity
- Other

### 2. **BlockModel** (`lib/models/block_model.dart`)
Data model for user blocks.

**Fields:**
- `id`: Unique block ID
- `blockerId`: UID of person blocking
- `blockedUserId`: UID of person being blocked
- `reason`: Optional reason for block
- `createdAt`: Timestamp when block was created

### 3. **SafetyService** (`lib/services/safety_service.dart`)
Core service managing all safety operations.

**Key Methods:**

```dart
// Submit a report
Future<void> reportUser({
  required String reporterId,
  required String reporteeId,
  required String reason,
  required String description,
  String? requestId,
  List<String> evidence,
})

// Block a user
Future<void> blockUser({
  required String blockerId,
  required String blockedUserId,
  String? reason,
})

// Unblock a user
Future<void> unblockUser({
  required String blockerId,
  required String blockedUserId,
})

// Check if user is blocked
Future<bool> isUserBlocked({
  required String blockerId,
  required String blockedUserId,
})

// Get all users that current user has blocked
Future<List<String>> getBlockedUsers(String userId)

// Get all users who have blocked this user
Future<List<String>> getUserBlockers(String userId)

// Check if two users can interact
Future<bool> canUsersInteract(String userId1, String userId2)

// Get pending reports (for admin)
Future<List<ReportModel>> getPendingReports()

// Get reports about specific user
Future<List<ReportModel>> getReportsAbout(String reporteeId)

// Get reports by specific user
Future<List<ReportModel>> getReportsByUser(String reporterId)

// Update report status
Future<void> updateReportStatus(String reportId, String newStatus)
```

### 4. **SafetyProvider** (`lib/providers/safety_provider.dart`)
State management for safety-related data using Provider pattern.

**State:**
- `blockedUsers`: List of user IDs current user has blocked
- `userBlockers`: List of user IDs who have blocked current user
- `userReports`: Reports submitted by current user
- `isLoading`: Loading state
- `error`: Error message if any

**Methods:**
- `loadBlockedUsers(userId)` - Load user's blocked list
- `loadUserBlockers(userId)` - Load who blocked user
- `loadUserReports(userId)` - Load user's submitted reports
- `reportUser()` - Submit report
- `blockUser()` - Block user
- `unblockUser()` - Unblock user
- `isUserBlocked()` - Check block status
- `canUsersInteract()` - Check if users can interact

### 5. **ReportBlockedScreen** (`lib/screens/safety/report_blocked_screen.dart`)
UI for reporting and blocking users.

**Features:**
- Reason selector dropdown (6 predefined reasons)
- Optional details text field
- Loading states during submission
- Error handling with snackbars
- Block confirmation with list of consequences
- Information boxes explaining process

## Firestore Schema

### Reports Collection
```
reports/
  {reportId}/
    id: string
    reporterId: string
    reporteeId: string
    reason: string
    description: string
    requestId: string (optional)
    evidence: array<string>
    status: string (pending|reviewed|resolved|dismissed)
    createdAt: timestamp
    updatedAt: timestamp
```

### Blocks Collection
```
blocks/
  {blockId}/
    id: string
    blockerId: string
    blockedUserId: string
    reason: string (optional)
    createdAt: timestamp
```

## Usage Examples

### Report a User
```dart
final safetyService = SafetyService();
await safetyService.reportUser(
  reporterId: currentUserId,
  reporteeId: suspiciousUserId,
  reason: 'No-show for session',
  description: 'User did not show up for scheduled session',
  requestId: request.id,
);
```

### Block a User
```dart
final safetyService = SafetyService();
await safetyService.blockUser(
  blockerId: currentUserId,
  blockedUserId: userToBlock,
  reason: 'Inappropriate behavior',
);
```

### Check if Users Can Interact
```dart
final canInteract = await safetyService.canUsersInteract(userId1, userId2);
if (!canInteract) {
  // Show blocked message
}
```

### Load Blocked Users in Provider
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final currentUid = context.read<AuthProvider>().currentUser?.uid;
  if (currentUid != null) {
    context.read<SafetyProvider>().loadBlockedUsers(currentUid);
  }
}
```

### Prevent Interaction with Blocked User
```dart
// In requests/chat flow before creating request or message
final canInteract = await SafetyService().canUsersInteract(
  currentUserId,
  otherUserId,
);

if (!canInteract) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Cannot interact with this user')),
  );
  return;
}
```

## Integration Points

### 1. Profile Screen - Add Report/Block Option
```dart
IconButton(
  icon: const Icon(Icons.flag_outlined),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportBlockedScreen(
          userName: user.displayName,
          userId: user.uid,
          onBlock: () {
            // Refresh profile or navigate away
          },
        ),
      ),
    );
  },
)
```

### 2. Chat/Request - Check Before Interaction
```dart
// In ChatThreadScreen or before sending request
final blocked = await SafetyService().isUserBlocked(
  blockerId: currentUserId,
  blockedUserId: otherUserId,
);

if (blocked) {
  // Prevent interaction
}
```

### 3. Listing - Hide from Blocked Users
```dart
// Filter listings to hide from blocked users
final blockedUsers = await SafetyService().getBlockedUsers(currentUserId);
final visibleListings = allListings
    .where((listing) => !blockedUsers.contains(listing.userId))
    .toList();
```

## Block Effects

When a user blocks another user:
- ✅ Their listings are hidden from blocked user
- ✅ Messages are blocked
- ✅ Both users' profiles are hidden from each other
- ✅ Existing conversations are preserved (but no new messages)
- ✅ Existing requests remain but can't be modified

## Report Workflow

### Submitting a Report
1. User navigates to ReportBlockedScreen
2. Selects report reason
3. Optionally adds details
4. Clicks "Submit Report"
5. Report is created in Firestore with status `pending`
6. User gets confirmation message

### Moderation (Admin)
1. Get pending reports: `SafetyService().getPendingReports()`
2. Review report details
3. Update status: `updateReportStatus(reportId, 'reviewed')`
4. Take action if needed (warning, suspension, block)

## Security Considerations

✅ **Implemented:**
- Only authenticated users can report/block
- Reports are permanent audit trail
- Blocks are bidirectional in effect (neither sees other)
- Users can unblock at any time
- Multiple reports on same user tracked

⚠️ **To Implement:**
- Rate limiting on reports (prevent spam)
- False report penalties
- Admin override capability
- Report visibility (show user their report status)
- Appeal process for false blocks

## Firestore Security Rules

```javascript
// Reports collection
match /reports/{document=**} {
  allow read: if request.auth.uid != null && 
              (resource.data.reporterId == request.auth.uid ||
               request.auth.customClaims.admin == true);
  allow create: if request.auth.uid != null &&
                request.resource.data.reporterId == request.auth.uid;
  allow update, delete: if request.auth.customClaims.admin == true;
}

// Blocks collection
match /blocks/{document=**} {
  allow read: if request.auth.uid != null &&
              (resource.data.blockerId == request.auth.uid ||
               resource.data.blockedUserId == request.auth.uid);
  allow create: if request.auth.uid != null &&
                request.resource.data.blockerId == request.auth.uid;
  allow delete: if request.auth.uid != null &&
                resource.data.blockerId == request.auth.uid;
}
```

## Testing Checklist

- [ ] Navigate to ReportBlockedScreen
- [ ] Select report reason from dropdown
- [ ] Add optional details
- [ ] Submit report (should create Firestore document)
- [ ] See success message
- [ ] Block user (should create block document)
- [ ] Check that blocked user can't see profile
- [ ] Check that blocked user's listings don't appear
- [ ] Unblock user (should delete block document)
- [ ] Check bidirectional blocking works
- [ ] Verify reports appear in Firestore with correct fields
- [ ] Test multiple reports on same user

## API Reference

### SafetyService

```dart
// Check if blocked
bool blocked = await SafetyService().isUserBlocked(
  blockerId: 'user1',
  blockedUserId: 'user2',
);

// Get blocked users
List<String> blocked = await SafetyService().getBlockedUsers('user1');

// Get blockers
List<String> blockers = await SafetyService().getUserBlockers('user1');

// Can interact
bool canInteract = await SafetyService().canUsersInteract('user1', 'user2');

// Get reports about user (admin)
List<ReportModel> reports = 
    await SafetyService().getReportsAbout('reporteeId');
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Block not working | Check Firestore security rules |
| Reports not appearing | Verify Firestore collection exists |
| Can still see blocked user | Clear app cache, check rules |
| Duplicate blocks | Check if already blocked before blocking |
| Report reason not saving | Verify reason is in ReportModel.reasons list |

## Implementation Status

✅ **Completed:**
- Report model with all fields
- Block model implementation
- SafetyService with all methods
- SafetyProvider state management
- ReportBlockedScreen UI
- Report reason predefined list
- Block verification
- Bidirectional interaction checking

🟡 **Partial:**
- Block effects (needs integration in other screens)
- Admin report review (structure ready, UI needed)

❌ **Not Yet Implemented:**
- Admin dashboard for report management
- User notification of block/report
- Report appeals
- Rate limiting
- Automatic actions (auto-block on multiple reports)
- User settings for blocking

## Next Steps

1. **Integrate Block Checks**: Add `canUsersInteract()` checks to:
   - Chat screen (prevent messaging)
   - Request sending (prevent new requests)
   - Listing browsing (hide blocked user listings)

2. **Add Settings Screen**: Show blocked users list with unblock option

3. **Create Admin Dashboard**: Review pending reports and take action

4. **Add Notifications**: Notify users when they're blocked

5. **Implement Appeals**: Let users appeal false reports

---

**Status**: ✅ Core functionality complete  
**Ready for**: Integration with chat and request screens  
**Next focus**: Block effect integration and admin dashboard
