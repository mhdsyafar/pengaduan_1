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
        return Colors.blue;
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${p.id}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              Chip(
                label: Text(p.status.name),
                backgroundColor: statusColor(p.status).withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(p.judul,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Pengadu: ${p.namaPengadu}'),
          Text('Tanggal: ${p.tanggal.substring(0, 10)}'),
          Text('Kategori: ${p.kategori}'),
          const SizedBox(height: 12),
          Text(p.isi),
          const SizedBox(height: 16),

          const Text('Ubah Status',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: StatusPengaduan.values
                .where((s) => s != p.status)
                .map(
                  (s) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: statusColor(s)),
                      backgroundColor: statusColor(s).withValues(alpha: 0.1),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close sheet before updating
                      updateStatus(p.id, s);
                    },
                    child: Text(s.name, style: TextStyle(color: statusColor(s))),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}