import 'package:flutter/material.dart';
import 'package:assignment/presentation/widgets/neumorphic_container.dart';
import 'package:assignment/presentation/AuthScreen.dart';
import 'package:assignment/presentation/OnboardingScreen.dart';

// We move AuthMode logic out of the UI and into a service or simple state
import '../data/services/auth_state.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFE0E5EC);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              _buildTitle(),
              const Spacer(),
              _buildGetStartedButton(context),
              const SizedBox(height: 24),
              _buildSignInText(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Define yourself in\nyour unique way.',
      style: TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: -2,
        color: Colors.black,
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return NeumorphicContainer(
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: () {
            AuthMode.isLogin = false;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text(
            'Get Started',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInText(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          AuthMode.isLogin = true;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        },
        child: RichText(
          text: const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(color: Colors.black54, fontSize: 15),
            children: [
              TextSpan(
                text: 'Sign In',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}