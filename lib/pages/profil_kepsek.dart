import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

/* =======================
   MODEL USER
======================= */
class User {
  final int id;
  final String namaguru;

  User({required this.id, required this.namaguru});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], namaguru: json['namaguru']);
  }
}

/* =======================
   PAGE PROFIL
======================= */
class ProfilKepsekPage extends StatefulWidget {
  const ProfilKepsekPage({super.key});

  @override
  State<ProfilKepsekPage> createState() => _ProfilKepsekPageState();
}

class _ProfilKepsekPageState extends State<ProfilKepsekPage> {
  static const Color _primary = Color(0xFF7048E8);

  bool _notifPengaduan = true;
  bool _notifLaporan = false;

  late Future<User> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = fetchUser();
  }

  /* =======================
     API CALL
  ======================= */
  Future<User> fetchUser() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/user/1'),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat data user');
    }
  }

  /* =======================
     UI
  ======================= */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FF),
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildSection("Pengaturan Notifikasi", [
                    _buildSwitchTile(
                      Icons.notifications,
                      "Notifikasi Pengaduan",
                      "Info pengaduan masuk",
                      _notifPengaduan,
                      (v) => setState(() => _notifPengaduan = v),
                    ),
                    _buildSwitchTile(
                      Icons.summarize,
                      "Ringkasan Harian",
                      "Statistik harian",
                      _notifLaporan,
                      (v) => setState(() => _notifLaporan = v),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* =======================
     HEADER
  ======================= */
  SliverAppBar _buildHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7048E8), Color(0xFF9775FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: FutureBuilder<User>(
                future: futureUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white);
                  } else if (snapshot.hasError) {
                    return const Text(
                      "Gagal memuat data",
                      style: TextStyle(color: Colors.white),
                    );
                  }

                  final user = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.school, size: 44, color: _primary),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.namaguru,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* =======================
     INFO CARD
  ======================= */
  Widget _buildInfoCard() {
    return FutureBuilder<User>(
      future: futureUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text("Gagal memuat biodata");
        }

        final user = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _infoRow(Icons.person, "Username", user.namaguru),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _primary, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B6B8A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: _primary),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text("Keluar"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
          );
        },
      ),
    );
  }
}
