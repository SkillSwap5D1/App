import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import 'notification_service.dart';
import 'user_service.dart';

class ReviewService {
  // ── Firebase instance ─────────────────────────────────────────────────────
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();

  // ── Submit a review after a completed session ──────────────────────────────
  // 1. Write review document to reviews collection with isPublished=false
  // 2. Check if the OTHER user has also submitted their review for this request
  // 3. If yes: set isPublished=true on BOTH review documents
  //    then call recalculateRating() for the reviewee
  // 4. Send notifications appropriately
  Future<void> submitReview(
    String requestId,
    String reviewerId,
    String revieweeId,
    int rating,
    String text,
  ) async {
    try {
      final now = DateTime.now();
      final reviewId = _db.collection('reviews').doc().id;

      // Get reviewer name for notifications
      final reviewerUser = await _userService.getUser(reviewerId);
      final reviewerName = reviewerUser?.displayName ?? 'A user';

      // 1. Create the review document and publish immediately
      final reviewData = ReviewModel(
        id: reviewId,
        requestId: requestId,
        reviewerId: reviewerId,
        revieweeId: revieweeId,
        rating: rating,
        text: text,
        isPublished: true,
        createdAt: now,
        updatedAt: now,
      );

      await _db.collection('reviews').doc(reviewId).set(reviewData.toMap());

      // 1.5 Send notification to the reviewee that their review is published
      try {
        await _notificationService.sendNotification(
          revieweeId,
          'review_published',
          '$reviewerName left a review',
          '$reviewerName gave you a $rating star review',
          requestId,
        );
      } catch (e) {
        if (kDebugMode) {
          print(
            '⚠️ [ReviewService] Could not send review_published notification: $e',
          );
        }
      }

      // Recalculate rating for the reviewee immediately
      await recalculateRating(revieweeId);
      if (kDebugMode) {
        print('✅ [ReviewService] Review published immediately for $revieweeId');
      }
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  // ── Recalculate and update a user's average rating ────────────────────────
  // 1. Query all published reviews where revieweeId == userId
  // 2. Calculate the average of all rating fields
  // 3. Update averageRating and totalReviews on the user document
  Future<void> recalculateRating(String userId) async {
    try {
      // 1. Query all published reviews for this user
      final reviewsQuery =
          await _db
              .collection('reviews')
              .where('revieweeId', isEqualTo: userId)
              .where('isPublished', isEqualTo: true)
              .get();

      // 2. Calculate the average rating
      if (reviewsQuery.docs.isEmpty) {
        // No reviews yet, set rating to 0 and totalReviews to 0
        await _db.collection('users').doc(userId).update({
          'rating': 0.0,
          'totalReviews': 0,
        });
        return;
      }

      double totalRating = 0;
      for (final doc in reviewsQuery.docs) {
        final rating = (doc['rating'] as num).toDouble();
        totalRating += rating;
      }

      final averageRating = totalRating / reviewsQuery.docs.length;

      // 3. Update the user document
      await _db.collection('users').doc(userId).update({
        'rating': averageRating,
        'totalReviews': reviewsQuery.docs.length,
      });
    } catch (e) {
      throw Exception('Failed to recalculate rating: $e');
    }
  }

  // ── Get all published reviews for a user (shown on their profile) ──────────
  // Query reviews where revieweeId == userId AND isPublished == true
  Future<List<ReviewModel>> getReviewsForUser(String userId) async {
    try {
      final query =
          await _db
              .collection('reviews')
              .where('revieweeId', isEqualTo: userId)
              .where('isPublished', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return query.docs.map((doc) => ReviewModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get reviews for user: $e');
    }
  }

  // ── Check if current user still needs to review a specific request ────────
  // Check if a review document exists for this requestId + reviewerId
  // Returns true if no review found yet (user still needs to review)
  Future<bool> reviewPending(String requestId, String userId) async {
    try {
      final query =
          await _db
              .collection('reviews')
              .where('requestId', isEqualTo: requestId)
              .where('reviewerId', isEqualTo: userId)
              .get();

      // Returns true if no review found (pending), false if already reviewed
      return query.docs.isEmpty;
    } catch (e) {
      throw Exception('Failed to check review pending status: $e');
    }
  }
}
