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
      home: const LoginPage(),
      routes: {
        '/profile': (context) => const ProfileOrangTua(),
      },
    );
  }
}

