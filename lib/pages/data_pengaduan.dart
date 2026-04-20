import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class DataPengaduan extends StatefulWidget {
  const DataPengaduan({super.key});

  @override
  State<DataPengaduan> createState() => _DataPengaduanState();
}

class _DataPengaduanState extends State<DataPengaduan> {
  String search = '';
  String statusFilter = 'semua';
  Pengaduan? selected;
  
  List<Pengaduan> pengaduanList = [];
  bool isLoading = true;

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

  List<Pengaduan> get filtered {
    return pengaduanList.where((p) {
      final matchSearch =
          p.judul.toLowerCase().contains(search.toLowerCase()) ||
          p.namaPengadu.toLowerCase().contains(search.toLowerCase()) ||
          p.id.toLowerCase().contains(search.toLowerCase());

      bool matchStatus = statusFilter == 'semua';
      if (!matchStatus) {
        if (statusFilter == 'masuk') matchStatus = p.status == StatusPengaduan.masuk;
        if (statusFilter == 'diproses') matchStatus = p.status == StatusPengaduan.diproses;
        if (statusFilter == 'selesai') matchStatus = p.status == StatusPengaduan.selesai;
        if (statusFilter == 'ditolak') matchStatus = p.status == StatusPengaduan.ditolak;
      }

      return matchSearch && matchStatus;
    }).toList();
  }

  Future<void> updateStatus(String id, StatusPengaduan status) async {
    // 1. Dapatkan konversi string status
    String statusStr = 'diajukan'; // default
    if (status == StatusPengaduan.diproses) statusStr = 'diproses';
    if (status == StatusPengaduan.selesai) statusStr = 'selesai';
    if (status == StatusPengaduan.ditolak) statusStr = 'ditolak';

    // 2. Panggil API backend
    final response = await ApiService.updateStatusPengaduan(id, statusStr);
    
    if (!mounted) return;
    
    if (response['success'] == true) {
      // 3. Jika sukses, muat ulang daftar pengaduan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status berhasil diperbarui!')),
      );
      _fetchData();
    } else {
      // 4. Jika gagal, tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Gagal memperbarui status')),
      );
    }
  }

  Color statusColor(StatusPengaduan status) {
    switch (status) {
      case StatusPengaduan.masuk:
        return const Color(0xFF0D9488);
      case StatusPengaduan.diproses:
        return Colors.orange;
      case StatusPengaduan.selesai:
        return Colors.green;
      case StatusPengaduan.ditolak:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pengaduan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _fetchData,
          )
        ],
      ),
      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari judul, nama, atau ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => search = v),
            ),
          ),

          // FILTER
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['semua', 'masuk', 'diproses', 'selesai', 'ditolak']
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(s),
                        selected: statusFilter == s,
                        onSelected: (_) =>
                            setState(() => statusFilter = s),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 8),

          // LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('Tidak ada pengaduan'))
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final p = filtered[i];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: statusColor(p.status).withValues(alpha: 0.2),
                                    child: Icon(
                                      Icons.inbox,
                                      color: statusColor(p.status),
                                    ),
                                  ),
                                  title: Text(p.judul),
                                  subtitle: Text(
                                      '${p.namaPengadu} • ${p.tanggal.substring(0, 10)}'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    setState(() => selected = p);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (_) => detailSheet(),
                                    );
                                  },
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

  Widget detailSheet() {
    if (selected == null) return const SizedBox();

    final p = selected!;
    final Color sColor = statusColor(p.status);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // HANDLE
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    // HEADER SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('#${p.id}', style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: sColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: sColor.withValues(alpha: 0.2))),
                          child: Text(p.status.name.toUpperCase(), style: TextStyle(color: sColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(p.judul, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 12),
                    
                    // INFO CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: Column(
                        children: [
                          _infoRow(Icons.person_outline_rounded, 'Pengadu', p.namaPengadu),
                          const Divider(height: 24),
                          _infoRow(Icons.calendar_today_rounded, 'Tanggal', p.tanggal.substring(0, 10)),
                          const Divider(height: 24),
                          _infoRow(Icons.category_outlined, 'Kategori', p.kategori),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('Isi Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(p.isi, style: const TextStyle(fontSize: 15, color: Color(0xFF4A4A4A), height: 1.5)),
                    
                    const SizedBox(height: 24),
                    if (p.rawTanggapans != null && p.rawTanggapans!.isNotEmpty) ...[
                      const Text('Tanggapan Petugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...p.rawTanggapans!.map((t) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withValues(alpha: 0.1))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.reply_all_rounded, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(t['Petugas']?['User']?['nama_lengkap'] ?? 'Petugas', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(t['isi_tanggapan'] ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
                          ],
                        ),
                      )),
                    ],

                    const SizedBox(height: 24),
                    const Text('Aksi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: StatusPengaduan.values.map((s) {
                        final isCurrent = s == p.status;
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 48) / 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCurrent ? statusColor(s) : Colors.white,
                              foregroundColor: isCurrent ? Colors.white : statusColor(s),
                              elevation: 0,
                              side: BorderSide(color: statusColor(s)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: isCurrent ? null : () {
                              Navigator.pop(context);
                              updateStatus(p.id, s);
                            },
                            child: Text(s.name.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: Icon(icon, size: 18, color: Colors.grey.shade600)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
          ],
        ),
      ],
    );
  }
}