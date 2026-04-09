import 'package:flutter/material.dart';
import 'pengaduan_page.dart';

class Pengaduan {
  final String judul;
  final String kategori;
  final String tanggal;
  final String status;

  Pengaduan({
    required this.judul,
    required this.kategori,
    required this.tanggal,
    required this.status,
  });
}

class DashboardOrangTua extends StatelessWidget {
  final VoidCallback? onAddTap;
  const DashboardOrangTua({super.key, this.onAddTap});

  static const Color _primary = Color(0xFF2F4AC2);

  @override
  Widget build(BuildContext context) {
    const String namaOrtu = "Ahmad Hidayat";
    const String kelasAnak = "5A";

    final List<Pengaduan> listPengaduan = [
      Pengaduan(judul: "AC Kelas Tidak Berfungsi", kategori: "Fasilitas", tanggal: "5 Feb 2026", status: "diproses"),
      Pengaduan(judul: "Perundungan di Kelas", kategori: "Kedisiplinan", tanggal: "4 Feb 2026", status: "menunggu"),
      Pengaduan(judul: "Lampu Mati", kategori: "Fasilitas", tanggal: "2 Feb 2026", status: "selesai"),
      Pengaduan(judul: "Kipas Rusak", kategori: "Fasilitas", tanggal: "1 Feb 2026", status: "selesai"),
      Pengaduan(judul: "Toilet Kotor", kategori: "Kebersihan", tanggal: "30 Jan 2026", status: "diproses"),
    ];

    final total = listPengaduan.length;
    final menunggu = listPengaduan.where((e) => e.status == "menunggu").length;
    final diproses = listPengaduan.where((e) => e.status == "diproses").length;
    final selesai = listPengaduan.where((e) => e.status == "selesai").length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, namaOrtu, kelasAnak),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _buildStatGrid(menunggu, diproses, selesai),
                  const SizedBox(height: 20),
                  _buildTotalBar(total, selesai),
                  const SizedBox(height: 24),
                  const Text('Laporan Anda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C3A))),
                  const SizedBox(height: 12),
                  _buildList(listPengaduan.take(3).toList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================== HEADER ========================
  Widget _buildHeader(BuildContext context, String namaOrtu, String kelasAnak) {
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
                        namaOrtu,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text('Wali Murid • Kelas $kelasAnak', style: const TextStyle(color: Colors.white60, fontSize: 13)),
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
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (onAddTap != null) {
                    onAddTap!();
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PengaduanPage()));
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text('Buat Pengaduan Baru', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================== STAT GRID ========================
  Widget _buildStatGrid(int menunggu, int diproses, int selesai) {
    return Row(
      children: [
        Expanded(child: _statCard("Menunggu", menunggu.toString(), Icons.access_time_rounded, const Color(0xFFEA6C00), const Color(0xFFFFF4E6))),
        const SizedBox(width: 12),
        Expanded(child: _statCard("Diproses", diproses.toString(), Icons.sync_rounded, const Color(0xFF3B5BDB), const Color(0xFFEDF2FF))),
        const SizedBox(width: 12),
        Expanded(child: _statCard("Selesai", selesai.toString(), Icons.check_circle_rounded, const Color(0xFF2F9E44), const Color(0xFFEBFBEE))),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ======================== TOTAL BAR ========================
  Widget _buildTotalBar(int total, int selesai) {
    final persen = total > 0 ? (selesai / total * 100).toInt() : 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: _primary, size: 20),
              const SizedBox(width: 8),
              const Text("Total Pengaduan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(total.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: persen / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(persen >= 100 ? const Color(0xFF2F9E44) : _primary),
            ),
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
            color = const Color(0xFFEA6C00);
            label = "Menunggu";
          }
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.description_rounded, color: color, size: 20),
                ),
                title: Text(p.judul, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(p.kategori, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
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
