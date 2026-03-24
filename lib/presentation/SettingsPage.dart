import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:assignment/data/services/database_service.dart';
import 'package:assignment/data/services/auth_service.dart';
import 'package:assignment/presentation/widgets/neumorphic_container.dart';
import 'package:assignment/presentation/auth/auth_screen.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
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
    try {
      final doc = await _dbService.getUserProfile(user!.uid);
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _ageCtrl.text = data['age']?.toString() ?? '';
        _genderCtrl.text = data['gender']?.toString() ?? '';
        _heightCtrl.text = data['height']?.toString() ?? '';
        _weightCtrl.text = data['weight']?.toString() ?? '';
        _profileBase64 = data['profile_image_base64'];
      }
    } catch (e) {
      debugPrint("Error loading user: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
          title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.transparent,
          elevation: 0
      ),
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
              try {
                await _dbService.updateUserProfile(user!.uid, {
                  'age': _ageCtrl.text,
                  'gender': _genderCtrl.text,
                  'height': _heightCtrl.text,
                  'weight': _weightCtrl.text
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              } finally {
                setState(() => _isSaving = false);
              }
            }),
            const SizedBox(height: 30),
            _buildButton("Log Out", () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                        (route) => false
                );
              }
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
          backgroundImage: _profileBase64 != null ? MemoryImage(base64Decode(_profileBase64!)) : null,
          child: _profileBase64 == null ? const Icon(Icons.person, size: 40) : null,
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
          child: TextField(
              controller: ctrl,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 15))
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        child: SizedBox(
            height: 55,
            width: double.infinity,
            child: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)))
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () => _showDeleteDialog(),
      child: NeumorphicContainer(
        color: const Color(0xFFFFEBEE),
        child: const SizedBox(
            height: 55,
            width: double.infinity,
            child: Center(child: Text("Delete Account", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFE0E5EC),
        title: const Text("Delete Account?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.black))),
          TextButton(onPressed: () async {
            try {
              await _dbService.deleteUserCloset(user!.uid);
              await user!.delete();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                        (route) => false
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please re-login to delete account.")));
              }
            }
          }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}