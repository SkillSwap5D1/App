import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';
import '../services/user_service.dart';

class ListingProvider extends ChangeNotifier {
  final ListingService _listingService = ListingService();
  final UserService _userService = UserService();

  // ── State ─────────────────────────────────────────────────────────────────
  List<ListingModel> listings = [];
  List<ListingModel> myListings = [];
  List<String> savedListingIds = [];
  bool isLoading = false;
  String? errorMessage;

  // ── Load all listings ─────────────────────────────────────────────────────
  Future<void> loadListings() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      listings = await _listingService.getAllListings();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Load my listings ──────────────────────────────────────────────────────
  Future<void> loadMyListings(String uid) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      myListings = await _listingService.getMyListings(uid);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Create a listing ──────────────────────────────────────────────────────
  Future<void> createListing(ListingModel listing) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _listingService.createListing(listing);
      await loadListings();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Update a listing ─────────────────────────────────────────────────────
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _listingService.updateListing(id, data);
      listings =
          listings
              .map(
                (listing) =>
                    listing.id == id
                        ? listing.copyWith(
                          title: data['title'] as String?,
                          description: data['description'] as String?,
                          level: data['level'] as String?,
                          modality: data['modality'] as String?,
                          category: data['category'] as String?,
                        )
                        : listing,
              )
              .toList();
      myListings =
          myListings
              .map(
                (listing) =>
                    listing.id == id
                        ? listing.copyWith(
                          title: data['title'] as String?,
                          description: data['description'] as String?,
                          level: data['level'] as String?,
                          modality: data['modality'] as String?,
                          category: data['category'] as String?,
                        )
                        : listing,
              )
              .toList();
      notifyListeners();
      await loadListings();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Delete a listing ──────────────────────────────────────────────────────
  Future<void> deleteListing(String id) async {
    try {
      await _listingService.deleteListing(id);
      myListings.removeWhere((l) => l.id == id);
      listings.removeWhere((l) => l.id == id);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Check if listing is saved ─────────────────────────────────────────────
  bool isSaved(String listingId) {
    return savedListingIds.contains(listingId);
  }

  // ── Get saved listings ────────────────────────────────────────────────────
  List<ListingModel> get savedListings {
    return listings.where((l) => savedListingIds.contains(l.id)).toList();
  }

  // ── Load saved listings for a user ───────────────────────────────────────
  Future<void> loadSavedListings(String uid) async {
    try {
      savedListingIds = await _userService.getSavedListingIds(uid);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Toggle saved/bookmarked and persist to Firestore ────────────────────
  Future<void> toggleSaved(String uid, String listingId) async {
    final shouldSave = !savedListingIds.contains(listingId);

    if (shouldSave) {
      savedListingIds.add(listingId);
    } else {
      savedListingIds.remove(listingId);
    }
    notifyListeners();

    try {
      await _userService.updateSavedListings(uid, listingId, shouldSave);
    } catch (e) {
      errorMessage = e.toString();
      if (shouldSave) {
        savedListingIds.remove(listingId);
      } else {
        savedListingIds.add(listingId);
      }
      notifyListeners();
    }
  }

  // ── Search listings ───────────────────────────────────────────────────────
  Future<void> searchListings({
    String query = '',
    String category = 'All',
    String level = 'All Levels',
    String modality = 'All Formats',
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      listings = await _listingService.searchListings(
        query: query,
        category: category,
        level: level,
        modality: modality,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
