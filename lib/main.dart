import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/profile_orangtua.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Pengaduan Siswa',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0FDFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D9488),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const LoginPage(),
      routes: {
        '/profile': (context) => const ProfileOrangTua(),
      },
    );
  }
}

