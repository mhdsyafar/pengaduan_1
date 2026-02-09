import 'package:flutter/material.dart';

class PengaduanPage extends StatelessWidget {
  const PengaduanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final judulController = TextEditingController();
    final isiController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Pengaduan')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: judulController,
              decoration: const InputDecoration(
                labelText: 'Judul Pengaduan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: isiController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Isi Pengaduan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengaduan berhasil dikirim'),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Kirim Pengaduan'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
