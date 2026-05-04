import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  // ── Firebase instance ─────────────────────────────────────────────────────
  final FirebaseFirestore _db;

  UserService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  // ── Get a single user ─────────────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;

    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // ── Real time stream of user data ─────────────────────────────────────────
  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return UserModel.fromMap(doc.data()!);
          }
          return null;
        });
  }

  // ── Update user profile ───────────────────────────────────────────────────
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // ── Update saved listings for a user ─────────────────────────────────────
  Future<void> updateSavedListings(
    String uid,
    String listingId,
    bool save,
  ) async {
    try {
      await _db.collection('users').doc(uid).update({
        'savedListingIds': save
            ? FieldValue.arrayUnion([listingId])
            : FieldValue.arrayRemove([listingId]),
      });
    } catch (e) {
      throw Exception('Failed to update saved listings: $e');
    }
  }

  // ── Load saved listings for a user ────────────────────────────────────────
  Future<List<String>> getSavedListingIds(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return [];
      final data = doc.data() ?? {};
      return List<String>.from(data['savedListingIds'] ?? const []);
    } catch (e) {
      throw Exception('Failed to load saved listings: $e');
    }
  }

  // ── Update privacy settings ───────────────────────────────────────────────
  Future<void> updatePrivacySettings(
    String uid, {
    required bool showFullName,
    required bool showCourse,
    required bool showPhoto,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .update({
            'showFullName': showFullName,
            'showCourse':   showCourse,
            'showPhoto':    showPhoto,
          });
    } catch (e) {
      throw Exception('Failed to update privacy settings: $e');
    }
  }

  // ── Update user rating after a review ────────────────────────────────────
  Future<void> updateUserRating(String uid) async {
    try {
      // Get all published reviews for this user
      final reviews = await _db
          .collection('reviews')
          .where('toUserId', isEqualTo: uid)
          .where('isPublished', isEqualTo: true)
          .get();

      if (reviews.docs.isEmpty) return;

      // Calculate average rating
      final total = reviews.docs
          .map((doc) => (doc.data()['rating'] ?? 0).toDouble())
          .reduce((a, b) => a + b);

      final average = total / reviews.docs.length;

      // Update user's rating
      await _db
          .collection('users')
          .doc(uid)
          .update({'rating': average});

    } catch (e) {
      throw Exception('Failed to update rating: $e');
    }
  }

  // ── Search users by name ──────────────────────────────────────────────────
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await _db
          .collection('users')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) =>
              user.fullName.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();

    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}