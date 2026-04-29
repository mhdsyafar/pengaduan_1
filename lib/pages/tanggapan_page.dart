import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class TanggapanPage extends StatefulWidget {
  final Pengaduan pengaduan;

  const TanggapanPage({super.key, required this.pengaduan});

  @override
  State<TanggapanPage> createState() => _TanggapanPageState();
}

class _TanggapanPageState extends State<TanggapanPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _tanggapanList = [];
  bool isLoading = true;
  bool isSubmitting = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchTanggapan();
  }

  Future<void> _loadUser() async {
    final userData = await ApiService.getUserData();
    if (mounted && userData != null) {
      setState(() {
        _currentUserId = userData['id_user'];
      });
    }
  }

  Future<void> _fetchTanggapan() async {
    final response = await ApiService.getTanggapan(widget.pengaduan.id);
    if (!mounted) return;

    if (response['success'] == true) {
      setState(() {
        _tanggapanList = response['data'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Gagal memuat tanggapan')),
      );
    }
  }

  Future<void> _submitTanggapan() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => isSubmitting = true);

    final response = await ApiService.createTanggapan(widget.pengaduan.id, text);
    
    if (!mounted) return;

    if (response['success'] == true) {
      _controller.clear();
      _fetchTanggapan(); // reload the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Gagal mengirim tanggapan')),
      );
    }
    
    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        title: const Text('Tanggapan Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pengaduan.judul,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Oleh: ${widget.pengaduan.namaPengadu}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.pengaduan.isi,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tanggapanList.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada tanggapan\nJadilah yang pertama menanggapi!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tanggapanList.length,
                        itemBuilder: (context, index) {
                          final t = _tanggapanList[index];
                          final user = t['User'] != null ? t['User']['nama_lengkap'] : 'User';
                          final isi = t['isi_tanggapan'] ?? '';
                          final tgl = t['tanggal_tanggapan']?.substring(0, 10) ?? '';
                          
                          final isMe = _currentUserId != null && t['id_user'] == _currentUserId;

                          return Container(
                            margin: EdgeInsets.only(
                              bottom: 12,
                              left: isMe ? 40.0 : 0.0,
                              right: isMe ? 0.0 : 40.0,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16, color: Colors.blue),
                                    const SizedBox(width: 6),
                                    Text(
                                      user,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    const Spacer(),
                                    Text(
                                      tgl,
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(isi, style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          
          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Tulis tanggapan...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitTanggapan(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  isSubmitting
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.blue),
                          onPressed: _submitTanggapan,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
