import 'package:flutter/material.dart';
import 'navbar_kepsek.dart';
// =====================
// MODEL PENGADU
// =====================
class Pengadu {
  final String id;
  String nama;
  String nik;
  String alamat;
  String telepon;
  String email;
  String tanggalDaftar;

  Pengadu({
    required this.id,
    required this.nama,
    required this.nik,
    required this.alamat,
    required this.telepon,
    required this.email,
    required this.tanggalDaftar,
  });
}

// =====================
// PAGE
// =====================
class KelolaPengaduPage extends StatefulWidget {
  const KelolaPengaduPage({super.key});

  @override
  State<KelolaPengaduPage> createState() => _KelolaPengaduPageState();
}

class _KelolaPengaduPageState extends State<KelolaPengaduPage> {
  final TextEditingController searchCtrl = TextEditingController();

  List<Pengadu> pengadu = [];
  List<Pengadu> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = pengadu;
    searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = searchCtrl.text.toLowerCase();
    setState(() {
      filtered = pengadu
          .where((p) =>
              p.nama.toLowerCase().contains(q) ||
              p.nik.contains(q))
          .toList();
    });
  }

  // =====================
  // ADD
  // =====================
  void tambahPengadu(Pengadu p) {
    setState(() {
      pengadu.add(p);
      filtered = pengadu;
    });
  }

  // =====================
  // EDIT
  // =====================
  void editPengadu(Pengadu p) {
    setState(() {
      final index = pengadu.indexWhere((e) => e.id == p.id);
      if (index != -1) pengadu[index] = p;
      filtered = pengadu;
    });
  }

  // =====================
  // DELETE
  // =====================
  void hapusPengadu(String id) {
    setState(() {
      pengadu.removeWhere((p) => p.id == id);
      filtered = pengadu;
    });
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Pengadu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showForm(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SEARCH
            TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Cari nama atau NIK...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // LIST
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text("Tidak ada data ditemukan"),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              p.nama,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "NIK: ${p.nik.substring(0, 6)}...${p.nik.substring(p.nik.length - 4)}",
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.more_vert, size: 18),
                                Text(
                                  p.tanggalDaftar,
                                  style: const TextStyle(fontSize: 10),
                                )
                              ],
                            ),
                            onTap: () =>
                                showDetail(context, p),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  // =====================
  // FORM TAMBAH
  // =====================
  void showForm(BuildContext context) {
    final namaCtrl = TextEditingController();
    final nikCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();
    final telpCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Daftarkan Pengadu Baru",
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              input(namaCtrl, "Nama Lengkap *"),
              input(nikCtrl, "NIK *"),
              input(alamatCtrl, "Alamat"),
              input(telpCtrl, "No. Telepon"),
              input(emailCtrl, "Email"),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (namaCtrl.text.isEmpty ||
                      nikCtrl.text.isEmpty) return;

                  tambahPengadu(
                    Pengadu(
                      id: "PD${pengadu.length + 1}",
                      nama: namaCtrl.text,
                      nik: nikCtrl.text,
                      alamat: alamatCtrl.text,
                      telepon: telpCtrl.text,
                      email: emailCtrl.text,
                      tanggalDaftar:
                          DateTime.now().toString().split(" ")[0],
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Daftarkan Pengadu"),
              )
            ],
          ),
        );
      },
    );
  }

  // =====================
  // DETAIL / EDIT
  // =====================
  void showDetail(BuildContext context, Pengadu p) {
    bool editMode = false;

    final namaCtrl = TextEditingController(text: p.nama);
    final nikCtrl = TextEditingController(text: p.nik);
    final alamatCtrl = TextEditingController(text: p.alamat);
    final telpCtrl = TextEditingController(text: p.telepon);
    final emailCtrl = TextEditingController(text: p.email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    editMode ? "Edit Pengadu" : "Detail Pengadu",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  editMode
                      ? Column(
                          children: [
                            input(namaCtrl, "Nama"),
                            input(nikCtrl, "NIK"),
                            input(alamatCtrl, "Alamat"),
                            input(telpCtrl, "Telepon"),
                            input(emailCtrl, "Email"),
                            ElevatedButton(
                              onPressed: () {
                                editPengadu(
                                  Pengadu(
                                    id: p.id,
                                    nama: namaCtrl.text,
                                    nik: nikCtrl.text,
                                    alamat: alamatCtrl.text,
                                    telepon: telpCtrl.text,
                                    email: emailCtrl.text,
                                    tanggalDaftar: p.tanggalDaftar,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              child: const Text("Simpan Perubahan"),
                            )
                          ],
                        )
                      : Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text("Nama: ${p.nama}"),
                            Text("NIK: ${p.nik}"),
                            Text("Alamat: ${p.alamat}"),
                            Text("Telepon: ${p.telepon}"),
                            Text("Email: ${p.email}"),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setModal(() => editMode = true);
                                    },
                                    child: const Text("Edit"),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () {
                                      hapusPengadu(p.id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Hapus"),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =====================
  // INPUT HELPER
  // =====================
  Widget input(TextEditingController c, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}