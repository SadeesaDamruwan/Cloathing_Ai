import 'dart:convert';
import 'package:assignment/presentation/WelcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:assignment/data/services/database_service.dart';
import 'package:assignment/data/services/auth_service.dart';
import 'package:assignment/presentation/widgets/neumorphic_container.dart';
// 👇 1. Import your Welcome/Auth Screen here!
import 'package:assignment/presentation/WelcomeScreen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _db = DatabaseService();
  final _auth = AuthService();
  final user = FirebaseAuth.instance.currentUser;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _profileBase64;

  final _ageCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (user == null) return;
    final doc = await _db.getUserProfile(user!.uid);
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      _ageCtrl.text = data['age']?.toString() ?? '';
      _genderCtrl.text = data['gender']?.toString() ?? '';
      _heightCtrl.text = data['height']?.toString() ?? '';
      _weightCtrl.text = data['weight']?.toString() ?? '';

      // Safe base64 extraction just in case
      String rawImage = data['profile_image_base64'] ?? '';
      if (rawImage.contains(',')) {
        _profileBase64 = rawImage.split(',').last;
      } else if (rawImage.isNotEmpty) {
        _profileBase64 = rawImage;
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(title: const Text(
          "Settings", style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.transparent),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAvatar(),
            const SizedBox(height: 30),
            _buildInput("Age", _ageCtrl),
            _buildInput("Gender", _genderCtrl),
            _buildInput("Height", _heightCtrl),
            _buildInput("Weight", _weightCtrl),
            const SizedBox(height: 10),
            _buildButton(_isSaving ? "Saving..." : "Save Details", () async {
              setState(() => _isSaving = true);
              await _db.updateUserProfile(user!.uid, {
                'age': _ageCtrl.text,
                'gender': _genderCtrl.text,
                'height': _heightCtrl.text,
                'weight': _weightCtrl.text
              });
              if (!mounted) return;
              setState(() => _isSaving = false);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile Updated!")));
            }),
            const SizedBox(height: 30),

            // 👇 2. The Updated Logout Button
            _buildButton("Log Out", () async {
              await _auth.signOut();

              if (!mounted) return;
              // Clear the navigation stack and send them to the Welcome screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (Route<dynamic> route) => false,
              );
            }),

            const SizedBox(height: 20),
            _buildDeleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return NeumorphicContainer(
      borderRadius: 100,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: _profileBase64 != null ? MemoryImage(
              base64Decode(_profileBase64!)) : null,
          child: _profileBase64 == null
              ? const Icon(Icons.person, size: 40, color: Colors.grey)
              : null,
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        NeumorphicContainer(
          isInner: true,
          child: TextField(controller: ctrl,
              decoration: const InputDecoration(border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15))),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        child: SizedBox(height: 55,
            width: double.infinity,
            child: Center(child: Text(
                label, style: const TextStyle(fontWeight: FontWeight.bold)))),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () => _showDeleteDialog(),
      child: const NeumorphicContainer(
        child: SizedBox(height: 55,
            width: double.infinity,
            child: Center(child: Text("Delete Account", style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold)))),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            backgroundColor: const Color(0xFFE0E5EC),
            title: const Text("Delete Account",
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
                "Are you sure you want to delete this account permanently? This action cannot be undone."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                      "Cancel", style: TextStyle(color: Colors.black))
              ),
              TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);

                    try {
                      await _db.deleteUserCloset(user!.uid);
                      await user!.delete();

                      // 👇 3. The Updated Delete Redirect
                      if (!mounted) return;
                      // Clear the navigation stack and send them to the Welcome screen
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                            (Route<dynamic> route) => false,
                      );

                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'requires-recent-login') {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(
                                "Security requirement: Please log out and log back in before deleting your account.")),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${e.message}")));
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")));
                      }
                    }
                  },
                  child: const Text("Delete", style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold))
              ),
            ],
          ),
    );
  }
}