# Rate and Review Implementation Guide

## Overview
The Rate and Review system has been fully implemented in the SkillSwap app. Users can now rate and review their peers after completing sessions, with automatic mutual review publishing and rating calculations.

## Components Implemented

### 1. **RateReviewScreen** (`lib/screens/reviews/rate_review_screen.dart`)
The main UI for submitting reviews after a session.

**Required Parameters:**
```dart
RateReviewScreen(
  requestId: String,           // The request/session ID
  skillTitle: String,          // The skill being reviewed
  otherUserId: String,         // UID of person being reviewed
  otherUserName: String,       // Display name of other user
  sessionDate: String,         // Formatted date of session
)
```

**Features:**
- Star rating selector (1-5 stars)
- Optional review text field
- Loading state during submission
- Error handling with snackbar feedback
- Success dialog with next steps

### 2. **ReviewTile Widget** (`lib/widgets/review_tile.dart`)
Displays individual reviews on user profiles.

**Shows:**
- Reviewer avatar with initials
- Reviewer name and relative date ("2d ago", "Today")
- 5-star rating visual
- Review text (truncated to 4 lines)
- Professional styling with borders and shadows

### 3. **ProfileScreen Reviews Section** (`lib/screens/profile/profile_screen.dart`)
New "Reviews" section added to profile display.

**Features:**
- Review count in section header
- Loading spinner while fetching
- Error handling with friendly messages
- "No reviews yet" for new users
- Reviewer information loaded asynchronously

### 4. **ReviewProvider** (`lib/providers/review_provider.dart`)
Optional centralized state management for reviews (for future use with Provider).

## How to Use

### Step 1: Navigate to RateReviewScreen After Session Completion

In your session completion flow (e.g., RequestsScreen or after marking a session complete):

```dart
// Example from requests screen after session is marked complete
void _navigateToReview(Request request) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RateReviewScreen(
        requestId: request.id,
        skillTitle: request.skillName,
        otherUserId: request.otherUserId, // Person being reviewed
        otherUserName: request.otherUserName,
        sessionDate: _formatDate(request.completedDate),
      ),
    ),
  );
}
```

### Step 2: User Submits Review

1. User views session summary card
2. Clicks 1-5 stars to rate
3. Optionally writes review text
4. Clicks "Submit Review" button
5. App shows loading spinner
6. Review is submitted to Firebase
7. Success dialog appears
8. User is redirected to requests list

### Step 3: Review Publishing Logic

**Automatic Publishing:**
- When first user submits review: stored with `isPublished=false`
- System checks if other user has submitted review
- If yes: both reviews set to `isPublished=true`
- If no: review waits for other user

**Rating Calculation:**
- Runs after both reviews are published
- Calculates average of all published reviews
- Updates user profile with rating and review count

### Step 4: Display on Profile

Reviews automatically appear on user profiles in the "Reviews" section:
- Shows reviewer avatar and name
- Displays star rating
- Shows relative date
- Includes review text

## Firebase Schema

### Reviews Collection
```
reviews/
  {reviewId}/
    id: string              // Unique review ID
    requestId: string       // Link to session/request
    reviewerId: string      // UID of reviewer
    revieweeId: string      // UID of person being reviewed
    rating: int (1-5)       // Star rating
    text: string            // Review text (optional)
    isPublished: boolean    // Published after mutual review
    createdAt: timestamp    // When review was submitted
    updatedAt: timestamp    // When review was last updated
```

### Users Collection Updates
```
users/{userId}/
  rating: double          // Average of all published reviews
  totalReviews: int       // Count of published reviews
```

## Testing Checklist

### UI Testing
- [ ] RateReviewScreen displays with correct session info
- [ ] All 5 stars are clickable
- [ ] Rating text updates as stars clicked
- [ ] Review text field accepts input
- [ ] Submit button disabled until rating selected
- [ ] Loading spinner appears during submission
- [ ] Success dialog shows correct user name
- [ ] Skip button works

### Business Logic Testing
- [ ] Review submitted successfully
- [ ] Other user can view pending review indicator (future feature)
- [ ] Reviews appear on profile after mutual submission
- [ ] Rating calculated correctly on profile
- [ ] Review count updated

### Error Handling
- [ ] Network error shows snackbar
- [ ] Invalid user shows error
- [ ] Firebase permissions respected
- [ ] Mounted checks prevent crashes

## Integration Points

### 1. Connect to Request Completion
Add to your request completion flow (e.g., in `RequestsScreen` or `RequestDetailScreen`):

```dart
// After marking session as complete
void _completeSession(Request request) {
  // Mark session complete in Firebase
  
  // Navigate to review screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RateReviewScreen(
        requestId: request.id,
        skillTitle: request.skillName,
        otherUserId: request.otherUserId,
        otherUserName: request.otherUserName,
        sessionDate: request.completedDate.toString(),
      ),
    ),
  );
}
```

### 2. Add Review Pending Indicator (Future)
Check if review is pending:

```dart
final pending = await reviewService.reviewPending(requestId, currentUserId);
// Show "Pending review" badge on requests list
```

### 3. Connect ReviewProvider to Main App (Future)
When using ReviewProvider for state management:

```dart
// In main.dart
ChangeNotifierProvider(
  create: (_) => ReviewProvider(),
  child: MyApp(),
)
```

## Edge Cases Handled

✅ User not authenticated - error message shown
✅ Firebase permission denied - caught in try-catch
✅ Network timeout - error snackbar displayed
✅ Other user data not found - defaults to "Unknown User"
✅ Empty review text - accepted and saved
✅ Mounted state checked - prevents crashes after navigation
✅ Mutual review check - ensures both reviews published together

## Next Steps

1. **Link Session Completion**: Find where sessions are marked complete and add RateReviewScreen navigation
2. **Add Review Pending Notifications**: Notify users when other party submits review
3. **Create Completed Sessions List**: Show sessions eligible for review
4. **Add Rating Display Enhancement**: Add more prominent rating display on profile
5. **Create Reviews Management**: Allow users to edit/delete their own reviews

## API Reference

### ReviewService Methods

```dart
// Submit a review
Future<void> submitReview(
  String requestId,
  String reviewerId,
  String revieweeId,
  int rating,
  String text,
)

// Get published reviews for user
Future<List<ReviewModel>> getReviewsForUser(String userId)

// Check if review is pending
Future<bool> reviewPending(String requestId, String userId)

// Recalculate user rating
Future<void> recalculateRating(String userId)
```

## Debugging

### Enable Logging
Add to `ReviewService`:
```dart
print('Review submitted: $reviewId');
print('Published reviews: ${reviews.length}');
```

### Check Firebase Rules
Ensure Firestore rules allow reviews collection access:
```
allow read, write: if request.auth.uid != null;
```

### Validate Models
Check `ReviewModel.fromMap()` for deserialization issues

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Reviews not appearing on profile | Check Firestore security rules |
| Rating not updating | Run `recalculateRating()` manually |
| "Unknown User" showing | Verify reviewer exists in users collection |
| Submit button disabled | Ensure rating is selected (> 0) |
| Navigation fails | Check route names in app router |

---

**Status**: ✅ Implementation Complete  
**Test Status**: Ready for integration testing  
**Next Action**: Link to session completion flow
