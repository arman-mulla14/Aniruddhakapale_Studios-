import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCP7iGgrYSmLaojDR4KuzQRaOhBqeaQH_4",
        appId: "1:691969489440:web:5fa2ad7aee1d25a3631a45", // We can use the web appId for quick testing, but ideally an Android appId is generated via flutterfire
        messagingSenderId: "691969489440",
        projectId: "aniruddhakapale-4e51b",
        storageBucket: "aniruddhakapale-4e51b.firebasestorage.app",
      ),
    );
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  runApp(const AKStudioAdminApp());
}

class AKStudioAdminApp extends StatelessWidget {
  const AKStudioAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AK Studio Admin',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD4AF37),
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF171717),
          elevation: 0,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
