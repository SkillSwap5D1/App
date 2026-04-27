# SkillSwap - Remaining Screens Implementation Guide

## Overview
The core infrastructure is complete and compiling. The following screens need to be created/updated:

---

## SCREENS IMPLEMENTATION CHECKLIST

### 1. AUTH FLOWS (CRITICAL) ✅ READY TO IMPLEMENT
**Files:**
- `lib/screens/auth/onboarding_screen.dart` - NEW

**OnboardingScreen Requirements:**
- Two-page PageView flow
- Page 1: "What can you teach?"
- Page 2: "What do you want to learn?"
- Skill chips grid (3 per row): Programming, Languages, Design, Music, Business, Data Science, Art, Culture, Computer Science, Creative, Fitness, Other
- Unselected: #FAF8F5 bg, #EDE9E3 border
- Selected: #F5F3FF bg, #6B21A8 border + check icon
- Next/Get Started button (disabled until ≥1 selected)
- "Skip for now" button
- On complete: save to Firestore users doc, navigate to HomeShellScreen

---

### 2. BROWSE & LISTINGS (HIGH PRIORITY)
**Files:**
- `lib/screens/browse/browse_screen.dart` - UPDATE
- `lib/screens/listings/listing_detail_screen.dart` - UPDATE
- `lib/screens/listings/create_listing_screen.dart` - NEW

**BrowseScreen:**
- Top bar: "SkillSwap" title, notification bell with purple badge, user avatar
- Search bar with filters (Category, Level, Format dropdowns)
- "Available/My Skills" toggle
- Results grid (2 cards per row)
- Card: avatar, title, owner, rating, description (2 lines), tags, availability, "Send Request" button, bookmark toggle
- "My Skills" tab: Edit + Delete buttons, "+ Create New Listing"
- Empty state: search icon, "No skills found"
- Pull to refresh

**ListingDetailScreen:**
- Back arrow + three-dot menu (→ ReportScreen)
- Provider row: avatar, name, rating, review count
- Title, tags, Level+Modality info
- "About this skill" + full description
- "Availability" + time slots
- Provider stats card
- Sticky bottom: Edit+Delete (if owner) OR "Request Lesson" (if guest)

**CreateListingScreen:**
- AppBar: "Create Listing" / "Edit Listing"
- Fields: Title, Description, Category, Level, Modality, Tags (chip input), Time slots
- Save button
- On success: navigate back, show SnackBar "Listing created!"

---

### 3. REQUESTS (HIGH PRIORITY)
**Files:**
- `lib/screens/requests/requests_screen.dart` - UPDATE
- `lib/screens/requests/send_request_screen.dart` - UPDATE
- `lib/screens/requests/counter_offer_screen.dart` - NEW

**RequestsScreen:**
- Tabs: "Incoming" + badge count / "Outgoing"
- Incoming cards: avatar, name, "wants to learn [skill]", status badge (pending/accepted/declined/countered), proposed times, message quote, Accept/Decline buttons, "Counter →" link
- Outgoing cards: same but no action buttons
- Status badge colors:
  - pending: #FFF8E6 bg, #92400E text
  - accepted: #ECFDF5 bg, #2D6A4F text
  - declined: #FEF2F2 bg, #B91C1C text
  - countered: #F5F3FF bg, #6B21A8 text
- Empty state per tab

**SendRequestScreen:**
- Header: read-only listing card (white bg, beige border)
- "Propose Time Slots" section
- Date picker + start/end time for up to 3 slots
- Slot 1 required, "+ Add another time" button, × to remove
- Optional note field
- Validation: past dates rejected, at least 1 slot required
- "Send Request" button with loading state
- On success: SnackBar "Request sent!", pop back

**CounterOfferScreen:**
- Header: original request read-only card
- New time slots (same widget as SendRequestScreen)
- Optional message field
- "Send Counter Offer" button
- On success: SnackBar "Counter sent!", pop back

---

### 4. CHAT (MEDIUM PRIORITY)
**Files:**
- `lib/screens/chat/chat_list_screen.dart` - UPDATE
- `lib/screens/chat/chat_thread_screen.dart` - UPDATE

