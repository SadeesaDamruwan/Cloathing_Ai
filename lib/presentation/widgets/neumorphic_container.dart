import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isInner;
  final Color color;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.isInner = false, // Defaults to false (popped out) if not specified
    this.color = const Color(0xFFE0E5EC),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isInner
            ? [
          // Inner Shadow (Pressed in effect)
          BoxShadow(color: Colors.grey.shade400, offset: const Offset(2, 2), blurRadius: 2),
          const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 2)
        ]
            : [
          // Outer Shadow (Popped out effect)
          BoxShadow(color: Colors.grey.shade500, offset: const Offset(6, 6), blurRadius: 10),
          const BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 10)
        ],
      ),
      child: child,
    );
  }
}