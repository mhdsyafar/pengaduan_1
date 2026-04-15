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
      setState(() {
        _laporan = mappedAduan;
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
    // Dummy response times for now
    return Row(
      children: [
        _summaryChip('Respons Cepat', '3', const Color(0xFF2F9E44)),
        const SizedBox(width: 8),
        _summaryChip('Respons Lambat', '2', const Color(0xFFEA6C00)),
        const SizedBox(width: 8),
        _summaryChip('Belum Respons', _laporan.where((l) => l.status == StatusPengaduan.masuk).length.toString(), const Color(0xFFE03131)),
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

  Widget _buildTeacherList() {
    final teachers = [
      {'name': 'Pak Budi Dharma', 'subject': 'Matematika', 'time': '5 menit', 'status': 'Sangat Cepat', 'color': const Color(0xFF2F9E44), 'rating': 5},
      {'name': 'Bu Sari Indah', 'subject': 'Bahasa Indonesia', 'time': '22 menit', 'status': 'Cepat', 'color': const Color(0xFF2F9E44), 'rating': 4},
      {'name': 'Pak Andi Kusuma', 'subject': 'Fisika', 'time': '1 jam 15 mnt', 'status': 'Lambat', 'color': const Color(0xFFEA6C00), 'rating': 2},
    ];

    return Column(
      children: teachers.asMap().entries.map((e) {
        final t = e.value;
        final color = t['color'] as Color;
        final rating = t['rating'] as int;
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
                    Text(t['subject'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Row(children: List.generate(5, (i) => Icon(
                      i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 13,
                      color: i < rating ? const Color(0xFFF59F00) : Colors.grey.shade300,
                    ))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(t['time'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
                    child: Text(t['status'] as String, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
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