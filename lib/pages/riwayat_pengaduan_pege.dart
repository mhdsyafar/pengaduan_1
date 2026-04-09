import 'package:flutter/material.dart';
import '../data/dummy_pengaduan.dart';


class RiwayatPengaduanPage extends StatelessWidget {
  const RiwayatPengaduanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pengaduan')),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: riwayatPengaduan.length,
        itemBuilder: (context, index) {
          final data = riwayatPengaduan[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(data['judul']!),
              subtitle: Text('${data['tanggal']} • Status: ${data['status']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}
