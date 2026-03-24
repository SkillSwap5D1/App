// ── MODELS ────────────────────────────────────────────────────────────────────
// These are temporary simple classes just for mock data.
// When you build Firebase later, these get replaced by your real models.

class MockUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String course;
  final String bio;
  final double rating;
  final int sessionsCompleted;
  final DateTime memberSince;

  const MockUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.course,
    required this.bio,
    required this.rating,
    required this.sessionsCompleted,
    required this.memberSince,
  });

  String get fullName => '$firstName $lastName';
  String get displayName => '$firstName ${lastName[0]}.';
}

class MockListing {
  final String id;
  final String ownerId;
  final String ownerName;
  final double ownerRating;
  final int ownerReviewCount;
  final String title;
  final String description;
  final List<String> tags;
  final String level;       // Beginner / Intermediate / Advanced
  final String modality;    // Online / In-Person
  final String category;    // Programming / Languages / Music etc
  final String nextAvailable;
  final bool isBookmarked;

  const MockListing({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerRating,
    required this.ownerReviewCount,
    required this.title,
    required this.description,
    required this.tags,
    required this.level,
    required this.modality,
    required this.category,
    required this.nextAvailable,
    this.isBookmarked = false,
  });
}

class MockRequest {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String listingId;
  final String skillName;
  final String message;
  final String status;      // pending / accepted / declined / countered
  final String timeAgo;
  final List<String> proposedTimes;

  const MockRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.listingId,
    required this.skillName,
    required this.message,
    required this.status,
    required this.timeAgo,
    required this.proposedTimes,
  });
}

class MockMessage {
  final String id;
  final String senderId;
  final String text;
  final String timestamp;
  final bool isMe;

  const MockMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}

class MockConversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isOnline;
  final String category;  // Programming / Languages / Design / Music
  final List<MockMessage> messages;

  const MockConversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
    required this.category,
    required this.messages,
  });
}

class MockNotification {
  final String id;
  final String type;        // message / request / reminder / accepted / declined
  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isRead;

  const MockNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.isRead,
  });
}

// ── MOCK DATA ─────────────────────────────────────────────────────────────────

class MockData {

  // ── CURRENT LOGGED IN USER ──────────────────────────────────────────────────
  static final MockUser currentUser = MockUser(
    id: 'user_001',
    firstName: 'Jamie',
    lastName: 'Wilson',
    email: 'jamie.wilson@myport.ac.uk',
    course: 'Computer Science',
    bio: 'Passionate about technology and learning new things. '
         'I love teaching what I know and picking up skills from others. '
         'Currently focused on web development and data science.',
    rating: 4.8,
    sessionsCompleted: 12,
    memberSince: DateTime(2025, 9, 1),
  );

  // ── OTHER USERS ─────────────────────────────────────────────────────────────
  static final List<MockUser> users = [
    MockUser(
      id: 'user_002',
      firstName: 'Alex',
      lastName: 'Chen',
      email: 'alex.chen@myport.ac.uk',
      course: 'Software Engineering',
      bio: 'Python enthusiast and coding tutor. '
           'Love helping beginners get started with programming.',
      rating: 4.8,
      sessionsCompleted: 24,
      memberSince: DateTime(2024, 9, 1),
    ),
    MockUser(
      id: 'user_003',
      firstName: 'Maria',
      lastName: 'Lopez',
      email: 'maria.lopez@myport.ac.uk',
      course: 'International Business',
      bio: 'Native Spanish speaker offering conversation practice. '
           'Intermediate and advanced levels welcome.',
      rating: 4.9,
      sessionsCompleted: 31,
      memberSince: DateTime(2024, 10, 1),
    ),
    MockUser(
      id: 'user_004',
      firstName: 'Jordan',
      lastName: 'Blake',
      email: 'jordan.blake@myport.ac.uk',
      course: 'Graphic Design',
      bio: 'UI/UX designer with a passion for teaching '
           'design fundamentals to beginners.',
      rating: 4.6,
      sessionsCompleted: 18,
      memberSince: DateTime(2025, 1, 15),
    ),
    MockUser(
      id: 'user_005',
      firstName: 'Sam',
      lastName: 'Rivera',
      email: 'sam.rivera@myport.ac.uk',
      course: 'Music Technology',
      bio: 'Guitar player of 8 years. '
           'Teaching all styles from classical to rock.',
      rating: 4.7,
      sessionsCompleted: 15,
      memberSince: DateTime(2025, 2, 1),
    ),
    MockUser(
      id: 'user_006',
      firstName: 'Priya',
      lastName: 'Sharma',
      email: 'priya.sharma@myport.ac.uk',
      course: 'Data Science',
      bio: 'Data science student looking to learn '
           'web development skills.',
      rating: 4.5,
      sessionsCompleted: 6,
      memberSince: DateTime(2025, 3, 1),
    ),
    MockUser(
      id: 'user_007',
      firstName: 'Liam',
      lastName: 'Foster',
      email: 'liam.foster@myport.ac.uk',
      course: 'Photography',
      bio: 'Photographer wanting to build a portfolio website.',
      rating: 4.3,
      sessionsCompleted: 4,
      memberSince: DateTime(2025, 3, 10),
    ),
  ];

