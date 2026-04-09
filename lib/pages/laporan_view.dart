import 'package:flutter/material.dart';

class LaporanView extends StatefulWidget {
  const LaporanView({super.key});

  @override
  State<LaporanView> createState() => _LaporanViewState();
}

class _LaporanViewState extends State<LaporanView> {
  static const Color _primary = Color(0xFF7048E8);
  String _selectedFilter = 'Semua';

  final _filters = ['Semua', 'Diproses', 'Selesai', 'Menunggu', 'Ditolak'];

  final _laporan = [
    {'title': 'Pengaduan tugas terlalu banyak', 'by': 'Budi Santoso (Orang Tua 8B)', 'date': '11 Mar 2026', 'status': 'Diproses', 'color': const Color(0xFFEA6C00), 'icon': Icons.pending_actions_rounded},
    {'title': 'Kelas terlalu bising saat belajar', 'by': 'Siti Rahayu (Orang Tua 7A)', 'date': '10 Mar 2026', 'status': 'Selesai', 'color': const Color(0xFF2F9E44), 'icon': Icons.check_circle_rounded},
    {'title': 'Guru terlambat datang mengajar', 'by': 'Ahmad Fauzan (Orang Tua 9C)', 'date': '9 Mar 2026', 'status': 'Menunggu', 'color': const Color(0xFF3B5BDB), 'icon': Icons.inbox_rounded},
    {'title': 'Fasilitas toilet tidak layak pakai', 'by': 'Dewi Lestari (Orang Tua 8A)', 'date': '8 Mar 2026', 'status': 'Selesai', 'color': const Color(0xFF2F9E44), 'icon': Icons.check_circle_rounded},
    {'title': 'Anak mengalami perundungan (bullying)', 'by': 'Hendra Wijaya (Orang Tua 7C)', 'date': '7 Mar 2026', 'status': 'Diproses', 'color': const Color(0xFFEA6C00), 'icon': Icons.pending_actions_rounded},
    {'title': 'Buku pelajaran belum tersedia', 'by': 'Rina Wahyuni (Orang Tua 9A)', 'date': '6 Mar 2026', 'status': 'Ditolak', 'color': const Color(0xFFE03131), 'icon': Icons.cancel_rounded},
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'Semua') return _laporan;
    return _laporan.where((l) => l['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FF),
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Daftar Laporan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded, color: Colors.white), onPressed: () {}),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF5E35B1), Color(0xFF7048E8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isActive = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive ? _primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isActive ? _primary : Colors.grey.shade300),
                          boxShadow: isActive ? [BoxShadow(color: _primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))] : [],
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('${_filtered.length} laporan ditemukan', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text('Tidak ada laporan', style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
                    ]),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final l = _filtered[i];
                      final color = l['color'] as Color;
                      return GestureDetector(
                        onTap: () => _showDetail(context, l),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                            border: Border(left: BorderSide(color: color, width: 4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
                                child: Icon(l['icon'] as IconData, color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2),
                                    const SizedBox(height: 4),
                                    Text(l['by'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded, size: 11, color: Colors.grey.shade400),
                                        const SizedBox(width: 4),
                                        Text(l['date'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                                child: Text(l['status'] as String, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> l) {
    final color = l['color'] as Color;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(l['status'] as String, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            Text(l['date'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ]),
          const SizedBox(height: 12),
          Text(l['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(l['by'] as String, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),
          const Text('Deskripsi Laporan:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Laporan ini telah diterima dan akan segera ditindaklanjuti oleh pihak sekolah.', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Tutup', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}