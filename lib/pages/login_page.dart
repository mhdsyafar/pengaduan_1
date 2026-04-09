import 'package:flutter/material.dart';
import '../data/dummy_user.dart';
import 'navbar_tu.dart';
import 'navbar_kepsek.dart';
import 'navbar_guru.dart';
import 'navbar_orangtua.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    String email = emailController.text.trim();
    String password = passwordController.text;

    for (var u in user) {
      if (u['email'] == email && u['password'] == password) {
        if (!mounted) return;
        if (u['role'] == 'guru') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NavbarGuru()));
        } else if (u['role'] == 'tu') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NavbarTU()));
        } else if (u['role'] == 'kepsek') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NavbarKepsek()));
        } else if (u['role'] == 'orangtua') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NavbarOrangTua()));
        }
        return;
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email atau Password salah'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2F4AC2), Color(0xFF4C6EF5), Color(0xFF748FFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Logo area
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                    ),
                    child: const Icon(Icons.school_rounded, size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sistem Pengaduan Sekolah',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Masuk untuk melanjutkan',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 12)),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Masuk', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1C1C3A))),
                        const SizedBox(height: 4),
                        Text('Silakan login sesuai peran Anda', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        const SizedBox(height: 24),

                        // Email field
                        const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1C1C3A))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'contoh@sekolah.com',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade400, size: 20),
                            filled: true,
                            fillColor: const Color(0xFFF5F7FF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF4C6EF5), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Password field
                        const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1C1C3A))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F7FF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF4C6EF5), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onSubmitted: (_) => login(),
                        ),

                        const SizedBox(height: 28),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B5BDB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Role hints
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Akun Demo:', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        _hintRow('Guru', 'guru@gmail.com'),
                        _hintRow('Orang Tua', 'ortu@gmail.com'),
                        _hintRow('Tata Usaha', 'tu@gmail.com'),
                        _hintRow('Kepala Sekolah', 'kepsek@gmail.com'),
                        const SizedBox(height: 4),
                        const Text('Password semua: 123456', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hintRow(String role, String email) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text('$role: ', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(email, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
