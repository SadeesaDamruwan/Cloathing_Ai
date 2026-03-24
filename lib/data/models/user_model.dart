import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String gender;
  final String height;
  final String weight;
  final String unit;
  final String age;
  final String style;
  final String? profileImageBase64;
  final bool setupComplete;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.gender,
    required this.height,
    required this.weight,
    required this.unit,
    required this.age,
    required this.style,
    this.profileImageBase64,
    this.setupComplete = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'gender': gender,
      'height': height,
      'weight': weight,
      'unit': unit,
      'age': age,
      'style': style,
      'profile_image_base64': profileImageBase64,
      'setupComplete': setupComplete,
      'appLockEnabled': false, // Default security value
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}