import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'tanggapan_page.dart';

class PengaduanPage extends StatefulWidget {
  final String? initialFilter;
  const PengaduanPage({super.key, this.initialFilter});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  String search = "";
  late String filter;
  bool showFilter = false;

  List<Pengaduan> pengaduanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    filter = widget.initialFilter ?? "semua";
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
    return pengaduanList.where((p) {
      final matchSearch = p.namaPengadu.toLowerCase().contains(search.toLowerCase()) || 
                          p.isi.toLowerCase().contains(search.toLowerCase()) || 
                          p.kategori.toLowerCase().contains(search.toLowerCase());
                          
      bool matchFilter = filter == "semua";
      if (!matchFilter) {
        if (filter == 'baru') matchFilter = p.status == StatusPengaduan.masuk;
        if (filter == 'diproses') matchFilter = p.status == StatusPengaduan.diproses;
        if (filter == 'selesai') matchFilter = p.status == StatusPengaduan.selesai;
      }
      return matchSearch && matchFilter;
    }).toList();
  }

  static const Color _primary = Color(0xFF0D9488);

  // Method to Update Status (Optional if Guru is allowed)
  Future<void> updateStatus(String id, StatusPengaduan status) async {
    String statusStr = 'diajukan'; // default
    if (status == StatusPengaduan.diproses) statusStr = 'diproses';
    if (status == StatusPengaduan.selesai) statusStr = 'selesai';
    if (status == StatusPengaduan.ditolak) statusStr = 'ditolak';

    final response = await ApiService.updateStatusPengaduan(id, statusStr);
    if (!mounted) return;
    
    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status berhasil diperbarui!')));
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? 'Gagal memperbarui status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Daftar Pengaduan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: isLoading ? null : _fetchData),
          Row(
            children: [
               const SizedBox(width: 6),
              Text("${pengaduanList.length}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
            ],
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF0D9488)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Cari pengaduan...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  ),
                  onChanged: (v) => setState(() => search = v),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ["semua", "baru", "diproses", "selesai"].map((s) {
                      final isSelected = filter == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => filter = s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? _primary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? _primary : Colors.grey.shade300),
                            ),
                            child: Text(
                              s == "semua" ? "Semua" : s[0].toUpperCase() + s.substring(1),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey.shade600),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
                            Text("Tidak ada pengaduan", style: TextStyle(color: Colors.grey.shade500)),
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
                              Color color;
                              String label;
                              if (item.status == StatusPengaduan.diproses) {
                                color = const Color(0xFF3B5BDB);
                                label = "Diproses";
                              } else if (item.status == StatusPengaduan.selesai) {
                                color = const Color(0xFF2F9E44);
                                label = "Selesai";
                              } else {
                                color = const Color(0xFFE03131);
                                label = "Baru";
                              }
                        
                              return GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    builder: (_) => Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Handle bar
                                          Container(
                                            width: 40, height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          // Judul pengaduan
                                          Text(
                                            item.judul,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Oleh: ${item.namaPengadu}',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                          ),
                                          const SizedBox(height: 12),

                                          // Isi pengaduan
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: Text(
                                              item.isi,
                                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                              maxLines: 5,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          // Tombol Balas Pengaduan
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => TanggapanPage(pengaduan: item),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.reply_rounded),
                                              label: const Text('Balas Pengaduan', style: TextStyle(fontWeight: FontWeight.bold)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _primary,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          // Ubah status
                                          const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Ubah Status", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: StatusPengaduan.values.map((s) {
                                              final isActive = s == item.status;
                                              return ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  updateStatus(item.id, s);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isActive ? _primary : Colors.grey.shade100,
                                                  foregroundColor: isActive ? Colors.white : Colors.black87,
                                                  elevation: isActive ? 2 : 0,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                ),
                                                child: Text(s.name[0].toUpperCase() + s.name.substring(1), style: const TextStyle(fontSize: 12)),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                                    border: Border(left: BorderSide(color: color, width: 4)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44, height: 44,
                                        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                                        child: Center(child: Text(item.namaPengadu.isNotEmpty ? item.namaPengadu[0].toUpperCase() : '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18))),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.namaPengadu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            const SizedBox(height: 2),
                                            Text(item.kategori, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                            const SizedBox(height: 6),
                                            Text(item.isi, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                                            child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(item.tanggal.substring(0, 10), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                        ],
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
}
