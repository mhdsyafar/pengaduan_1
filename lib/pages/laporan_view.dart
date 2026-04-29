import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class LaporanView extends StatefulWidget {
  final String initialFilter;
  const LaporanView({super.key, this.initialFilter = 'Semua'});

  @override
  State<LaporanView> createState() => _LaporanViewState();
}

class _LaporanViewState extends State<LaporanView> {
  static const Color _primary = Color(0xFF0D9488);
  late String _selectedFilter;
  bool _isLoading = true;

  final _filters = ['Semua', 'Diproses', 'Selesai', 'Menunggu', 'Ditolak'];
  List<Pengaduan> _laporan = [];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getAllPengaduan();
    
    if (response['success'] == true) {
      final List<Pengaduan> mappedAduan = (response['data'] as List)
          .map((item) => Pengaduan.fromJson(item))
          .toList();
      setState(() {
        _laporan = mappedAduan;
      });
    }
    setState(() => _isLoading = false);
  }

  List<Pengaduan> get _filtered {
    if (_selectedFilter == 'Semua') return _laporan;
    if (_selectedFilter == 'Diproses') {
      return _laporan.where((l) => l.status == StatusPengaduan.diproses).toList();
    }
    if (_selectedFilter == 'Selesai') {
      return _laporan.where((l) => l.status == StatusPengaduan.selesai).toList();
    }
    if (_selectedFilter == 'Menunggu') {
      return _laporan.where((l) => l.status == StatusPengaduan.masuk).toList();
    }
    if (_selectedFilter == 'Ditolak') {
      return _laporan.where((l) => l.status == StatusPengaduan.ditolak).toList();
    }
    return _laporan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Daftar Laporan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _fetchLaporan),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF0D9488)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
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
                          boxShadow: isActive ? [BoxShadow(color: _primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))] : [],
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
                : RefreshIndicator(
                    onRefresh: _fetchLaporan,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final l = _filtered[i];
                        Color color;
                        IconData icon;
                        String statusLabel;
                        
                        switch (l.status) {
                          case StatusPengaduan.masuk:
                            color = const Color(0xFF3B5BDB);
                            icon = Icons.inbox_rounded;
                            statusLabel = 'Menunggu';
                            break;
                          case StatusPengaduan.diproses:
                            color = const Color(0xFFEA6C00);
                            icon = Icons.pending_actions_rounded;
                            statusLabel = 'Diproses';
                            break;
                          case StatusPengaduan.selesai:
                            color = const Color(0xFF2F9E44);
                            icon = Icons.check_circle_rounded;
                            statusLabel = 'Selesai';
                            break;
                          case StatusPengaduan.ditolak:
                            color = const Color(0xFFE03131);
                            icon = Icons.cancel_rounded;
                            statusLabel = 'Ditolak';
                            break;
                        }

                        return GestureDetector(
                          onTap: () => _showDetail(context, l, color, statusLabel),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                              border: Border(left: BorderSide(color: color, width: 4)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
                                  child: Icon(icon, color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l.judul, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2),
                                      const SizedBox(height: 4),
                                      Text('Oleh: ${l.namaPengadu}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today_rounded, size: 11, color: Colors.grey.shade400),
                                          const SizedBox(width: 4),
                                          if (l.tanggal.isNotEmpty) Text(l.tanggal.substring(0, 10), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                                  child: Text(statusLabel, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Pengaduan l, Color color, String status) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            if (l.tanggal.isNotEmpty) Text(l.tanggal.substring(0, 10), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ]),
          const SizedBox(height: 12),
          Text(l.judul, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Oleh: ${l.namaPengadu}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),
          const Text('Deskripsi Laporan:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(l.isi, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Tutup', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }
}
