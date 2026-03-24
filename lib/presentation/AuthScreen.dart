import 'package:flutter/material.dart';
import 'package:assignment/data/services/auth_service.dart';
import 'package:assignment/presentation/widgets/neumorphic_container.dart';
import '../data/services/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    if (_identifierController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (AuthMode.isLogin) {
        await _authService.signInWithEmail(_identifierController.text, _passwordController.text);
      } else {
        await _authService.signUpWithEmail(_identifierController.text, _passwordController.text);
      }
      // AuthGate in main.dart will automatically redirect now
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text(AuthMode.isLogin ? "Welcome Back" : "Create Account",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 30),

            // Neumorphic Input Fields
            _buildInput(_identifierController, "Email", Icons.email_outlined),
            const SizedBox(height: 20),
            _buildInput(_passwordController, "Password", Icons.lock_outline, isPass: true),

            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 40),
            _buildSocialRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, IconData icon, {bool isPass = false}) {
    return NeumorphicContainer(
      // We can add a custom 'isPressed' boolean to our widget if we want inner shadows
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: Text(AuthMode.isLogin ? "Sign In" : "Register", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSocialRow() {
    return Row(
      children: [
        Expanded(child: NeumorphicContainer(child: IconButton(onPressed: () {}, icon: const Icon(Icons.g_mobiledata, size: 40)))),
        const SizedBox(width: 20),
        Expanded(child: NeumorphicContainer(child: IconButton(onPressed: () {}, icon: const Icon(Icons.apple, size: 40)))),
      ],
    );
  }
}