import 'package:flutter/material.dart';
import 'package:assignment/presentation/widgets/neumorphic_container.dart';
import 'package:assignment/data/models/post_model.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool isGlobal = true; // State for the toggle

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFE0E5EC);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Feed ", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: Colors.black)),
      ),
      body: Column(
        children: [
          _buildToggle(),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // This will eventually be postList.length
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemBuilder: (context, index) => _buildPostCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _toggleText("Global", isGlobal, () => setState(() => isGlobal = true)),
          const SizedBox(width: 40),
          _toggleText("Friends", !isGlobal, () => setState(() => isGlobal = false)),
        ],
      ),
    );
  }

  Widget _toggleText(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: active ? Colors.black : Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPostCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: NeumorphicContainer(
        borderRadius: 30,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: Image.network(
                "https://picsum.photos/seed/${DateTime.now().millisecond}/800/1000",
                height: 400,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatIcon(emoji: "🔥", count: 12),
                  _StatIcon(emoji: "😍", count: 45),
                  _StatIcon(emoji: "💬", count: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Small private widget for the stats to keep build method clean
class _StatIcon extends StatelessWidget {
  final String emoji;
  final int count;
  const _StatIcon({required this.emoji, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 5),
        Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}