**ChatListScreen:**
- AppBar: "Messages" title, count subtitle
- Search bar to filter conversations
- ListView of conversation rows:
  - CircleAvatar (44x44), name, last message (1 line), timestamp, unread badge (black bg, white text)
  - Active row: #F5F3FF bg
- Tap to ChatThreadScreen
- Empty state: bubble icon, "No conversations yet"

**ChatThreadScreen:**
- AppBar: avatar, other user name, online status dot, three-dot menu (→ ReportScreen)
- Messages list: 
  - Their messages: white bg, beige border, left align, radius TL4 TR16 BL16 BR16
  - My messages: #0A0A0A bg, white text,right align, radius TL16 TR4 BL16 BR16
- Bottom input bar:
  - White bg, top border beige
  - TextField: warm off-white bg, radius 24, no border
  - Black circular send button (44x44)
- Auto-scroll to bottom on new message

---

### 5. PROFILE & SETTINGS (MEDIUM PRIORITY)
**Files:**
- `lib/screens/profile/profile_screen.dart` - UPDATE
- `lib/screens/profile/edit_profile_screen.dart` - UPDATE

**ProfileScreen:**
- Hero section: warm gradient, avatar (72x72), name, course (grey), stars + rating + count, 3-column stats
- "About" section: bio text
- "Contact" section: email row, member since row
- "Privacy Settings" section: 3 Switches (Show full name, Show course, Show photo)
- "Edit Profile" button

**EditProfileScreen:**
- AppBar: "Edit Profile", "Save" button (purple, disabled until change)
- Avatar with "Change photo" link
- First name, last name fields
- Bio multiline
- Course dropdown
- Email (greyed out, not editable)
- Save: calls UserService.updateUser(), SnackBar "Profile updated!", pop

---

### 6. OTHER SCREENS (LOWER PRIORITY)
**Files:**
- `lib/screens/notifications/notifications_screen.dart` - NEW
- `lib/screens/saved/saved_screen.dart` - NEW
- `lib/screens/reviews/rate_review_screen.dart` - UPDATE
- `lib/screens/safety/report_screen.dart` - NEW

**NotificationsScreen:**
- AppBar: "Notifications", "Mark all as read" button
- Notification rows with icons in colored circles:
  - request: #F5F3FF bg, inbox icon, #6B21A8
  - message: #EFF6FF bg, chat icon, #1D4ED8
  - accepted: #ECFDF5 bg, check icon, #2D6A4F
  - declined: #FEF2F2 bg, cancel icon, #B91C1C
  - reminder: #FFFBEB bg, access_time icon, #92400E
- Title bold, subtitle grey, timeAgo grey
- Unread: #FAF8F5 bg, Read: white bg
- Tap: navigate to relevant screen
- Empty state: notification icon, "No notifications"

**SavedScreen:**
- AppBar: "Saved Skills" + count
- Same grid as BrowseScreen
- Bookmark filled on all cards
- Tap bookmark: remove with "Removed — Undo" SnackBar
- Empty state: bookmark icon, "No saved skills yet", "Browse Skills" button

**RateReviewScreen:**
- Session summary card: "Completed Session" label, skill title, "with [name]", date
- "How was your session?" heading (centered)
- 5 stars (48x48 size): unselected #EDE9E3, selected #6B21A8, animate on tap
- Rating label: Poor/Fair/Good/Very Good/Excellent
- Optional review text field
- "Submit Review" button (disabled until stars selected)
- "Skip for now" button
- On success: SnackBar, navigate away

**ReportScreen (Bottom Sheet):**
- Handle bar at top
- "Report or Block" title, [User name] subtitle
- Divider
- "Report User" option with flag icon (red)
  - Opens form: Category dropdown (Harassment, Spam, Inappropriate Content, Fake Profile, Other), optional description field, "Submit Report" button
- "Block User" option with block icon (red)
  - Tap opens AlertDialog: "Block [name]?", "They can no longer message you", Cancel/Block buttons
  - On confirm: ReportService.blockUser(), SnackBar "User blocked", close

---

## HELPER UTILITIES TO CREATE

### 1. **Widgets** (`lib/widgets/`)

**badge_widget.dart:**
```dart
class BadgeWidget extends StatelessWidget {
  final int count;
  final Widget child;
  BadgeWidget({required this.count, required this.child});
  // Purple circle badge with count
}
```

