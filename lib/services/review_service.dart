import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  // ── Firebase instance ─────────────────────────────────────────────────────
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Submit a review after a completed session ──────────────────────────────
  // 1. Write review document to reviews collection with isPublished=false
  // 2. Check if the OTHER user has also submitted their review for this request
  // 3. If yes: set isPublished=true on BOTH review documents
  //    then call recalculateRating() for the reviewee
  // 4. If no: leave isPublished=false and wait
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

      // 1. Create the review document with isPublished=false initially
      final reviewData = ReviewModel(
        id: reviewId,
        requestId: requestId,
        reviewerId: reviewerId,
        revieweeId: revieweeId,
        rating: rating,
        text: text,
        isPublished: false,
        createdAt: now,
        updatedAt: now,
      );

      await _db.collection('reviews').doc(reviewId).set(reviewData.toMap());

      // 2. Check if the OTHER user (revieweeId) has submitted their review
      final otherReviewQuery =
          await _db
              .collection('reviews')
              .where('requestId', isEqualTo: requestId)
              .where('reviewerId', isEqualTo: revieweeId)
              .where('revieweeId', isEqualTo: reviewerId)
              .get();

      // 3. If yes: set isPublished=true on BOTH review documents
      if (otherReviewQuery.docs.isNotEmpty) {
        // Both users have reviewed, publish both reviews
        await _db.collection('reviews').doc(reviewId).update({
          'isPublished': true,
          'updatedAt': Timestamp.now(),
        });

        // Update the other review
        final otherReviewId = otherReviewQuery.docs.first.id;
        await _db.collection('reviews').doc(otherReviewId).update({
          'isPublished': true,
          'updatedAt': Timestamp.now(),
        });

        // Recalculate ratings for both reviewees
        await recalculateRating(revieweeId);
        await recalculateRating(reviewerId);
      }
      // 4. If no: leave isPublished=false and wait (already done above)
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
}
