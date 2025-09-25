import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:autour_web/screens/home_screen.dart';
import 'package:autour_web/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register video element view factory for webcam
  ui_web.platformViewRegistry.registerViewFactory(
    'webcam-video',
    (int viewId) {
      final videoElement = html.VideoElement()
        ..id = 'webcam-video'
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';
      return videoElement;
    },
  );

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyB1nzEhW1GCS544Sa5UDNLtSojSjSc4__s",
          authDomain: "autour-b3ded.firebaseapp.com",
          projectId: "autour-b3ded",
          storageBucket: "autour-b3ded.firebasestorage.app",
          messagingSenderId: "466685065267",
          appId: "1:466685065267:web:b6b1bde6fcfbc02a82cb46"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuTour',
      // home: LoginScreen(),
      home: HomeScreen(accountType: 'Super Admin'),
    );
  }
}
