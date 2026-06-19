import 'package:belajarin_aja_yuk/pages/kuis/kuis_page.dart';
import 'package:belajarin_aja_yuk/pages/materi/input_materi_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'pages/auth/splash_page.dart';
import 'pages/navigation/main_navigation.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/chatbot/chatbot_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Belajarin Aja Yuk!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MainNavigation(),
        '/chat': (context) => const ChatbotPage(),
        '/input-materi': (context) => const InputMateriPage(),
        '/kuis': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final soalKuis = args['soalKuis'] as List<Map<String, dynamic>>;
          final materiId = args['materiId'] as String;

          return KuisPage(
            soalKuis: soalKuis,
            materiId: materiId,
          );
        },
      },
    );
  }
}
