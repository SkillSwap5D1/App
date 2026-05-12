import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../services/request_service.dart';
import 'dart:async';

class RequestProvider extends ChangeNotifier {
  final RequestService _requestService = RequestService();
  String? _activeUid;

  // ── State ─────────────────────────────────────────────────────────────────
  List<RequestModel> incoming = [];
  List<RequestModel> outgoing = [];
  bool isLoading = false;
  String? errorMessage;

  // ── Stream subscriptions ──────────────────────────────────────────────────
  StreamSubscription? _incomingSubscription;
  StreamSubscription? _outgoingSubscription;

  // ── Load requests — starts real time streams ──────────────────────────────
  void loadRequests(String uid) {
    _activeUid = uid;

    _incomingSubscription?.cancel();
    _outgoingSubscription?.cancel();

    incoming = [];
    outgoing = [];
    notifyListeners();

    // Listen to incoming requests
    _incomingSubscription = _requestService.getIncomingRequests(uid).listen((
      data,
    ) {
      incoming = data;
      notifyListeners();
    });

    // Listen to outgoing requests
    _outgoingSubscription = _requestService.getOutgoingRequests(uid).listen((
      data,
    ) {
      outgoing = data;
      notifyListeners();
    });
  }

  // ── Send a request ────────────────────────────────────────────────────────
  Future<String?> sendRequest(RequestModel request) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final id = await _requestService.sendRequest(request);
      return id;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Accept a request ──────────────────────────────────────────────────────
  Future<void> acceptRequest(
    String requestId,
    Map<String, String> confirmedSlot,
    String requesterName,
    String skillName,
    String requesterId,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _requestService.acceptRequest(
        requestId,
        confirmedSlot,
        requesterName,
        skillName,
        requesterId,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Decline a request ─────────────────────────────────────────────────────
  Future<void> declineRequest(
    String requestId,
    String requesterId,
    String skillName,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _requestService.declineRequest(requestId, requesterId, skillName);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Counter a request ─────────────────────────────────────────────────────
  Future<void> counterRequest(
    String requestId,
    List<Map<String, dynamic>> newSlots,
    String note,
    String requesterId,
    String skillName,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _requestService.counterRequest(
        requestId,
        newSlots,
        note,
        requesterId,
        skillName,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Get unread count for bottom nav badge ─────────────────────────────────
  int get pendingCount {
    return incoming.where((r) => r.isPending).length;
  }

  // ── Cancel streams on dispose ─────────────────────────────────────────────
  @override
  void dispose() {
    _incomingSubscription?.cancel();
    _outgoingSubscription?.cancel();
    super.dispose();
  }
}
