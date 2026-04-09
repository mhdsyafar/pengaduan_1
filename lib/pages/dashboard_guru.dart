import 'package:flutter/material.dart';

class Pengaduan {
  final String nama;
  final String kategori;
  final String deskripsi;
  final String tanggal;
  final String status;

  Pengaduan({
    required this.nama,
    required this.kategori,
    required this.deskripsi,
    required this.tanggal,
    required this.status,
  });
}

class DashboardGuru extends StatelessWidget {
  const DashboardGuru({super.key});

  static const Color _primary = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    final List<Pengaduan> pengaduanList = [
      Pengaduan(
        nama: "Ahmad",
        kategori: "Bullying",
        deskripsi: "Terjadi perundungan di kelas",
        tanggal: "05 Feb 2026",
        status: "baru",
      ),
      Pengaduan(
        nama: "Siti",
        kategori: "Fasilitas",
        deskripsi: "Kipas angin rusak",
        tanggal: "04 Feb 2026",
        status: "diproses",
      ),
      Pengaduan(
        nama: "Budi",
        kategori: "Akademik",
        deskripsi: "Metode pembelajaran kurang dipahami",
        tanggal: "03 Feb 2026",
        status: "selesai",
      ),
    ];

    final total = pengaduanList.length;
    final baru = pengaduanList.where((e) => e.status == "baru").length;
    final diproses = pengaduanList.where((e) => e.status == "diproses").length;
    final selesai = pengaduanList.where((e) => e.status == "selesai").length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _buildStatGrid(total, baru, diproses, selesai),
                  const SizedBox(height: 24),
                  const Text('Tugas Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C3A))),
                  const SizedBox(height: 12),
                  _buildList(pengaduanList),
                ],
              ),
            ),
          ],
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
                      Text('$greeting,', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 2),
                      const Text(
                        'Guru Pengajar',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Text('Wali Kelas 10A', style: TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person_rounded, size: 30, color: Colors.white),
                    ),
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
  Widget _buildStatGrid(int total, int baru, int diproses, int selesai) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard("Total Kasus", total.toString(), Icons.folder_rounded, const Color(0xFF0D9488), const Color(0xFFF0FDFA)),
        _statCard("Laporan Baru", baru.toString(), Icons.warning_amber_rounded, const Color(0xFFE03131), const Color(0xFFFFF5F5)),
        _statCard("Sedang Diproses", diproses.toString(), Icons.pending_actions_rounded, const Color(0xFFF59F00), const Color(0xFFFFF9DB)),
        _statCard("Penyelesaian", selesai.toString(), Icons.check_circle_rounded, const Color(0xFF2F9E44), const Color(0xFFEBFBEE)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  // ======================== LIST ========================
  Widget _buildList(List<Pengaduan> list) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
      ),
      child: Column(
        children: list.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          Color color;
          String label;
          if (p.status == "diproses") {
            color = const Color(0xFF3B5BDB);
            label = "Diproses";
          } else if (p.status == "selesai") {
            color = const Color(0xFF2F9E44);
            label = "Selesai";
          } else {
            color = const Color(0xFFE03131);
            label = "Baru";
          }
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.description_rounded, color: color, size: 20),
                ),
                title: Text(p.deskripsi, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${p.nama} • ${p.kategori}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 4),
                    Text(p.tanggal, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              if (i < list.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
