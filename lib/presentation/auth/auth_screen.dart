import 'package:flutter/material.dart';
import 'package:assignment/data/services/auth_service.dart';
import 'package:assignment/presentation/widgets/neumorphic_container.dart';
import 'package:assignment/data/services/auth_state.dart'; // Make sure this path is correct!

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (AuthMode.isLogin) {
        await _authService.signInWithEmail(_emailController.text, _passController.text);
      } else {
        await _authService.signUpWithEmail(_emailController.text, _passController.text);
      }
      // Success! AuthGate in main.dart will automatically detect the login and navigate.
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                  AuthMode.isLogin ? "Welcome Back" : "Create Account",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)
              ),
              const SizedBox(height: 40),

              // Email Input
              NeumorphicContainer(
                isInner: true,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      hintText: "Email",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.email_outlined),
                      contentPadding: EdgeInsets.symmetric(vertical: 20)
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Input
              NeumorphicContainer(
                isInner: true,
                child: TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      hintText: "Password",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.lock_outline),
                      contentPadding: EdgeInsets.symmetric(vertical: 20)
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  child: Text(
                      AuthMode.isLogin ? "Sign In" : "Register",
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Google Sign In (Optional extra touch)
              GestureDetector(
                onTap: () async {
                  setState(() => _isLoading = true);
                  try {
                    await _authService.signInWithGoogle();
                  } catch (e) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Error: $e")));
                  }
                },
                child: const NeumorphicContainer(
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata, size: 40),
                        Text("Continue with Google", style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}