import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class MonitoringView extends StatefulWidget {
  const MonitoringView({super.key});

  @override
  State<MonitoringView> createState() => _MonitoringViewState();
}

class _MonitoringViewState extends State<MonitoringView> {
  static const Color _primary = Color(0xFF7048E8);
  bool _isLoading = true;
  List<Pengaduan> _laporan = [];
  
  int _cepatCount = 0;
  int _lambatCount = 0;
  List<Map<String, dynamic>> _teacherResponsList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getAllPengaduan();
    
    if (response['success'] == true) {
      final List<Pengaduan> mappedAduan = (response['data'] as List)
          .map((item) => Pengaduan.fromJson(item))
          .toList();
          
      int cepat = 0;
      int lambat = 0;
      List<Map<String, dynamic>> responsData = [];

      for (var aduan in mappedAduan) {
        if (aduan.rawTanggapans != null && aduan.rawTanggapans!.isNotEmpty) {
          final tglAduan = DateTime.tryParse(aduan.tanggal);
          
          for (var t in aduan.rawTanggapans!) {
            final tglTanggapan = DateTime.tryParse(t['tanggal_tanggapan'] ?? '');
            final userNama = (t['User'] != null) ? t['User']['nama_lengkap'] : 'Guru';
            
            if (tglAduan != null && tglTanggapan != null) {
              final diff = tglTanggapan.difference(tglAduan);
              
              if (diff.inHours <= 24) {
                cepat++;
              } else {
                lambat++;
              }
              
              responsData.add({
                'name': userNama,
                'judul_aduan': aduan.judul,
                'diff': diff,
              });
            }
          }
        }
      }
      
      // Sort by fastest response
      responsData.sort((a, b) => (a['diff'] as Duration).compareTo(b['diff'] as Duration));

      setState(() {
        _laporan = mappedAduan;
        _cepatCount = cepat;
        _lambatCount = lambat;
        _teacherResponsList = responsData;
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FF),
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Monitoring Respons', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchData,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5E35B1), Color(0xFF7048E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Respons Guru per Pengaduan'),
                  const SizedBox(height: 12),
                  _buildTeacherList(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Pengaduan Belum Ditangani'),
                  const SizedBox(height: 12),
                  _buildPendingList(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1C1C3A)));
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _summaryChip('Respons Cepat', '$_cepatCount', const Color(0xFF2F9E44)),
        const SizedBox(width: 8),
        _summaryChip('Respons Lambat', '$_lambatCount', const Color(0xFFEA6C00)),
        const SizedBox(width: 8),
        _summaryChip('Belum Respons', _laporan.where((l) => l.status == StatusPengaduan.masuk && (l.rawTanggapans == null || l.rawTanggapans!.isEmpty)).length.toString(), const Color(0xFFE03131)),
      ],
    );
  }

  Widget _summaryChip(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.8)), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays} hari';
    if (d.inHours > 0) return '${d.inHours} jam';
    if (d.inMinutes > 0) return '${d.inMinutes} mnt';
    return 'Baru saja';
  }

  Widget _buildTeacherList() {
    if (_teacherResponsList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: const Center(child: Text("Belum ada tanggapan masuk.", style: TextStyle(color: Colors.grey))),
      );
    }

    return Column(
      children: _teacherResponsList.take(5).map((t) { // Take top 5 fastest/latest
        final diff = t['diff'] as Duration;
        final isFast = diff.inHours <= 24;
        final color = isFast ? const Color(0xFF2F9E44) : const Color(0xFFEA6C00);
        final statusLabel = isFast ? 'Cepat' : 'Lambat';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.15)]),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('Respons untuk: ${t['judul_aduan']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatDuration(diff), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
                    child: Text(statusLabel, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingList() {
    final pending = _laporan.where((l) => l.status == StatusPengaduan.masuk).toList();

    if (pending.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: const Center(child: Text("Tidak ada pengaduan yang menunggu.", style: TextStyle(color: Colors.grey))),
      );
    }

    return Column(
      children: pending.map((p) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: const Border(left: BorderSide(color: Color(0xFFE03131), width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFE03131), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.judul, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('Oleh: ${p.namaPengadu}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                Text(p.tanggal.isNotEmpty ? p.tanggal.substring(0, 10) : '', style: const TextStyle(fontSize: 11, color: Color(0xFFE03131))),
              ]),
            ),
          ],
        ),
      )).toList(),
    );
  }
}