import 'package:flutter/material.dart';
import 'package:assignment/data/models/onboarding_model.dart';
import 'package:assignment/presentation/widgets/neumorphic_container.dart';
import 'package:assignment/presentation/AuthScreen.dart';
import '../data/services/auth_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingModel> _data = OnboardingModel.list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (v) => setState(() => _currentPage = v),
                itemCount: _data.length,
                itemBuilder: (context, i) => _buildPage(i),
              ),
            ),
            _buildDots(),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    return Column(
      children: [
        // Reusing the NeumorphicContainer for consistent 3D look
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: NeumorphicContainer(
              borderRadius: 40,
              child: Center(
                child: Icon(_data[index].icon, size: 160, color: Colors.black87),
              ),
            ),
          ),
        ),
        _buildTextSection(index),
      ],
    );
  }

  Widget _buildTextSection(int index) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            Text(
              _data[index].title,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 15),
            Text(
              _data[index].description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    bool isLastPage = _currentPage == _data.length - 1;
    return Padding(
      padding: const EdgeInsets.all(30),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            if (isLastPage) {
              AuthMode.isLogin = false;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
            } else {
              _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
          child: Text(isLastPage ? "Get Started" : "Next", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_data.length, (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 8),
        height: 8,
        width: _currentPage == index ? 24 : 8,
        decoration: BoxDecoration(
          color: _currentPage == index ? Colors.black : Colors.grey[400],
          borderRadius: BorderRadius.circular(4),
        ),
      )),
    );
  }
}