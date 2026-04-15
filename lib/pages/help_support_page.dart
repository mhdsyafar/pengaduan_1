import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2F4AC2);

    final List<Map<String, String>> faqs = [
      {
        'question': 'Bagaimana cara membuat pengaduan?',
        'answer': 'Anda dapat membuat pengaduan melalui menu "Pengaduan" di navigasi bawah, lalu tekan tombol tambah (+) untuk mengisi formulir pengaduan.'
      },
      {
        'question': 'Berapa lama proses penanganan pengaduan?',
        'answer': 'Waktu penanganan bervariasi tergantung pada jenis pengaduan. Biasanya diproses dalam 1-3 hari kerja.'
      },
      {
        'question': 'Bagaimana cara melihat status pengaduan saya?',
        'answer': 'Status pengaduan dapat dilihat pada menu "Riwayat" atau langsung melalui riwayat di dashboard Anda.'
      },
      {
        'question': 'Apakah saya bisa mengedit pengaduan yang sudah dikirim?',
        'answer': 'Saat ini pengaduan yang sudah dikirim tidak dapat diubah. Jika ada kesalahan, Anda bisa menghubungi petugas TU.'
      },
      {
        'question': 'Bagaimana jika lupa password?',
        'answer': 'Silakan hubungi admin sekolah atau petugas TU untuk melakukan reset password akun Anda.'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      appBar: AppBar(
        title: const Text('Bantuan & Dukungan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              width: double.infinity,
              child: Column(
                children: [
                  const Icon(Icons.help_outline_rounded, size: 64, color: primary),
                  const SizedBox(height: 16),
                  const Text(
                    'Pusat Bantuan',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1C1C3A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Temukan jawaban atas pertanyaan Anda atau hubungi dukungan kami.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1C3A)),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: faqs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ExpansionTile(
                        backgroundColor: Colors.white,
                        collapsedBackgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(
                          faqs[index]['question']!,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C3A)),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              faqs[index]['answer']!,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Masih butuh bantuan?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1C3A)),
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    icon: Icons.email_rounded,
                    title: 'Email',
                    subtitle: 'support@sekolah.sch.id',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.phone_rounded,
                    title: 'Telepon / WhatsApp',
                    subtitle: '+62 812 3456 7890',
                    onTap: () {},
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2F4AC2).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.email_rounded, color: Color(0xFF2F4AC2), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }
}
