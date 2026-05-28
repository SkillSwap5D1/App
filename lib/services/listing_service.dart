import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class ListingService {
  // ── Firebase instance ─────────────────────────────────────────────────────
  final FirebaseFirestore _db;

  ListingService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  // ── Get all active listings ───────────────────────────────────────────────
  Future<List<ListingModel>> getAllListings() async {
    try {
      final snapshot =
          await _db
              .collection('listings')
              .where('isActive', isEqualTo: true)
              .get();

      return snapshot.docs
          .map((doc) => ListingModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get listings: $e');
    }
  }

  // ── Real time stream of all listings ─────────────────────────────────────
  Stream<List<ListingModel>> listingsStream() {
    return _db
        .collection('listings')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ListingModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  // ── Get listings owned by a specific user ─────────────────────────────────
  Future<List<ListingModel>> getMyListings(String uid) async {
    try {
      final snapshot =
          await _db
              .collection('listings')
              .where('ownerId', isEqualTo: uid)
              .where('isActive', isEqualTo: true)
              .get();

      return snapshot.docs
          .map((doc) => ListingModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get my listings: $e');
    }
  }

  // ── Create a new listing ──────────────────────────────────────────────────
  Future<void> createListing(ListingModel listing) async {
    try {
      // Generate a new document ID
      final docRef = _db.collection('listings').doc();

      // Save with the generated ID
      await docRef.set(listing.copyWith(id: docRef.id).toMap());
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  // ── Update an existing listing ────────────────────────────────────────────
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('listings').doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  // ── Soft delete — sets isActive to false ──────────────────────────────────
  Future<void> deleteListing(String id) async {
    try {
      await _db.collection('listings').doc(id).update({'isActive': false});
    } catch (e) {
      throw Exception('Failed to delete listing: $e');
    }
  }

  // ── Search and filter listings ────────────────────────────────────────────
  Future<List<ListingModel>> searchListings({
    String query = '',
    String category = 'All',
    String level = 'All Levels',
    String modality = 'All Formats',
  }) async {
    try {
      // Start with all active listings
      Query q = _db.collection('listings').where('isActive', isEqualTo: true);

      // Apply category filter
      if (category != 'All') {
        q = q.where('category', isEqualTo: category);
      }

      // Apply level filter
      if (level != 'All Levels') {
        q = q.where('level', isEqualTo: level);
      }

      // Apply modality filter
      if (modality != 'All Formats') {
        q = q.where('modality', isEqualTo: modality);
      }

      final snapshot = await q.get();

      List<ListingModel> results =
          snapshot.docs
              .map(
                (doc) =>
                    ListingModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      // Apply text search filter locally
      if (query.isNotEmpty) {
        results =
            results
                .where(
                  (listing) =>
                      listing.title.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      listing.description.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      listing.tags.any(
                        (tag) =>
                            tag.toLowerCase().contains(query.toLowerCase()),
                      ),
                )
                .toList();
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }

  // ── Get a single listing by ID ────────────────────────────────────────────
  Future<ListingModel?> getListing(String id) async {
    try {
      final doc = await _db.collection('listings').doc(id).get();

      if (doc.exists) {
        return ListingModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get listing: $e');
    }
  }
}
