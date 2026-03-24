import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> isProfileSetupComplete(String uid) async {
    try {
      final doc = await _db.collection('user_closets').doc(uid).get(
        const GetOptions(source: Source.serverAndCache),
      );

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return data['setupComplete'] == true ||
            (data['selected_items'] as List?)?.isNotEmpty == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _db.collection('user_closets').doc(user.uid).set(
        user.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception("Failed to save profile: $e");
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) async {
    try {
      return await _db.collection('user_closets').doc(uid).get();
    } catch (e) {
      throw Exception("Failed to fetch profile: $e");
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('user_closets').doc(uid).update(data);
    } catch (e) {
      throw Exception("Update failed: $e");
    }
  }

  Future<void> deleteUserCloset(String uid) async {
    try {
      await _db.collection('user_closets').doc(uid).delete();
    } catch (e) {
      throw Exception("Failed to delete user data: $e");
    }
  }


  Future<void> saveCustomClosetItem(String uid, String name, String category, String base64Image) async {
    try {
      await _db.collection('user_closets').doc(uid).set({
        'selected_items': FieldValue.arrayUnion([name]),
        'custom_images': FieldValue.arrayUnion([{'name': name, 'category': category, 'image_base64': base64Image}])
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to save item: $e");
    }
  }
}