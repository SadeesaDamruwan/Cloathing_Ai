import 'package:flutter/material.dart';
import 'package:assignment/presentation/community/community_page.dart';
import 'package:assignment/presentation/ai_stylist/ai_stylist_page.dart';
import 'package:assignment/presentation/profile/profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Professional way: Define navigation items in a list of objects
  final List<Widget> _pages = [
    const CommunityPage(),
    const AiStylistPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color navBgColor = Color(0xFFE0E5EC);

    return Scaffold(
      // IndexedStack is professional because it preserves the state of your pages
      // (e.g., if you scroll on the Feed, it stays there when you come back)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0, // We use the Container's shadow for a cleaner look
          backgroundColor: navBgColor,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black45,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          type: BottomNavigationBarType.fixed, // Prevents shifting animation
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_sharp),
              label: "Feed",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: "AI Stylist",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}