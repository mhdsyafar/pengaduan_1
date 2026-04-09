import 'package:flutter/material.dart';

class Pengaduan {
  final String id;
  final String nama;
  final String kelas;
  final String kategori;
  final String deskripsi;
  final String tanggal;
  String status;

  Pengaduan({
    required this.id,
    required this.nama,
    required this.kelas,
    required this.kategori,
    required this.deskripsi,
    required this.tanggal,
    required this.status,
  });
}

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  String search = "";
  String filter = "semua";
  bool showFilter = false;

  final List<Pengaduan> pengaduanList = [
    Pengaduan(id: "1", nama: "Ahmad", kelas: "VII A", kategori: "Bullying", deskripsi: "Terjadi perundungan di kelas", tanggal: "05 Feb 2026", status: "baru"),
    Pengaduan(id: "2", nama: "Siti", kelas: "VIII B", kategori: "Fasilitas", deskripsi: "Kipas angin rusak", tanggal: "04 Feb 2026", status: "diproses"),
    Pengaduan(id: "3", nama: "Budi", kelas: "IX C", kategori: "Akademik", deskripsi: "Metode pembelajaran kurang jelas", tanggal: "03 Feb 2026", status: "selesai"),
  ];

  List<Pengaduan> get filteredList {
    return pengaduanList.where((p) {
      final matchSearch = p.nama.toLowerCase().contains(search.toLowerCase()) || p.deskripsi.toLowerCase().contains(search.toLowerCase()) || p.kategori.toLowerCase().contains(search.toLowerCase());
      final matchFilter = filter == "semua" || p.status == filter;
      return matchSearch && matchFilter;
    }).toList();
  }

  static const Color _primary = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Daftar Pengaduan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Row(
            children: [
              const Icon(Icons.message_rounded, color: Colors.white, size: 20),
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
            child: filteredList.isEmpty
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
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      Color color;
                      String label;
                      if (item.status == "diproses") {
                        color = const Color(0xFF3B5BDB);
                        label = "Diproses";
                      } else if (item.status == "selesai") {
                        color = const Color(0xFF2F9E44);
                        label = "Selesai";
                      } else {
                        color = const Color(0xFFE03131);
                        label = "Baru";
                      }

                      return Container(
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
                              child: Center(child: Text(item.nama[0], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18))),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text("${item.kelas} • ${item.kategori}", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                  const SizedBox(height: 6),
                                  Text(item.deskripsi, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
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
                                Text(item.tanggal, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
