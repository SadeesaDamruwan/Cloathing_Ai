import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'package:assignment/data/services/database_service.dart';
import 'package:assignment/presentation/auth/auth_screen.dart';
import 'package:assignment/presentation/setup/setup_profile_screen.dart';
import 'package:assignment/presentation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Avenir',
        scaffoldBackgroundColor: const Color(0xFFE0E5EC),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScaffold();
        }

        if (!authSnapshot.hasData) {
          return const AuthScreen();
        }

        return FutureBuilder<bool>(
          future: dbService.isProfileSetupComplete(authSnapshot.data!.uid),
          builder: (context, setupSnapshot) {
            if (setupSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScaffold();
            }

            if (setupSnapshot.data == true) {
              return const MainNavigation();
            } else {
              return const SetupProfileScreen();
            }
          },
        );
      },
    );
  }
}

class LoadingScaffold extends StatelessWidget {
  const LoadingScaffold({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFE0E5EC),
      body: Center(child: CircularProgressIndicator(color: Colors.black)),
    );
  }
}