  // ── LISTINGS ────────────────────────────────────────────────────────────────
  static const List<MockListing> listings = [
    MockListing(
      id: 'listing_001',
      ownerId: 'user_002',
      ownerName: 'Alex Chen',
      ownerRating: 4.8,
      ownerReviewCount: 24,
      title: 'Python Programming',
      description: 'Learn Python from scratch — variables, loops, '
                   'data structures, and build your first projects together. '
                   'Perfect for complete beginners.',
      tags: ['Programming', 'Computer Science', 'Beginner'],
      level: 'Beginner',
      modality: 'Online',
      category: 'Programming',
      nextAvailable: 'Tomorrow, 3 PM',
    ),
    MockListing(
      id: 'listing_002',
      ownerId: 'user_003',
      ownerName: 'Maria Lopez',
      ownerRating: 4.9,
      ownerReviewCount: 31,
      title: 'Spanish Conversation Practice',
      description: 'Practice real-world Spanish conversation. '
                   'Improve your accent, vocabulary, and confidence speaking. '
                   'Native speaker with teaching experience.',
      tags: ['Languages', 'Culture', 'Intermediate'],
      level: 'Intermediate',
      modality: 'In-Person',
      category: 'Languages',
      nextAvailable: 'Today, 5 PM',
    ),
    MockListing(
      id: 'listing_003',
      ownerId: 'user_004',
      ownerName: 'Jordan Blake',
      ownerRating: 4.6,
      ownerReviewCount: 18,
      title: 'Digital Design Basics',
      description: 'Get started with UI/UX design. '
                   'Learn layout principles, colour theory, and '
                   'how to use Figma to create stunning designs.',
      tags: ['Design', 'Creative', 'Beginner'],
      level: 'Beginner',
      modality: 'Online',
      category: 'Design',
      nextAvailable: 'Wed, 2 PM',
    ),
    MockListing(
      id: 'listing_004',
      ownerId: 'user_005',
      ownerName: 'Sam Rivera',
      ownerRating: 4.7,
      ownerReviewCount: 15,
      title: 'Guitar Lessons',
      description: 'Acoustic guitar for any level. '
                   'Chords, strumming patterns, music theory basics, '
                   'and your favourite songs.',
      tags: ['Music', 'Creative'],
      level: 'Beginner',
      modality: 'In-Person',
      category: 'Music',
      nextAvailable: 'Thu, 4 PM',
    ),
    MockListing(
      id: 'listing_005',
      ownerId: 'user_002',
      ownerName: 'Alex Chen',
      ownerRating: 4.8,
      ownerReviewCount: 24,
      title: 'Web Development with React',
      description: 'Build modern web apps using React. '
                   'Covers components, hooks, state management, '
                   'and connecting to APIs.',
      tags: ['Programming', 'Computer Science', 'Intermediate'],
      level: 'Intermediate',
      modality: 'Online',
      category: 'Programming',
      nextAvailable: 'Fri, 11 AM',
    ),
    MockListing(
      id: 'listing_006',
      ownerId: 'user_003',
      ownerName: 'Maria Lopez',
      ownerRating: 4.9,
      ownerReviewCount: 31,
      title: 'Business Spanish',
      description: 'Professional Spanish for business settings. '
                   'Emails, presentations, meetings, and negotiations. '
                   'Advanced level only.',
      tags: ['Languages', 'Business', 'Advanced'],
      level: 'Advanced',
      modality: 'Online',
      category: 'Languages',
      nextAvailable: 'Mon, 10 AM',
      isBookmarked: true,
    ),
  ];

