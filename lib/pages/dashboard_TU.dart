import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

class DashboardTU extends StatelessWidget {
  final List<Petugas> petugas;
  final List<Pengadu> pengadu;
  final List<Pengaduan> pengaduan;
  final Function(String screen) onNavigate;

  static const Color _primary = Color(0xFF3B5BDB);
  static const Color _primaryLight = Color(0xFF4C6EF5);

  const DashboardTU({
    super.key,
    required this.petugas,
    required this.pengadu,
    required this.pengaduan,
    required this.onNavigate,
  });

  // ======================== ERROR VIEW ========================
  Widget _errorView(Object error, StackTrace stack) {
    final debugText = '========= DASHBOARD TU ERROR =========\n\n$error\n\n$stack';
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("DEBUG ERROR"),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => Clipboard.setData(ClipboardData(text: debugText)),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(debugText, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontFamily: 'monospace')),
        ),
      ),
    );
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
                      const Text(
                        'Ahmad Fauzi',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Text('Petugas Tata Usaha', style: TextStyle(color: Colors.white60, fontSize: 13)),
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
                      child: Icon(Icons.shield_rounded, size: 30, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
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
  Widget _buildStatCards(int pPetugas, int pPengadu, int pPengaduan, int pTinggi) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard('Petugas', pPetugas, Icons.badge_rounded, const Color(0xFF3B5BDB), const Color(0xFFEDF2FF), () => onNavigate('petugas')),
        _statCard('Pengadu', pPengadu, Icons.people_rounded, const Color(0xFF0CA678), const Color(0xFFE6FCF5), () => onNavigate('pengadu')),
        _statCard('Pengaduan', pPengaduan, Icons.inbox_rounded, const Color(0xFFEA6C00), const Color(0xFFFFF4E6), () => onNavigate('pengaduan')),
        _statCard('Prioritas Tinggi', pTinggi, Icons.warning_amber_rounded, const Color(0xFFE03131), const Color(0xFFFFF5F5), null),
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
          border: Border.all(color: color.withOpacity(0.12)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
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
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 18),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color.withOpacity(0.6)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value.toString(), style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
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
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
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
                  onPressed: () => onNavigate('pengaduan'),
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
                        color: _statusColor(p.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.inbox_rounded, color: _statusColor(p.status), size: 20),
                    ),
                    title: Text(p.judul, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('${p.namaPengadu} · ${p.tanggal}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor(p.status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_statusText(p.status), style: TextStyle(color: _statusColor(p.status), fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _prioritasColor(p.prioritas).withOpacity(0.10),
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
    try {
      final prioritasTinggi = pengaduan.where((e) => e.prioritas == Prioritas.tinggi).length;
      final masuk = pengaduan.where((e) => e.status == StatusPengaduan.masuk).length;
      final diproses = pengaduan.where((e) => e.status == StatusPengaduan.diproses).length;
      final selesai = pengaduan.where((e) => e.status == StatusPengaduan.selesai).length;
      final ditolak = pengaduan.where((e) => e.status == StatusPengaduan.ditolak).length;

      return Scaffold(
        backgroundColor: const Color(0xFFF0F2FF),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    _buildStatCards(petugas.length, pengadu.length, pengaduan.length, prioritasTinggi),
                    const SizedBox(height: 16),
                    _buildStatusBar(masuk, diproses, selesai, ditolak),
                    const SizedBox(height: 16),
                    _buildRingkasan(petugas.length, petugas.length, masuk, selesai, pengaduan.length),
                    const SizedBox(height: 16),
                    _buildPengaduanTerbaru(pengaduan.take(5).toList()),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, s) {
      return _errorView(e, s);
    }
  }
}
