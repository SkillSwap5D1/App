import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../services/review_service.dart';
import '../services/user_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  final UserService _userService = UserService();

  List<ReviewModel> _reviews = [];
  Map<String, UserModel?> _reviewers = {};
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  Map<String, UserModel?> get reviewers => _reviewers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReviewsForUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await _reviewService.getReviewsForUser(userId);

      // Load reviewer info for each review
      _reviewers = {};
      for (final review in _reviews) {
        if (!_reviewers.containsKey(review.reviewerId)) {
          _reviewers[review.reviewerId] =
              await _userService.getUser(review.reviewerId);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load reviews: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitReview({
    required String requestId,
    required String reviewerId,
    required String revieweeId,
    required int rating,
    required String text,
  }) async {
    try {
      await _reviewService.submitReview(
        requestId,
        reviewerId,
        revieweeId,
        rating,
        text,
      );

      // Reload reviews for the reviewee
      await loadReviewsForUser(revieweeId);
    } catch (e) {
      _error = 'Failed to submit review: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> checkReviewPending(String requestId, String userId) async {
    try {
      return await _reviewService.reviewPending(requestId, userId);
    } catch (e) {
      _error = 'Failed to check review status: $e';
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _reviews = [];
    _reviewers = {};
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
