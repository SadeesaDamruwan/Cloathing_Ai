import 'package:flutter/material.dart';
import 'package:assignment/presentation/widgets/neumorphic_container.dart';
import 'settings_page.dart'; // Update path as needed

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Tops', 'Bottoms', 'Accessories'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: const Text("My Closet", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent, elevation: 0,
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
      body: Column(
        children: [
          _buildFilterBar(),
          const Expanded(child: Center(child: Text("Digital Closet Items Load Here"))),
        ],
      ),
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