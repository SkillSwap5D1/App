import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import './user_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a profile photo and return its download URL
  // 1. Create a reference at: profile_photos/{userId}/avatar.jpg
  // 2. Upload the file using FirebaseStorage.instance.ref().putFile()
  // 3. Get the download URL from the upload task snapshot
  // 4. Call UserService.updateProfile() to save the URL on the user doc
  // 5. Return the download URL
  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      // Step 1: Create a reference at profile_photos/{userId}/avatar.jpg
      final ref = _storage.ref().child('profile_photos/$userId/avatar.jpg');
      
      // Step 2: Upload the file using FirebaseStorage.instance.ref().putFile()
      final uploadTask = ref.putFile(imageFile);
      
      // Step 3: Get the download URL from the upload task snapshot
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Step 4: Call UserService.updateProfile() to save the URL on the user doc
      await UserService().updateProfile(userId, {'photoUrl': downloadUrl});
      
      // Step 5: Return the download URL
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
      rethrow;
    }
  }
}
