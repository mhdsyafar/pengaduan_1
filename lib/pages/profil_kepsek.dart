import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'login_page.dart';
import 'dart:io';
import '../services/profile_image_service.dart';

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
  File? _profileImage;

  late Future<Map<String, dynamic>?> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = ApiService.getUserData();
    _loadNotifSetting();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final image = await ProfileImageService.loadProfileImage();
    if (mounted) setState(() => _profileImage = image);
  }

  Future<void> _changeProfileImage() async {
    final image = await ProfileImageService.pickAndSaveImage();
    if (image != null && mounted) {
      setState(() => _profileImage = image);
    }
  }

  Future<void> _removeProfileImage() async {
    await ProfileImageService.removeProfileImage();
    if (mounted) setState(() => _profileImage = null);
  }

  void _showProfileImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih Foto Baru'),
              onTap: () {
                Navigator.pop(context);
                _changeProfileImage();
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadNotifSetting() async {
    final enabled = await NotificationService.isEnabled();
    if (mounted) setState(() => _notifPengaduan = enabled);
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
                      (v) async {
                        setState(() => _notifPengaduan = v);
                        await NotificationService.setEnabled(v);
                      },
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
      actions: [
        IconButton(
          onPressed: () {
            futureUser.then((user) {
              if (user != null) _showEditProfileDialog(user);
            });
          },
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
          tooltip: 'Edit Profil',
        )
      ],
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
              child: FutureBuilder<Map<String, dynamic>?>(
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

                  final user = snapshot.data ?? {};
                  final nama = user['nama_lengkap'] ?? user['username'] ?? 'Kepala Sekolah';
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _showProfileImageOptions,
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null ? const Icon(Icons.school, size: 44, color: _primary) : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        nama,
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
    return FutureBuilder<Map<String, dynamic>?>(
      future: futureUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text("Gagal memuat biodata");
        }

        final user = snapshot.data ?? {};
        final nama = user['nama_lengkap'] ?? user['username'] ?? 'Kepala Sekolah';
        final email = user['email'] ?? 'Tidak ada email';
        final phone = user['no_hp'] ?? '-';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _infoRow(Icons.person, "Nama Lengkap", nama),
              const Divider(height: 24),
              _infoRow(Icons.email, "Email", email),
              const Divider(height: 24),
              _infoRow(Icons.phone, "Nomor Telepon", phone),
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

  void _showEditProfileDialog(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['nama_lengkap']);
    final emailController = TextEditingController(text: user['email']);
    final phoneController = TextEditingController(text: user['no_hp']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Nomor Telepon')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final result = await ApiService.updateMyProfile({
                'nama_lengkap': nameController.text,
                'email': emailController.text,
                'no_hp': phoneController.text,
              });
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? (result['success'] ? 'Berhasil' : 'Gagal'))));
              if (result['success']) {
                setState(() {
                  futureUser = ApiService.getUserData();
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
        onPressed: () async {
          await ApiService.logout();
          if (!mounted) return;
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
