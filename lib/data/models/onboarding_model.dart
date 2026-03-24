import 'package:flutter/material.dart';

class OnboardingModel {
  final String title;
  final String description;
  final IconData icon;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.icon,
  });

  // Professionals often store this data in a static list within the model
  static List<OnboardingModel> list = [
    OnboardingModel(
      title: "Latest Trends",
      description: "Discover the most unique fashion trends.",
      icon: Icons.style_outlined,
    ),
    OnboardingModel(
      title: "Smart Search",
      description: "Find exactly what you need in seconds.",
      icon: Icons.manage_search_outlined,
    ),
    OnboardingModel(
      title: "Fast Shipping",
      description: "Outfits delivered to your doorstep.",
      icon: Icons.local_shipping_outlined,
    ),
  ];
}