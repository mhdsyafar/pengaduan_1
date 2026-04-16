import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'notification_page.dart';

class DashboardTU extends StatefulWidget {
  final Function(String screen) onNavigate;

  const DashboardTU({
    super.key,
    required this.onNavigate,
  });

  @override
  State<DashboardTU> createState() => _DashboardTUState();
}

class _DashboardTUState extends State<DashboardTU> {
  Map<String, dynamic>? userData;
  List<Pengaduan> listPengaduan = [];
  int countSiswa = 0;
  int countPetugas = 0;
  int countPengadu = 0;
  bool isLoading = true;
  int _unreadNotifCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = await ApiService.getUserData();
    final pengaduanResponse = await ApiService.getAllPengaduan();
    final siswaResponse = await ApiService.getAllSiswa();
    final usersResponse = await ApiService.getAllUsers();
    final orangtuaResponse = await ApiService.getAllOrangtua();

    List<Pengaduan> mappedAduan = [];
    if (pengaduanResponse['success'] == true) {
      mappedAduan = (pengaduanResponse['data'] as List)
          .map((item) => Pengaduan.fromJson(item))
          .toList();
    }

    int sCount = 0;
    if (siswaResponse['success'] == true) {
      sCount = (siswaResponse['data'] as List).length;
    }

    // Hitung petugas (role selain orangtua: role 1=TU, 2=Guru, 4=Kepsek)
    int pCount = 0;
    if (usersResponse['success'] == true) {
      pCount = (usersResponse['data'] as List)
          .where((u) => u['id_role'] != 3)
          .length;
    }

    // Hitung orang tua dari data orangtua
    int oCount = 0;
    if (orangtuaResponse['success'] == true) {
      // Hitung jumlah user unik (bukan jumlah record orangtua)
      final uniqueUsers = <int>{};
      for (final o in (orangtuaResponse['data'] as List)) {
        if (o['id_user'] != null) uniqueUsers.add(o['id_user']);
      }
      oCount = uniqueUsers.length;
    }

    await NotificationService.checkForUpdates();
    final unread = await NotificationService.getUnreadCount();

