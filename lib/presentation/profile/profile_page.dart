import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:assignment/data/services/database_service.dart';
import 'package:assignment/presentation/widgets/neumorphic_container.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _db = DatabaseService();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Tops', 'Bottoms', 'Accessories'];

  String _userName = "Stylist";
  String? _profileBase64;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch the username and profile picture from Firebase
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await _db.getUserProfile(user.uid);
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (mounted) {
            setState(() {
              _userName = data['username'] ?? "Stylist";
              _profileBase64 = data['profile_image_base64'];
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching profile: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: const Text("My Closet", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
              child: const NeumorphicContainer(
                borderRadius: 10,
                child: Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.settings)),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
        children: [
          _buildProfileHeader(), // 👇 Added the new header here
          const SizedBox(height: 20),
          _buildFilterBar(),
          const Expanded(child: Center(child: Text("Digital Closet Items Load Here"))),
        ],
      ),
    );
  }

  // The new Profile Header with the Image and Name
  Widget _buildProfileHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        NeumorphicContainer(
          borderRadius: 100,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: _profileBase64 != null ? MemoryImage(base64Decode(_profileBase64!)) : null,
              child: _profileBase64 == null ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          _userName,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Padding(
              padding: const EdgeInsets.only(right: 15, top: 5, bottom: 10),
              child: NeumorphicContainer(
                isInner: isSelected,
                borderRadius: 20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(filter, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.black45)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}