import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class DashboardKepsek extends StatefulWidget {
  const DashboardKepsek({super.key});

  @override
  State<DashboardKepsek> createState() => _DashboardKepsekState();
}

class _DashboardKepsekState extends State<DashboardKepsek> {
  static const Color _primary = Color(0xFF7048E8);

  Map<String, dynamic>? userData;
  List<Pengaduan> listPengaduan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
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

    setState(() {
      userData = user;
      listPengaduan = mappedAduan;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F4FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final total = listPengaduan.length;
    final diproses = listPengaduan.where((e) => e.status == StatusPengaduan.diproses).length;
    final selesai = listPengaduan.where((e) => e.status == StatusPengaduan.selesai).length;
    // Dummy counting prioritias tinggi since prioritizing logic needs backend adjustments:
    final tinggi = listPengaduan.where((e) => e.prioritas == Prioritas.tinggi).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FF),
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
                    _buildStatGrid(total, diproses, selesai, tinggi),
                    const SizedBox(height: 20),
                    _buildSectionTitle("Tren Pengaduan Bulanan"),
                    const SizedBox(height: 12),
                    _buildChart(),
                    const SizedBox(height: 20),
                    _buildSectionTitle("Aktivitas Terbaru"),
                    const SizedBox(height: 12),
                    _buildActivityList(listPengaduan.take(5).toList()),
                    const SizedBox(height: 16),
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

    final String namaLengkap = userData?['nama_lengkap'] ?? userData?['username'] ?? "Kepala Sekolah";

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5E35B1), Color(0xFF7048E8), Color(0xFF9775FA)],
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
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text('Kepala Sekolah', style: TextStyle(color: Colors.white60, fontSize: 13)),
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
                      child: Icon(Icons.school_rounded, size: 30, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _headerChip(Icons.calendar_today_rounded, '${now.day}/${now.month}/${now.year}'),
                  const SizedBox(width: 8),
                  _headerChip(Icons.circle, 'Semester Saat Ini'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  // ======================== STAT GRID ========================
  Widget _buildStatGrid(int total, int diproses, int selesai, int tinggi) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard("Total Pengaduan", total.toString(), Icons.report_rounded, const Color(0xFF7048E8), const Color(0xFFF3F0FF)),
        _statCard("Sedang Diproses", diproses.toString(), Icons.pending_actions_rounded, const Color(0xFFEA6C00), const Color(0xFFFFF4E6)),
        _statCard("Selesai", selesai.toString(), Icons.check_circle_rounded, const Color(0xFF2F9E44), const Color(0xFFE6FCF5)),
        _statCard("Prioritas Tinggi", tinggi.toString(), Icons.warning_amber_rounded, const Color(0xFFE03131), const Color(0xFFFFF5F5)),
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

  // ======================== SECTION TITLE ========================
  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C3A)));
  }

  // ======================== DIY CHART ========================
  Widget _buildChart() {
    // Keep dummy data for chart as the backend doesn't aggregate yet
    final data = [
      {'label': 'Jan', 'value': 8, 'done': 6},
      {'label': 'Feb', 'value': 12, 'done': 10},
      {'label': 'Mar', 'value': 7, 'done': 4},
      {'label': 'Apr', 'value': 15, 'done': 12},
      {'label': 'Mei', 'value': 10, 'done': 7},
      {'label': 'Jun', 'value': 9, 'done': 8},
    ];
    const maxVal = 15.0;

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
              _legendDot(_primary, 'Total'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFF2F9E44), 'Selesai'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120, // INCREASED TO FIX OVERFLOW
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.map((d) {
                final val = d['value'] as int;
                final done = d['done'] as int;
                final totalH = (val / maxVal * 90).toDouble();
                final doneH = (done / maxVal * 90).toDouble();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 12, height: totalH,
                          decoration: BoxDecoration(color: _primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(width: 2),
                        Container(
                          width: 12, height: doneH,
                          decoration: BoxDecoration(color: const Color(0xFF2F9E44), borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(d['label'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  // ======================== ACTIVITY LIST ========================
  Widget _buildActivityList(List<Pengaduan> list) {
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
        ),
        child: const Center(
          child: Text('Belum ada laporan terbaru', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

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
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.inbox_rounded, color: color, size: 20),
                ),
                title: Text(p.judul, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Row(
                  children: [
                    Text("Oleh: ${p.namaPengadu} • ${p.kategori}", style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
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
                    Text(p.tanggal.substring(0, 10), style: const TextStyle(fontSize: 10, color: Colors.grey)),
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