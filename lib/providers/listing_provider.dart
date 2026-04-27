import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';

class ListingProvider extends ChangeNotifier {
  final ListingService _listingService = ListingService();

  // ── State ─────────────────────────────────────────────────────────────────
  List<ListingModel> listings    = [];
  List<ListingModel> myListings  = [];
  List<String> savedListingIds   = [];
  bool isLoading                 = false;
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

  // ── Toggle saved/bookmarked ───────────────────────────────────────────────
  void toggleSaved(String listingId) {
    if (savedListingIds.contains(listingId)) {
      savedListingIds.remove(listingId);
    } else {
      savedListingIds.add(listingId);
    }
    notifyListeners();
  }

  // ── Check if listing is saved ─────────────────────────────────────────────
  bool isSaved(String listingId) {
    return savedListingIds.contains(listingId);
  }

  // ── Get saved listings ────────────────────────────────────────────────────
  List<ListingModel> get savedListings {
    return listings
        .where((l) => savedListingIds.contains(l.id))
        .toList();
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
        query:    query,
        category: category,
        level:    level,
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