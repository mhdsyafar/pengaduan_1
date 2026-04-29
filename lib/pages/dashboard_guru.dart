import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/models.dart';
import 'notification_page.dart';
import 'pengaduan_list.dart';
import 'dart:io';
import '../services/profile_image_service.dart';

class DashboardGuru extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const DashboardGuru({super.key, this.onProfileTap});

  @override
  State<DashboardGuru> createState() => _DashboardGuruState();
}

class _DashboardGuruState extends State<DashboardGuru> {
  Map<String, dynamic>? userData;
  List<Pengaduan> listPengaduan = [];
  File? _profileImage;
  bool isLoading = true;
  int _unreadNotifCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final img = await ProfileImageService.loadProfileImage();
    if (mounted) setState(() => _profileImage = img);
  }

  Future<void> _fetchData() async {
    final user = await ApiService.getUserData();
    final pengaduanResponse = await ApiService.getAllPengaduan();

    List<Pengaduan> mappedAduan = [];
    if (pengaduanResponse['success'] == true) {
      mappedAduan = (pengaduanResponse['data'] as List)
          .map((item) => Pengaduan.fromJson(item))
          .toList();
    }

    await NotificationService.checkForUpdates();
    final unread = await NotificationService.getUnreadCount();

    if (!mounted) return;
    setState(() {
      userData = user;
      listPengaduan = mappedAduan;
      _unreadNotifCount = unread;
      isLoading = false;
    });
    _loadProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0FDFA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final total = listPengaduan.length;
    final baru = listPengaduan
        .where((e) => e.status == StatusPengaduan.masuk)
        .length;
    final diproses = listPengaduan
        .where((e) => e.status == StatusPengaduan.diproses)
        .length;
    final selesai = listPengaduan
        .where((e) => e.status == StatusPengaduan.selesai)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _buildStatGrid(context, total, baru, diproses, selesai),
                    const SizedBox(height: 24),
                    const Text(
                      'Tugas Terbaru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C3A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildList(listPengaduan.take(5).toList()),
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
  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 11) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    final String namaLengkap =
        userData?['nama_lengkap'] ?? userData?['username'] ?? "Guru Pengajar";

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        namaLengkap,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Guru Pengajar',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationPage(),
                            ),
                          );
                          _fetchData();
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            if (_unreadNotifCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE03131),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    '$_unreadNotifCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: widget.onProfileTap,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white24,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 30,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================== STAT GRID ========================
  Widget _buildStatGrid(
    BuildContext context,
    int total,
    int baru,
    int diproses,
    int selesai,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard(
          "Total Kasus",
          total.toString(),
          Icons.folder_rounded,
          const Color(0xFF0D9488),
          const Color(0xFFF0FDFA),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PengaduanPage(initialFilter: "semua"),
              ),
            );
          },
        ),
        _statCard(
          "Laporan Baru",
          baru.toString(),
          Icons.warning_amber_rounded,
          const Color(0xFFE03131),
          const Color(0xFFFFF5F5),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PengaduanPage(initialFilter: "baru"),
              ),
            );
          },
        ),
        _statCard(
          "Sedang Diproses",
          diproses.toString(),
          Icons.pending_actions_rounded,
          const Color(0xFFF59F00),
          const Color(0xFFFFF9DB),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PengaduanPage(initialFilter: "diproses"),
              ),
            );
          },
        ),
        _statCard(
          "Penyelesaian",
          selesai.toString(),
          Icons.check_circle_rounded,
          const Color(0xFF2F9E44),
          const Color(0xFFEBFBEE),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PengaduanPage(initialFilter: "selesai"),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ======================== LIST ========================
  Widget _buildList(List<Pengaduan> list) {
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Belum ada laporan terbaru',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: list.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          Color color;
          String label;
          if (p.status == StatusPengaduan.diproses) {
            color = const Color(0xFF3B5BDB);
            label = "Diproses";
          } else if (p.status == StatusPengaduan.selesai) {
            color = const Color(0xFF2F9E44);
            label = "Selesai";
          } else if (p.status == StatusPengaduan.ditolak) {
            color = const Color(0xFFE03131);
            label = "Ditolak";
          } else {
            color = const Color(0xFFEA6C00);
            label = "Baru";
          }
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                title: Text(
                  p.judul,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${p.namaPengadu} • ${p.kategori}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.tanggal.substring(0, 10),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (i < list.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
