
# SkillSwap

A peer-to-peer skill exchange mobile application for University of 
Portsmouth students. SkillSwap enables students to offer and discover 
skills, send lesson requests, communicate via real-time chat, and 
rate sessions — all within a verified university environment.

Built with Flutter and Firebase as part of the Software Engineering 
Theory and Practice (M30819) module, Iteration 2.

---

## Demo

Video demonstration: https://www.youtube.com/watch?v=iX1_VaygFvw

---

## Features

- University email authentication (@myport.ac.uk only)
- Google Sign In restricted to university accounts
- Browse and search skill listings with filters
- Send lesson requests with multiple proposed time slots
- Accept, decline, or counter requests
- Real-time chat between matched users
- Automatic conversation creation on request acceptance
- Rate and review completed sessions (dual submission system)
- Report and block users
- Configurable privacy settings
- In-app notifications
- User onboarding flow

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter & Dart |
| State Management | Provider (ChangeNotifier) |
| Authentication | Firebase Auth + Google Sign In |
| Database | Cloud Firestore (europe-west2) |
| Fonts | Google Fonts — Inter |

---

## Project Structure

```
lib/
├── main.dart                  # Firebase init + Provider setup + routing
├── firebase_options.dart      # Auto-generated Firebase config
├── theme/
│   └── app_theme.dart         # Colours, text styles, spacing constants
├── models/                    # 7 data classes
│   ├── user_model.dart
│   ├── listing_model.dart
│   ├── request_model.dart
│   ├── conversation_model.dart
│   ├── message_model.dart
│   ├── notification_model.dart
│   └── review_model.dart
├── services/                  # 8 service classes (all Firebase calls)
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── listing_service.dart
│   ├── request_service.dart
│   ├── chat_service.dart
│   ├── notification_service.dart
│   ├── review_service.dart
│   └── report_service.dart
├── providers/                 # 5 state management providers
│   ├── auth_provider.dart
│   ├── listing_provider.dart
│   ├── request_provider.dart
│   ├── chat_provider.dart
│   └── notification_provider.dart
├── screens/                   # 18 screens across 9 feature folders
│   ├── auth/
│   ├── home/
│   ├── browse/
│   ├── listings/
│   ├── requests/
│   ├── chat/
│   ├── notifications/
│   ├── profile/
│   └── reviews/
└── widgets/                   # Shared reusable widgets
```

---

## Firestore Collections

| Collection | Purpose |
|-----------|---------|
| users | User profiles and privacy settings |
| listings | Skill listings with soft delete |
| requests | Lesson requests and status tracking |
| conversations | Chat threads between users |
| messages | Individual chat messages |
| notifications | In-app alerts and reminders |
| reviews | Post-session ratings (dual submission) |
| reports | User safety reports |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Dart ^3.7.2
- Firebase project configured
- Android Studio or VS Code

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/SkillSwap5D1/App.git
   cd App
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Run the app
   ```bash
   flutter run
   ```

### Running Tests

Run all tests:
```bash
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

Run integration tests:
```bash
flutter test integration_test/app_test.dart
```

---

## Branching Strategy

| Branch | Purpose |
|--------|---------|
| main | Stable production code — updated weekly |
| dev | Integration branch — all PRs merge here first |
| feature/* | One branch per screen or service file |

---

## Authentication

Only University of Portsmouth email addresses 
(@myport.ac.uk) are accepted at login and registration. 
This is enforced at the service level before any 
Firebase call is made. Google Sign In is also restricted 
to @myport.ac.uk Google accounts only.

---

## Team

Developed by SkillSwap5D1 as part of M30819 
Software Engineering Theory and Practice at the 
University of Portsmouth, May 2026.

---

## Module

University of Portsmouth  
School of Computing  
M30819 Software Engineering Theory and Practice  
Module Coordinator: Dr Claudia Iacob
```

