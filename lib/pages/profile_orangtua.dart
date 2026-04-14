import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class ProfileOrangTua extends StatelessWidget {
  const ProfileOrangTua({super.key});

  static const Color _primary = Color(0xFF2F4AC2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: ApiService.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data ?? {};
          final nama = user['nama_lengkap'] ?? user['username'] ?? 'Orang Tua / Wali';
          final email = user['email'] ?? 'Tidak ada email';
          final kelas = user['kelas'];

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, nama),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoCard(email, kelas),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Pengaturan Notifikasi'),
                      const SizedBox(height: 12),
                      _buildSettingsCard(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Akun'),
                      const SizedBox(height: 12),
                      _buildAccountCard(context),
                      const SizedBox(height: 30),
                      _buildLogoutButton(context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  // ======================== HEADER ========================
  Widget _buildHeader(BuildContext context, String namaLengkap) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF283F9E), Color(0xFF2F4AC2), Color(0xFF5C73DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            children: [
              const Text('Profil Saya', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3)),
                child: const CircleAvatar(radius: 40, backgroundColor: Colors.white24, child: Icon(Icons.person_rounded, size: 40, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Text(namaLengkap, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Orang Tua / Wali Murid', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  // ======================== TITLE ========================
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C3A))),
    );
  }

  // ======================== CARDS ========================
  Widget _buildInfoCard(String email, String? kelas) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        children: [
          _infoRow(Icons.email_rounded, 'Email', email),
          const Divider(height: 24),
          _infoRow(Icons.phone_rounded, 'Nomor Telepon', '-'),
          const Divider(height: 24),
          _infoRow(Icons.class_rounded, 'Kelas Anak', kelas ?? 'Tidak ditugaskan'),
          const Divider(height: 24),
          _infoRow(Icons.child_care_rounded, 'Nama Anak', 'Tidak ada data'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: _primary, size: 18)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        children: [
          SwitchListTile(
            activeThumbColor: _primary,
            title: const Text('Notifikasi Status Pengaduan', style: TextStyle(fontSize: 14)),
            value: true,
            onChanged: (v) {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            activeThumbColor: _primary,
            title: const Text('Notifikasi SMS', style: TextStyle(fontSize: 14)),
            value: false,
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        children: [
          ListTile(leading: const Icon(Icons.lock_rounded, color: Colors.grey), title: const Text('Ubah Password', style: TextStyle(fontSize: 14)), trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey), onTap: () {}),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(leading: const Icon(Icons.help_outline_rounded, color: Colors.grey), title: const Text('Pusat Bantuan', style: TextStyle(fontSize: 14)), trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey), onTap: () {}),
        ],
      ),
    );
  }

  // ======================== LOGOUT ========================
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE03131).withValues(alpha: 0.1),
          foregroundColor: const Color(0xFFE03131),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: () async {
          await ApiService.logout();
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
        },
        child: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}