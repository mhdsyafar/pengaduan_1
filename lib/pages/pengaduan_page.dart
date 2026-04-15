import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  bool isSubmitted = false;

  bool get isValid =>
      judulController.text.trim().isNotEmpty &&
      deskripsiController.text.trim().isNotEmpty;

  bool isLoading = false;
  
  Future<void> handleSubmit() async {
    if (!isValid) return;

    setState(() {
      isLoading = true;
    });

    final String finalIsi = deskripsiController.text.trim();

    final result = await ApiService.createPengaduan(
      judulController.text.trim(),
      finalIsi,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        isSubmitted = true;
        isLoading = false;
      });

      Timer(const Duration(milliseconds: 2500), () {
        if (!mounted) return;
        judulController.clear();
        deskripsiController.clear();
        setState(() {
          isSubmitted = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal membuat pengaduan')),
      );
    }
  }

  @override
  void dispose() {
    judulController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      appBar: AppBar(
        title: const Text('Ajukan Pengaduan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2F4AC2),
        elevation: 0,
        centerTitle: true,
      ),
      body: isSubmitted ? _successView() : _formView(),
    );
  }

  // ================= SUCCESS VIEW =================
  Widget _successView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 36,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pengaduan Terkirim!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Pengaduan Anda telah berhasil diajukan dan akan segera ditindaklanjuti.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FORM VIEW =================
  Widget _formView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajukan Pengaduan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sampaikan keluhan atau saran Anda kepada pihak sekolah',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          /// ================= Judul =================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Judul Pengaduan *',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: judulController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan judul pengaduan',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),



          const SizedBox(height: 12),

          /// ================= Deskripsi =================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deskripsi *',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: deskripsiController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: 'Jelaskan detail pengaduan Anda...',
                      border: OutlineInputBorder(),
                      isDense: true,
                      counterText: '',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  Text(
                    '${deskripsiController.text.length}/500 karakter',
                    style:
                        const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// ================= Submit =================
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: (isValid && !isLoading) ? handleSubmit : null,
              icon: isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send, size: 18),
              label: Text(
                isLoading ? 'Mengirim...' : 'Kirim Pengaduan',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}