**chip_selector_widget.dart:**
```dart
class ChipSelector extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged onChanged;
  final bool multiSelect;
  // Grid of chips with selection logic
}
```

**time_slot_picker_widget.dart:**
```dart
class TimeSlotPicker extends StatefulWidget {
  final Function(String) onSlotAdded;
  final Function(int) onSlotRemoved;
  // Date + time pickers
}
```

**rating_widget.dart:**
```dart
class StarRating extends StatefulWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  // 5 interactive stars
}
```

### 2. **Shared Helpers** (`lib/widgets/` or `lib/core/`)

**empty_state.dart:**
```dart
class EmptyState {
  static Widget listingEmpty() // Icon + "No skills found"
  static Widget conversationEmpty() // Icon + "No conversations"
  static Widget notificationEmpty() // Icon + "No notifications"
  // etc...
}
```

**snackbar_helper.dart:**
```dart
class SnackBarHelper {
  static void show(context, message, {isError = false})
  // #0A0A0A bg, white text, purple action, 3s duration, floating
}
```

**dialog_helper.dart:**
```dart
class DialogHelper {
  static Future<bool> confirmDelete(context, itemName)
  static Future<bool> blockUser(context, userName)
  // Common confirmation dialogs
}
```

---

## DATA FLOW EXAMPLES

### Flow 1: Send Request
1. Browse → Find listing → Tap "Send Request"
2. SendRequestScreen: User picks time slots + optional note
3. "Send Request" tap → RequestProvider.sendRequest()
4. RequestService: Check duplicate, write to Firestore, create conversation, send notification
5. OnSuccess: SnackBar "Request sent!", pop back
6. Provider streams update both users automatically

### Flow 2: Accept Request
1. Requests tab → Incoming → Find request → Tap "Accept"
2. Dialog: Pick confirmed time slot
3. "Accept" tap → RequestProvider.acceptRequest()
4. Firestore: Update status="accepted", set confirmedSlot
5. NotificationService: Send notification to requester
6. Provider stream updates in real-time

### Flow 3: Chat
1. After request accepted, users can message
2. Chat tab → Find conversation → Tap
3. ChatThreadScreen loads messages via ChatProvider stream
4. Type message → "Send" → ChatService.sendMessage()
5. Message written to messages collection
6. Conversation lastMessage updated
7. Provider streams notify both users

---

## FIRESTORE SECURITY RULES STATUS
✅ **TO BE ADDED**: Copy the provided rules into Firebase Console → Firestore → Rules tab
- User docs: read public, write owner
- Listings: read public, write owner
- Requests: read=shared users, write=participants
- Messages: read/write=participants
- Conversations: read/write=participants
- Notifications: write=requester, read=owner
- Reviews: read=public, write=submitter
- Reports: create=public, read=false (analytics only)

---

## PRIORITY ORDER TO COMPLETE
1. **OnboardingScreen** (unblocks auth flow)
2. **RequestsScreen**, **SendRequestScreen**, **CounterOfferScreen** (core feature)
3. **ChatListScreen**, **ChatThreadScreen** (core feature)
4. **BrowseScreen**, **ListingDetailScreen**, **CreateListingScreen** (content)
5. **NotificationsScreen**, **SavedScreen** (quality of life)
6. **RateReviewScreen**, **ReportScreen** (closure + safety)
7. Helper widgets & utils

---

## TESTING APPROACH
Once core screens are complete:
1. Test auth flow: Register with @myport.ac.uk → Onboarding → HomeShellScreen
2. Test browse: Browse listings → Create listing → See in list
3. Test requests: Send request → Accept/Decline/Counter → Notifications arrive
4. Test chat: Message after request accepted
5. Test profile: View & edit profile settings
6. Test end-to-end: User A sends request → User B accepts → Chat → Rate → Review visible

---

## NOTES
- All colors use AppColors constants from theme
- All text uses AppTextStyles
- All buttons show loading states
- All forms validate before submit
- All destructive actions confirmed
- No overflow errors/FutureBuilder without CircularProgressIndicator
- Keyboard never covers inputs (resizeToAvoidBottomInset: true, SingleChildScrollView)
- Minimum 375px width support
- Pull-to-refresh on Browse & Requests
