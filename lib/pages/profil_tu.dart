import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

enum SubScreen {
  main,
  notifikasi,
  ubahPassword,
  bantuan,
  tentang,
  logoutConfirm,
}

class Notifikasi {
  final String id;
  final String judul;
  final String pesan;
  final String waktu;
  bool dibaca;
  final String tipe;

  Notifikasi({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.waktu,
    required this.dibaca,
    required this.tipe,
  });
}

class ProfilTUPage extends StatefulWidget {
  const ProfilTUPage({super.key});

  @override
  State<ProfilTUPage> createState() => _ProfilTUPageState();
}

class _ProfilTUPageState extends State<ProfilTUPage> {
  SubScreen subScreen = SubScreen.main;

  List<Notifikasi> notifikasi = [
    Notifikasi(
      id: "1",
      judul: "Pengaduan Baru Masuk",
      pesan:
          "Pengaduan #ADU-005 tentang 'Kerusakan Jalan' telah diterima dan menunggu tindak lanjut.",
      waktu: "5 menit lalu",
      dibaca: false,
      tipe: "pengaduan",
    ),
    Notifikasi(
      id: "2",
      judul: "Status Pengaduan Diperbarui",
      pesan: "Pengaduan #ADU-003 telah selesai diproses.",
      waktu: "1 jam lalu",
      dibaca: false,
      tipe: "pengaduan",
    ),
    Notifikasi(
      id: "3",
      judul: "Akun Petugas Baru",
      pesan: "Akun petugas Dewi Lestari berhasil dibuat.",
      waktu: "3 jam lalu",
      dibaca: true,
      tipe: "akun",
    ),
  ];

  int get unreadCount =>
      notifikasi.where((n) => !n.dibaca).length;

  // ================= HEADER =================
  Widget header(String title) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() => subScreen = SubScreen.main);
          },
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  // ================= NOTIFIKASI =================
  Widget notifikasiScreen() {
    return Column(
      children: [
        header("Notifikasi"),
        if (unreadCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$unreadCount belum dibaca"),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var n in notifikasi) {
                        n.dibaca = true;
                      }
                    });
                  },
                  child: const Text("Tandai semua"),
                )
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: notifikasi.length,
            itemBuilder: (context, index) {
              final n = notifikasi[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    n.tipe == "pengaduan"
                        ? Icons.message
                        : Icons.notifications,
                    color: n.dibaca ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    n.judul,
                    style: TextStyle(
                      fontWeight:
                          n.dibaca ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.pesan),
                      const SizedBox(height: 4),
                      Text(
                        n.waktu,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () {
                      setState(() => notifikasi.removeAt(index));
                    },
                  ),
                  onTap: () {
                    setState(() => n.dibaca = true);
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // ================= UBAH PASSWORD =================
  Widget ubahPasswordScreen() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    return Column(
      children: [
        header("Ubah Password"),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: oldController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Password Lama"),
              ),
              TextField(
                controller: newController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Password Baru"),
              ),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Konfirmasi Password"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Password berhasil diubah")),
                  );
                },
                child: const Text("Simpan"),
              )
            ],
          ),
        )
      ],
    );
  }

  // ================= BANTUAN =================
  Widget bantuanScreen() {
    return Column(
      children: [
        header("Bantuan"),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Jika mengalami kendala, hubungi:\n"
            "Email: support@pengaduan.go.id\n"
            "Telp: (021) 1234-5678",
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  // ================= TENTANG =================
  Widget tentangScreen() {
    return Column(
      children: [
        header("Tentang Aplikasi"),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Sistem Pengaduan Masyarakat Digital\n"
            "Versi 1.0.0\n\n"
            "Aplikasi ini digunakan oleh Petugas TU "
            "untuk mengelola pengaduan masyarakat.",
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  // ================= LOGOUT =================
  Widget logoutConfirm() {
    return Column(
      children: [
        header("Keluar"),
        const SizedBox(height: 40),
        const Text(
          "Apakah Anda yakin ingin keluar?",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await ApiService.logout();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (_) => false,
            );
          },
          child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            setState(() => subScreen = SubScreen.main);
          },
          child: const Text("Batal"),
        )
      ],
    );
  }

  // ================= MAIN =================
  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (subScreen) {
      case SubScreen.notifikasi:
        body = notifikasiScreen();
        break;
      case SubScreen.ubahPassword:
        body = ubahPasswordScreen();
        break;
      case SubScreen.bantuan:
        body = bantuanScreen();
        break;
      case SubScreen.tentang:
        body = tentangScreen();
        break;
      case SubScreen.logoutConfirm:
        body = logoutConfirm();
        break;
      default:
        body = mainScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Akun TU")),
      body: body,
    );
  }

  Widget mainScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FutureBuilder<Map<String, dynamic>?>(
          future: ApiService.getUserData(),
          builder: (context, snapshot) {
            String nama = "Memuat...";
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              nama = snapshot.data!['nama_lengkap'] ?? snapshot.data!['username'] ?? 'TU';
            }
            return Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.shield, size: 40),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Text(nama,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("Kepala TU"),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
        const SizedBox(height: 20),
        menuItem(Icons.notifications, "Notifikasi", SubScreen.notifikasi),
        menuItem(Icons.lock, "Ubah Password", SubScreen.ubahPassword),
        menuItem(Icons.help, "Bantuan", SubScreen.bantuan),
        menuItem(Icons.info, "Tentang Aplikasi", SubScreen.tentang),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text("Keluar"),
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            setState(() => subScreen = SubScreen.logoutConfirm);
          },
        )
      ],
    );
  }

  Widget menuItem(IconData icon, String title, SubScreen target) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        setState(() => subScreen = target);
      },
    );
  }
}