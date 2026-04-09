import 'package:flutter/material.dart';

class DashboardKepsek extends StatelessWidget {
  const DashboardKepsek({super.key});

  static const Color _primary = Color(0xFF7048E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FF),
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
                  _buildStatGrid(),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Tren Pengaduan Bulanan"),
                  const SizedBox(height: 12),
                  _buildChart(),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Aktivitas Terbaru"),
                  const SizedBox(height: 12),
                  _buildActivityList(),
                  const SizedBox(height: 16),
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
                      const Text(
                        'Drs. Sulaiman, M.Pd',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text('Kepala Sekolah', style: TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
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
                  _headerChip(Icons.calendar_today_rounded, 'Rabu, 12 Maret 2026'),
                  const SizedBox(width: 8),
                  _headerChip(Icons.circle, 'Semester Genap'),
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
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard("Total Pengaduan", "24", Icons.report_rounded, const Color(0xFF7048E8), const Color(0xFFF3F0FF)),
        _statCard("Sedang Diproses", "10", Icons.pending_actions_rounded, const Color(0xFFEA6C00), const Color(0xFFFFF4E6)),
        _statCard("Selesai", "12", Icons.check_circle_rounded, const Color(0xFF2F9E44), const Color(0xFFE6FCF5)),
        _statCard("Prioritas Tinggi", "2", Icons.warning_amber_rounded, const Color(0xFFE03131), const Color(0xFFFFF5F5)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
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
                          decoration: BoxDecoration(color: _primary.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
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
  Widget _buildActivityList() {
    final activities = [
      {'icon': Icons.inbox_rounded, 'title': 'Pengaduan tugas terlalu banyak', 'by': 'Orang Tua Kelas 8B', 'time': '10 menit lalu', 'color': const Color(0xFFEA6C00), 'status': 'Diproses'},
      {'icon': Icons.check_circle_rounded, 'title': 'Laporan keterlambatan guru', 'by': 'Orang Tua Kelas 7A', 'time': '30 menit lalu', 'color': const Color(0xFF2F9E44), 'status': 'Selesai'},
      {'icon': Icons.inbox_rounded, 'title': 'Pengaduan fasilitas kelas rusak', 'by': 'Orang Tua Kelas 9C', 'time': '1 jam lalu', 'color': const Color(0xFF7048E8), 'status': 'Masuk'},
      {'icon': Icons.warning_amber_rounded, 'title': 'Perilaku tidak sopan siswa', 'by': 'Orang Tua Kelas 8A', 'time': '3 jam lalu', 'color': const Color(0xFFE03131), 'status': 'Mendesak'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
      ),
      child: Column(
        children: activities.asMap().entries.map((e) {
          final i = e.key;
          final a = e.value;
          final color = a['color'] as Color;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(a['icon'] as IconData, color: color, size: 20),
                ),
                title: Text(a['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Row(
                  children: [
                    Text(a['by'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                      child: Text(a['status'] as String, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 4),
                    Text(a['time'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              if (i < activities.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}