    if (!mounted) return;
    setState(() {
      userData = user;
      listPengaduan = mappedAduan;
      countSiswa = sCount;
      countPetugas = pCount;
      countPengadu = oCount;
      _unreadNotifCount = unread;
      isLoading = false;
    });
  }


  // ======================== HELPERS ========================
  Color _statusColor(StatusPengaduan s) {
    switch (s) {
      case StatusPengaduan.masuk: return const Color(0xFF3B5BDB);
      case StatusPengaduan.diproses: return const Color(0xFFF59F00);
      case StatusPengaduan.selesai: return const Color(0xFF2F9E44);
      case StatusPengaduan.ditolak: return const Color(0xFFE03131);
    }
  }

  String _prioritasText(Prioritas p) {
    switch (p) {
      case Prioritas.tinggi: return 'Tinggi';
      case Prioritas.sedang: return 'Sedang';
      case Prioritas.rendah: return 'Rendah';
    }
  }

  Color _prioritasColor(Prioritas p) {
    switch (p) {
      case Prioritas.tinggi: return const Color(0xFFE03131);
      case Prioritas.sedang: return const Color(0xFFF59F00);
      case Prioritas.rendah: return const Color(0xFF2F9E44);
    }
  }

  String _statusText(StatusPengaduan s) {
    switch (s) {
      case StatusPengaduan.masuk: return 'Masuk';
      case StatusPengaduan.diproses: return 'Diproses';
      case StatusPengaduan.selesai: return 'Selesai';
      case StatusPengaduan.ditolak: return 'Ditolak';
    }
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

    final namaLengkap = userData?['nama_lengkap'] ?? userData?['username'] ?? "Tata Usaha";

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F4AC2), Color(0xFF4C6EF5), Color(0xFF748FFC)],
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
                      Text('$greeting,', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(
                        namaLengkap,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Text('Petugas Tata Usaha', style: TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
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
                              child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
                            ),
                            if (_unreadNotifCount > 0)
                              Positioned(
                                right: 0, top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Color(0xFFE03131), shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  child: Text(
                                    '$_unreadNotifCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.shield_rounded, size: 30, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    const Text('Sistem Pengaduan Sekolah', style: TextStyle(color: Colors.white, fontSize: 13)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('AKTIF', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================== STAT CARDS ========================
  Widget _buildStatCards(int pPetugas, int pSiswa, int pPengadu, int pPengaduan, int pTinggi) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard('Siswa', pSiswa, Icons.school_rounded, const Color(0xFF3B5BDB), const Color(0xFFEDF2FF), () => widget.onNavigate('siswa')),
        _statCard('Orang Tua', pPengadu, Icons.people_rounded, const Color(0xFF0CA678), const Color(0xFFE6FCF5), () => widget.onNavigate('pengadu')),
        _statCard('Petugas', pPetugas, Icons.badge_rounded, const Color(0xFF6366F1), const Color(0xFFEEF2FF), () => widget.onNavigate('petugas')),
        _statCard('Pengaduan', pPengaduan, Icons.inbox_rounded, const Color(0xFFEA6C00), const Color(0xFFFFF4E6), () => widget.onNavigate('pengaduan')),
      ],
    );
  }


  Widget _statCard(String label, int value, IconData icon, Color color, Color bg, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.12)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 18),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color.withValues(alpha: 0.6)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value.toString(), style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ======================== STATUS BAR ========================
  Widget _buildStatusBar(int masuk, int diproses, int selesai, int ditolak) {
    final total = masuk + diproses + selesai + ditolak;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Pengaduan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (total > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  _progressBar(masuk, total, const Color(0xFF3B5BDB)),
                  _progressBar(diproses, total, const Color(0xFFF59F00)),
                  _progressBar(selesai, total, const Color(0xFF2F9E44)),
                  _progressBar(ditolak, total, const Color(0xFFE03131)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusChip('Masuk', masuk, const Color(0xFF3B5BDB)),
              _statusChip('Diproses', diproses, const Color(0xFFF59F00)),
              _statusChip('Selesai', selesai, const Color(0xFF2F9E44)),
              _statusChip('Ditolak', ditolak, const Color(0xFFE03131)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressBar(int value, int total, Color color) {
    if (total == 0 || value == 0) return const SizedBox();
    return Flexible(
      flex: value,
      child: Container(height: 8, color: color),
    );
  }

  Widget _statusChip(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Center(child: Text(value.toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  // ======================== RINGKASAN ========================
  Widget _buildRingkasan(int aktif, int total, int menunggu, int selesai, int totalPengaduan) {
    final persen = totalPengaduan > 0 ? (selesai / totalPengaduan * 100).toInt() : 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Kinerja', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _ringkasanRow('Petugas Aktif', '$aktif / $total petugas', Icons.badge_rounded, const Color(0xFF3B5BDB)),
          const Divider(height: 16),
          _ringkasanRow('Menunggu Tindak Lanjut', '$menunggu pengaduan', Icons.pending_actions_rounded, const Color(0xFFF59F00)),
          const Divider(height: 16),
          _ringkasanRow('Tingkat Penyelesaian', '$persen%', Icons.check_circle_rounded, const Color(0xFF2F9E44)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: persen / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(persen >= 70 ? const Color(0xFF2F9E44) : const Color(0xFFF59F00)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ringkasanRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ======================== PENGADUAN TERBARU ========================
  Widget _buildPengaduanTerbaru(List<Pengaduan> list) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pengaduan Terbaru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => widget.onNavigate('pengaduan'),
                  child: const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Belum ada pengaduan', style: TextStyle(color: Colors.grey))),
            )
          else
            ...list.asMap().entries.map((e) {
              final i = e.key;
              final p = e.value;
              return Column(
                children: [
                  ListTile(
                    dense: true,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _statusColor(p.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.inbox_rounded, color: _statusColor(p.status), size: 20),
                    ),
                    title: Text(p.judul, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('${p.namaPengadu} · ${p.tanggal.substring(0, 10)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor(p.status).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_statusText(p.status), style: TextStyle(color: _statusColor(p.status), fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _prioritasColor(p.prioritas).withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_prioritasText(p.prioritas), style: TextStyle(color: _prioritasColor(p.prioritas), fontSize: 9)),
                        ),
                      ],
                    ),
                  ),
                  if (i < list.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ======================== BUILD ========================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F2FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    try {
      final prioritasTinggi = listPengaduan.where((e) => e.prioritas == Prioritas.tinggi).length;
      final masuk = listPengaduan.where((e) => e.status == StatusPengaduan.masuk).length;
      final diproses = listPengaduan.where((e) => e.status == StatusPengaduan.diproses).length;
      final selesai = listPengaduan.where((e) => e.status == StatusPengaduan.selesai).length;
      final ditolak = listPengaduan.where((e) => e.status == StatusPengaduan.ditolak).length;

      // Menggunakan data real dari database

      return Scaffold(
        backgroundColor: const Color(0xFFF0F2FF),
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
                    children: [
                      const SizedBox(height: 4),
                      _buildStatCards(countPetugas, countSiswa, countPengadu, listPengaduan.length, prioritasTinggi),
                      const SizedBox(height: 16),
                      _buildStatusBar(masuk, diproses, selesai, ditolak),
                      const SizedBox(height: 16),
                      _buildRingkasan(countPetugas, countPetugas, masuk, selesai, listPengaduan.length),
                      const SizedBox(height: 16),
                      _buildPengaduanTerbaru(listPengaduan.take(5).toList()),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return Scaffold(
        body: Center(child: Text("Error: $e")),
      );
    }
  }
}