  // ── MY LISTINGS (current user owns these) ───────────────────────────────────
  static const List<MockListing> myListings = [
    MockListing(
      id: 'listing_007',
      ownerId: 'user_001',
      ownerName: 'Jamie Wilson',
      ownerRating: 4.8,
      ownerReviewCount: 12,
      title: 'Flutter App Development',
      description: 'Learn to build cross-platform mobile apps '
                   'using Flutter and Dart. From zero to your '
                   'first working app.',
      tags: ['Programming', 'Mobile', 'Beginner'],
      level: 'Beginner',
      modality: 'Online',
      category: 'Programming',
      nextAvailable: 'Tomorrow, 2 PM',
    ),
    MockListing(
      id: 'listing_008',
      ownerId: 'user_001',
      ownerName: 'Jamie Wilson',
      ownerRating: 4.8,
      ownerReviewCount: 12,
      title: 'Data Structures & Algorithms',
      description: 'Crack coding interviews. '
                   'Arrays, linked lists, trees, sorting, '
                   'and dynamic programming explained clearly.',
      tags: ['Programming', 'Computer Science', 'Intermediate'],
      level: 'Intermediate',
      modality: 'Online',
      category: 'Programming',
      nextAvailable: 'Sat, 3 PM',
    ),
  ];

  // ── SAVED LISTINGS ──────────────────────────────────────────────────────────
  static List<MockListing> savedListings = [
    listings[1], // Spanish Conversation
    listings[5], // Business Spanish
    listings[2], // Digital Design
  ];

  // ── INCOMING REQUESTS ───────────────────────────────────────────────────────
  static const List<MockRequest> incomingRequests = [
    MockRequest(
      id: 'req_001',
      fromUserId: 'user_006',
      fromUserName: 'Priya Sharma',
      listingId: 'listing_007',
      skillName: 'Flutter App Development',
      message: 'Hi Jamie! I\'d love to learn Flutter. '
               'I have some Python experience and want to '
               'build a mobile app for my final year project.',
      status: 'pending',
      timeAgo: '2 hours ago',
      proposedTimes: ['Mon 14 Apr, 2:00 PM', 'Tue 15 Apr, 4:00 PM'],
    ),
    MockRequest(
      id: 'req_002',
      fromUserId: 'user_007',
      fromUserName: 'Liam Foster',
      listingId: 'listing_007',
      skillName: 'Flutter App Development',
      message: 'Hey! I\'m a photographer and want to build '
               'my own portfolio app. Can you help me '
               'learn the basics?',
      status: 'pending',
      timeAgo: '5 hours ago',
      proposedTimes: ['Wed 16 Apr, 3:00 PM'],
    ),
  ];

  // ── OUTGOING REQUESTS ───────────────────────────────────────────────────────
  static const List<MockRequest> outgoingRequests = [
    MockRequest(
      id: 'req_003',
      fromUserId: 'user_001',
      fromUserName: 'Jamie Wilson',
      listingId: 'listing_002',
      skillName: 'Spanish Conversation Practice',
      message: 'Hi Maria! I saw your Spanish listing. '
               'I\'d love to practice — I\'m at intermediate level.',
      status: 'accepted',
      timeAgo: '1 day ago',
      proposedTimes: ['Thu 17 Apr, 5:00 PM'],
    ),
    MockRequest(
      id: 'req_004',
      fromUserId: 'user_001',
      fromUserName: 'Jamie Wilson',
      listingId: 'listing_003',
      skillName: 'Digital Design Basics',
      message: 'Hi Jordan! Really interested in learning '
               'Figma for my projects.',
      status: 'pending',
      timeAgo: '3 hours ago',
      proposedTimes: ['Fri 18 Apr, 2:00 PM', 'Sat 19 Apr, 11:00 AM'],
    ),
  ];

