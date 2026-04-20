import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'login_page.dart';
import 'help_support_page.dart';
import 'dart:io';
import '../services/profile_image_service.dart';

class ProfilTUPage extends StatefulWidget {
  const ProfilTUPage({super.key});

  @override
  State<ProfilTUPage> createState() => _ProfilTUPageState();
}

class _ProfilTUPageState extends State<ProfilTUPage> {
  static const Color _primary = Color(0xFF6366F1); // Indigo
  Map<String, dynamic>? _userData;
  File? _profileImage;
  bool _isLoading = true;
  bool _notifStatus = true;
  bool _notifEmail = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
    if (mounted) setState(() => _notifStatus = enabled);
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getMe();
    if (response['success'] == true) {
      setState(() {
        _userData = response['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal mengambil data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = _userData ?? {};
    final nama = user['nama_lengkap'] ?? 'Petugas TU';
    final email = user['email'] ?? 'Tidak ada email';
    final noHp = user['no_hp'] ?? '-';
    final username = user['username'] ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: RefreshIndicator(
        onRefresh: _fetchUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context, nama),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoCard(email, noHp, username),
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
        ),
      ),
    );
  }

  // ======================== HEADER ========================
  Widget _buildHeader(BuildContext context, String namaLengkap) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4338CA), Color(0xFF6366F1), Color(0xFF818CF8)],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text('Profil Petugas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => _showEditProfileDialog(),
                    icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
                    tooltip: 'Edit Profil',
                  )
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showProfileImageOptions,
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3)),
                  child: CircleAvatar(
                    radius: 40, 
                    backgroundColor: Colors.white24, 
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null ? const Icon(Icons.admin_panel_settings_rounded, size: 40, color: Colors.white) : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Administrator TU / Staf Admin', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(namaLengkap, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
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
  Widget _buildInfoCard(String email, String noHp, String username) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        children: [
          _infoRow(Icons.person_outline_rounded, 'Username', username),
          const Divider(height: 24),
          _infoRow(Icons.email_rounded, 'Email', email),
          const Divider(height: 24),
          _infoRow(Icons.phone_rounded, 'Nomor Telepon', noHp),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: _primary, size: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          ]),
        ),
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
            title: const Text('Notifikasi Pengaduan Baru', style: TextStyle(fontSize: 14)),
            value: _notifStatus,
            onChanged: (v) async {
              setState(() => _notifStatus = v);
              await NotificationService.setEnabled(v);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            activeThumbColor: _primary,
            title: const Text('Pengingat Review Harian', style: TextStyle(fontSize: 14)),
            value: _notifEmail,
            onChanged: (v) => setState(() => _notifEmail = v),
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
          ListTile(
            leading: const Icon(Icons.lock_rounded, color: Colors.grey),
            title: const Text('Ubah Password', style: TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            onTap: () => _showChangePasswordDialog(),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded, color: Colors.grey),
            title: const Text('Pusat Bantuan & FAQ', style: TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage()));
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded, color: Colors.grey),
            title: Text('Tentang Aplikasi', style: TextStyle(fontSize: 14)),
            subtitle: Text('Versi 2.1.0', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ======================== DIALOGS ========================
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userData?['nama_lengkap']);
    final emailController = TextEditingController(text: _userData?['email']);
    final phoneController = TextEditingController(text: _userData?['no_hp']);

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
              if (result['success']) _fetchUserData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPass, obscureText: true, decoration: const InputDecoration(labelText: 'Password Lama')),
            TextField(controller: newPass, obscureText: true, decoration: const InputDecoration(labelText: 'Password Baru')),
            TextField(controller: confirmPass, obscureText: true, decoration: const InputDecoration(labelText: 'Konfirmasi Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (newPass.text != confirmPass.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfirmasi password tidak cocok')));
                return;
              }
              final result = await ApiService.changePassword(oldPass.text, newPass.text);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primary),
            child: const Text('Ubah', style: TextStyle(color: Colors.white)),
          ),
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