import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

// Make sure these paths match your actual project structure!
import 'package:assignment/data/models/user_model.dart';
import 'package:assignment/data/services/database_service.dart';
import 'package:assignment/presentation/main_navigation.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final PageController _pageController = PageController();
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;
  bool _isLoading = false;

  // Data to capture
  String username = "";
  String genderPreference = "Unisex";
  int height = 170;
  int weight = 70;
  bool isMetric = true;
  String ageRange = "18-24";
  String style = "Streetwear";
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 400,
      maxHeight: 400,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
    if (mounted) Navigator.pop(context); // Close the bottom sheet
  }

  void _finishSetup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? base64Image;
      if (_image != null) {
        final bytes = await _image!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      // 1. Create the model
      UserModel profile = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        username: username.trim().isEmpty ? 'User' : username.trim(),
        gender: genderPreference,
        height: height.toString(),
        weight: weight.toString(),
        unit: isMetric ? 'metric' : 'imperial',
        age: ageRange,
        style: style,
        profileImageBase64: base64Image,
      );

      // 2. Use the service to save
      await _databaseService.saveUserProfile(profile);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : Column(
          children: [
            const SizedBox(height: 20),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildUsernameStep(),
                  _buildGenderStep(),
                  _buildMeasurementStep(),
                  _buildAgeStep(),
                  _buildStyleStep(),
                  _buildPhotoStep(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        children: List.generate(6, (index) => Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index <= _currentStep ? Colors.black : Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
      ),
    );
  }

  Widget _stepLayout({required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
          const SizedBox(height: 30),
          child,
        ],
      ),
    );
  }

  Widget _buildUsernameStep() {
    return _stepLayout(
      title: "What's your name?",
      subtitle: "Choose a name for your profile.",
      child: TextField(
        onChanged: (val) => username = val,
        decoration: InputDecoration(
          hintText: "Enter username",
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.all(20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildGenderStep() => _stepLayout(
    title: "What do you wear?",
    subtitle: "We'll tailor your feed based on your choice.",
    child: Column(children: ["Menswear", "Womenswear", "Unisex"].map((opt) => _customRadioTile(opt, genderPreference, (val) => setState(() => genderPreference = val))).toList()),
  );

  Widget _buildMeasurementStep() => _stepLayout(
    title: "Body Stats",
    subtitle: "Helps us find the perfect fit.",
    child: Column(
      children: [
        _unitToggle(),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(child: _compactRoller("Height", height, isMetric ? 100 : 40, isMetric ? "cm" : "in", (val) => setState(() => height = val))),
            const SizedBox(width: 20),
            Expanded(child: _compactRoller("Weight", weight, isMetric ? 40 : 80, isMetric ? "kg" : "lb", (val) => setState(() => weight = val))),
          ],
        ),
      ],
    ),
  );

  Widget _buildAgeStep() {
    final ranges = ["Under 18", "18-24", "25-34", "35-44", "45-54", "55+"];
    return _stepLayout(
      title: "How old are you?",
      subtitle: "Help us recommend the best trends.",
      child: Wrap(
        spacing: 12, runSpacing: 12,
        children: ranges.map((r) => ChoiceChip(
          label: Text(r),
          selected: ageRange == r,
          onSelected: (s) => setState(() => ageRange = r),
          selectedColor: Colors.black,
          labelStyle: TextStyle(color: ageRange == r ? Colors.white : Colors.black),
        )).toList(),
      ),
    );
  }

  Widget _buildStyleStep() => _stepLayout(
    title: "Pick your style",
    subtitle: "Define your aesthetic.",
    child: Column(children: ["Old Money", "Streetwear", "High Fashion", "Athleisure"].map((s) => _customRadioTile(s, style, (val) => setState(() => style = val))).toList()),
  );

  Widget _buildPhotoStep() => _stepLayout(
    title: "Add a Photo",
    subtitle: "Complete your profile look.",
    child: Column(
      children: [
        GestureDetector(
          onTap: () => _showImageSourceOptions(),
          child: CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey[100],
            backgroundImage: _image != null ? FileImage(_image!) : null,
            child: _image == null ? const Icon(Icons.add_a_photo_outlined, size: 30, color: Colors.black54) : null,
          ),
        ),
        const SizedBox(height: 20),
        TextButton(onPressed: _finishSetup, child: const Text("Skip for now", style: TextStyle(color: Colors.grey))),
      ],
    ),
  );

  Widget _customRadioTile(String label, String group, Function(String) onTap) {
    bool selected = label == group;
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: selected ? Colors.black : Colors.grey[50], borderRadius: BorderRadius.circular(18)),
        child: Row(children: [Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)), const Spacer(), if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 20)]),
      ),
    );
  }

  Widget _compactRoller(String label, int currentVal, int startAt, String unit, Function(int) onSelect) {
    return Column(children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
      const SizedBox(height: 10),
      Container(
        height: 120,
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20)),
        child: ListWheelScrollView.useDelegate(
          itemExtent: 45, physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (i) => onSelect(i + startAt),
          childDelegate: ListWheelChildBuilderDelegate(builder: (c, i) => Center(child: Text("${i + startAt} $unit", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), childCount: 200),
        ),
      ),
    ]);
  }

  Widget _unitToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _toggleBtn("Metric", isMetric, () => setState(() => isMetric = true)),
        _toggleBtn("Imperial", !isMetric, () => setState(() => isMetric = false)),
      ]),
    );
  }

  Widget _toggleBtn(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (c) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Take Photo"), onTap: () => _pickImage(ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo_library), title: const Text("Gallery"), onTap: () => _pickImage(ImageSource.gallery)),
      ])),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentStep > 0
              ? IconButton(
              onPressed: () {
                _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                setState(() => _currentStep--);
              },
              icon: const Icon(Icons.arrow_back_ios, size: 20)
          )
              : const SizedBox(width: 48),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(160, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
            ),
            onPressed: () {
              if (_currentStep < 5) {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                setState(() => _currentStep++);
              } else {
                _finishSetup();
              }
            },
            child: Text(_currentStep == 5 ? "Complete" : "Continue", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}