  // ── CONVERSATIONS ───────────────────────────────────────────────────────────
  static const List<MockConversation> conversations = [
    MockConversation(
      id: 'conv_001',
      otherUserId: 'user_003',
      otherUserName: 'Maria Lopez',
      lastMessage: 'See you at the library tomorrow!',
      timestamp: '10:42 AM',
      unreadCount: 2,
      isOnline: true,
      category: 'Languages',
      messages: [
        MockMessage(
          id: 'msg_001',
          senderId: 'user_001',
          text: 'Hi! I saw your Spanish conversation listing. '
                'I\'d love to practice!',
          timestamp: '10:30 AM',
          isMe: true,
        ),
        MockMessage(
          id: 'msg_002',
          senderId: 'user_003',
          text: 'Hola! That\'s great 😊 What level are you at?',
          timestamp: '10:32 AM',
          isMe: false,
        ),
        MockMessage(
          id: 'msg_003',
          senderId: 'user_001',
          text: 'I\'d say intermediate — I can hold conversations '
                'but want to sound more natural.',
          timestamp: '10:35 AM',
          isMe: true,
        ),
        MockMessage(
          id: 'msg_004',
          senderId: 'user_003',
          text: 'Perfect! We can do conversational practice. '
                'Want to meet at the campus library?',
          timestamp: '10:38 AM',
          isMe: false,
        ),
        MockMessage(
          id: 'msg_005',
          senderId: 'user_001',
          text: 'That sounds perfect! When works for you?',
          timestamp: '10:40 AM',
          isMe: true,
        ),
        MockMessage(
          id: 'msg_006',
          senderId: 'user_003',
          text: 'See you at the library tomorrow!',
          timestamp: '10:42 AM',
          isMe: false,
        ),
      ],
    ),
    MockConversation(
      id: 'conv_002',
      otherUserId: 'user_002',
      otherUserName: 'Alex Chen',
      lastMessage: 'I\'ll share my Python notes with you',
      timestamp: 'Yesterday',
      unreadCount: 0,
      isOnline: false,
      category: 'Programming',
      messages: [
        MockMessage(
          id: 'msg_007',
          senderId: 'user_002',
          text: 'Hey! Ready for our Python session tomorrow?',
          timestamp: 'Yesterday 3:00 PM',
          isMe: false,
        ),
        MockMessage(
          id: 'msg_008',
          senderId: 'user_001',
          text: 'Yes! Really looking forward to it.',
          timestamp: 'Yesterday 3:05 PM',
          isMe: true,
        ),
        MockMessage(
          id: 'msg_009',
          senderId: 'user_002',
          text: 'I\'ll share my Python notes with you',
          timestamp: 'Yesterday 3:08 PM',
          isMe: false,
        ),
      ],
    ),
  ];

  // ── NOTIFICATIONS ────────────────────────────────────────────────────────────
  static const List<MockNotification> notifications = [
    MockNotification(
      id: 'notif_001',
      type: 'request',
      title: 'New request from Priya Sharma',
      subtitle: 'wants to learn Flutter App Development',
      timeAgo: '2 hours ago',
      isRead: false,
    ),
    MockNotification(
      id: 'notif_002',
      type: 'request',
      title: 'New request from Liam Foster',
      subtitle: 'wants to learn Flutter App Development',
      timeAgo: '5 hours ago',
      isRead: false,
    ),
    MockNotification(
      id: 'notif_003',
      type: 'accepted',
      title: 'Maria Lopez accepted your request',
      subtitle: 'Spanish Conversation — Thu 17 Apr, 5:00 PM confirmed',
      timeAgo: '1 day ago',
      isRead: true,
    ),
    MockNotification(
      id: 'notif_004',
      type: 'message',
      title: 'New message from Maria Lopez',
      subtitle: 'See you at the library tomorrow!',
      timeAgo: '10:42 AM',
      isRead: false,
    ),
    MockNotification(
      id: 'notif_005',
      type: 'reminder',
      title: 'Session reminder',
      subtitle: 'Spanish with Maria Lopez — tomorrow at 5:00 PM',
      timeAgo: '1 hour ago',
      isRead: true,
    ),
  ];

  // ── BLOCKED USERS ───────────────────────────────────────────────────────────
  static final List<String> blockedUserIds = [
    // Initially empty, users can be added to this list
    // Example: 'user_002', 'user_005'
  ];

  // ── HELPER METHODS ───────────────────────────────────────────────────────────
  static bool isUserBlocked(String userId) {
    return blockedUserIds.contains(userId);
  }

  static void blockUser(String userId) {
    if (!blockedUserIds.contains(userId)) {
      blockedUserIds.add(userId);
    }
  }

  static void unblockUser(String userId) {
    blockedUserIds.remove(userId);
  }

  // ── CATEGORIES ───────────────────────────────────────────────────────────────
  static const List<String> categories = [
    'All',
    'Programming',
    'Languages',
    'Design',
    'Music',
    'Business',
    'Creative',
    'Data Science',
    'Art',
    'Culture',
    'Computer Science',
  ];

  // ── LEVELS ───────────────────────────────────────────────────────────────────
  static const List<String> levels = [
    'All Levels',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  // ── FORMATS ──────────────────────────────────────────────────────────────────
  static const List<String> formats = [
    'All Formats',
    'Online',
    'In-Person',
  ];

  // ── COURSES ──────────────────────────────────────────────────────────────────
  static const List<String> courses = [
    'Computer Science',
    'Software Engineering',
    'Business Management',
    'International Business',
    'Psychology',
    'Graphic Design',
    'Music Technology',
    'Data Science',
    'Photography',
    'Mechanical Engineering',
    'Education Studies',
    'Media Studies',
    'Sports Science',
    'Other',
  ];
}