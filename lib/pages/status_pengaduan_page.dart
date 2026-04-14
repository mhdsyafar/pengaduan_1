import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'tanggapan_page.dart';

class StatusPengaduanPage extends StatefulWidget {
  const StatusPengaduanPage({super.key});

  @override
  State<StatusPengaduanPage> createState() => _StatusPengaduanPageState();
}

class _StatusPengaduanPageState extends State<StatusPengaduanPage> {
  String filter = 'semua';
  String search = '';
  String? expandedId;
  
  List<Pengaduan> pengaduanList = [];
  bool isLoading = true;

  static const Color _primary = Color(0xFF2F4AC2);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final response = await ApiService.getAllPengaduan();
    
    if (!mounted) return;
    
    if (response['success'] == true) {
      final list = (response['data'] as List)
          .map((item) => Pengaduan.fromJson(item))
          .toList();
      setState(() {
        pengaduanList = list;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Gagal memuat data')),
      );
    }
  }

  List<Pengaduan> get filteredList {
    return pengaduanList.where((item) {
      bool matchesFilter = filter == 'semua';
      if (!matchesFilter) {
        if (filter == 'menunggu') matchesFilter = item.status == StatusPengaduan.masuk;
        if (filter == 'diproses') matchesFilter = item.status == StatusPengaduan.diproses;
        if (filter == 'selesai') matchesFilter = item.status == StatusPengaduan.selesai;
      }
      final matchesSearch = item.judul.toLowerCase().contains(search.toLowerCase()) || item.kategori.toLowerCase().contains(search.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Status Pengaduan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: isLoading ? null : _fetchData,
          )
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF283F9E), Color(0xFF2F4AC2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pantau perkembangan pengaduan Anda', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari pengaduan...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  ),
                  onChanged: (value) => setState(() => search = value),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('semua', 'Semua'),
                      _filterChip('menunggu', 'Menunggu'),
                      _filterChip('diproses', 'Diproses'),
                      _filterChip('selesai', 'Selesai'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('Tidak ada pengaduan ditemukan', style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              final isExpanded = expandedId == item.id;
                              
                              Color color;
                              String label;
                              IconData icon;
                              if (item.status == StatusPengaduan.diproses) {
                                color = const Color(0xFF3B5BDB);
                                label = "Diproses";
                                icon = Icons.sync_rounded;
                              } else if (item.status == StatusPengaduan.selesai) {
                                color = const Color(0xFF2F9E44);
                                label = "Selesai";
                                icon = Icons.check_circle_rounded;
                              } else if (item.status == StatusPengaduan.ditolak) {
                                color = const Color(0xFFE03131);
                                label = "Ditolak";
                                icon = Icons.cancel_rounded;
                              } else {
                                color = const Color(0xFFEA6C00);
                                label = "Masuk";
                                icon = Icons.access_time_rounded;
                              }
                        
                              return GestureDetector(
                                onTap: () => setState(() => expandedId = isExpanded ? null : item.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                                    border: Border(left: BorderSide(color: color, width: 4)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('#${item.id}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontFamily: 'monospace')),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                                            child: Row(
                                              children: [
                                                Icon(icon, size: 12, color: color),
                                                const SizedBox(width: 4),
                                                Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(item.judul, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                            child: Text(item.kategori, style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade400),
                                          const SizedBox(width: 4),
                                          Text(item.tanggal.substring(0, 10), style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                                        ],
                                      ),
                        
                                      if (isExpanded) ...[
                                        const SizedBox(height: 16),
                                        const Divider(),
                                        const SizedBox(height: 12),
                                        Text('Deskripsi:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                                        const SizedBox(height: 4),
                                        Text(item.isi, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
                                        const SizedBox(height: 16),
                                        
                                        _timelineStep(Colors.green, 'Pengaduan diterima', item.tanggal.substring(0, 10)),
                                        if (item.status == StatusPengaduan.diproses || item.status == StatusPengaduan.selesai)
                                          _timelineStep(const Color(0xFF3B5BDB), 'Sedang ditinjau oleh sekolah', 'Proses'),
                                        if (item.status == StatusPengaduan.selesai)
                                          _timelineStep(Colors.green, 'Pengaduan diselesaikan', 'Selesai'),

                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (_) => TanggapanPage(pengaduan: item)));
                                            },
                                            icon: const Icon(Icons.forum_rounded, size: 16),
                                            label: const Text('Lihat Tanggapan / Balasan'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: _primary,
                                              side: const BorderSide(color: _primary),
                                            ),
                                          ),
                                        ),
                                      ],
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

  Widget _filterChip(String id, String label) {
    final selected = filter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => filter = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? _primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? _primary : Colors.grey.shade300),
          ),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.grey.shade600)),
        ),
      ),
    );
  }

  Widget _timelineStep(Color color, String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade700))),
          Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}