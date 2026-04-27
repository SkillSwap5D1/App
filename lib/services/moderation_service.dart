import 'package:cloud_firestore/cloud_firestore.dart';
import './user_service.dart';

class ModerationService {
  static final ModerationService _instance = ModerationService._internal();

  factory ModerationService() {
    return _instance;
  }

  ModerationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
}
