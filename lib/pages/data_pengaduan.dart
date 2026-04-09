import 'package:flutter/material.dart';
import '../models/models.dart';
import 'navbar_kepsek.dart';
class DataPengaduan extends StatefulWidget {
  final List<Pengaduan> pengaduan;

  const DataPengaduan({super.key, required this.pengaduan});

  @override
  State<DataPengaduan> createState() => _DataPengaduanState();
}

class _DataPengaduanState extends State<DataPengaduan> {
  String search = '';
  String statusFilter = 'semua';
  Pengaduan? selected;

  List<Pengaduan> get filtered {
    return widget.pengaduan.where((p) {
      final matchSearch =
          p.judul.toLowerCase().contains(search.toLowerCase()) ||
          p.namaPengadu.toLowerCase().contains(search.toLowerCase()) ||
          p.id.toLowerCase().contains(search.toLowerCase());

      final matchStatus =
          statusFilter == 'semua' || p.status == statusFilter;

      return matchSearch && matchStatus;
    }).toList();
  }

 void updateStatus(String id, StatusPengaduan status) {
  setState(() {
    final index = widget.pengaduan.indexWhere((e) => e.id == id);

    if (index != -1) {
      final old = widget.pengaduan[index];

      widget.pengaduan[index] = Pengaduan(
        id: old.id,
        pengaduId: old.pengaduId,
        namaPengadu: old.namaPengadu,
        judul: old.judul,
        isi: old.isi,
        kategori: old.kategori,
        status: status, // ✅ enum
        tanggal: old.tanggal,
        prioritas: old.prioritas,
      );

      if (selected?.id == id) {
        selected = widget.pengaduan[index];
      }
    }
  });
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
            child: filtered.isEmpty
                ? const Center(child: Text('Tidak ada pengaduan'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final p = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor(p.status).withOpacity(0.2),
                            child: Icon(
                              Icons.inbox,
                              color: statusColor(p.status),
                            ),
                          ),
                          title: Text(p.judul),
                          subtitle: Text(
                              '${p.namaPengadu} • ${p.tanggal}'),
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
                p.id,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              Chip(
                label: Text(p.status.name), // ✅ FIX
                backgroundColor: statusColor(p.status).withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(p.judul,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Pengadu: ${p.namaPengadu}'),
          Text('Tanggal: ${p.tanggal}'),
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
                    onPressed: () {
                      updateStatus(p.id, s); // ✅ enum
                      Navigator.pop(context);
                    },
                    child: Text(s.name), // tampilkan teks
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}