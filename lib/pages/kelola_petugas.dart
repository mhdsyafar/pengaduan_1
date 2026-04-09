import 'package:flutter/material.dart';
import '../models/models.dart';

// =====================
// PAGE
// =====================
class KelolaPetugasPage extends StatefulWidget {
  final List<Petugas> petugas;
  final Function(List<Petugas>) setPetugas;

  const KelolaPetugasPage({
    super.key,
    required this.petugas,
    required this.setPetugas,
  });

  @override
  State<KelolaPetugasPage> createState() => _KelolaPetugasPageState();
}

class _KelolaPetugasPageState extends State<KelolaPetugasPage> {
  final searchCtrl = TextEditingController();

  Petugas? selected;
  bool showForm = false;
  bool editMode = false;

  final namaCtrl = TextEditingController();
  final nipCtrl = TextEditingController();
  final jabatanCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telpCtrl = TextEditingController();

  List<Petugas> get filtered {
    final q = searchCtrl.text.toLowerCase();
    return widget.petugas.where((p) {
      return p.nama.toLowerCase().contains(q) ||
          p.nip.contains(q) ||
          p.jabatan.toLowerCase().contains(q);
    }).toList();
  }

  // =====================
  // ADD
  // =====================
  void addPetugas() {
    if (namaCtrl.text.isEmpty || nipCtrl.text.isEmpty) return;

    final newPetugas = Petugas(
      id: "P${(widget.petugas.length + 1).toString().padLeft(3, '0')}",
      nama: namaCtrl.text,
      nip: nipCtrl.text,
      jabatan: jabatanCtrl.text,
      email: emailCtrl.text,
      telepon: telpCtrl.text,
      status: StatusPetugas.aktif,
      tanggalDibuat: DateTime.now().toString().split(" ")[0],
    );

    widget.setPetugas([...widget.petugas, newPetugas]);
    clearForm();
    Navigator.pop(context);
  }

  // =====================
  // EDIT
  // =====================
  void saveEdit() {
    if (selected == null) return;

    widget.setPetugas(
      widget.petugas.map((p) {
        if (p.id == selected!.id) {
          return Petugas(
            id: p.id,
            nama: namaCtrl.text,
            nip: nipCtrl.text,
            jabatan: jabatanCtrl.text,
            email: emailCtrl.text,
            telepon: telpCtrl.text,
            status: p.status,
            tanggalDibuat: p.tanggalDibuat,
          );
        }
        return p;
      }).toList(),
    );

    Navigator.pop(context);
  }

  void deletePetugas(String id) {
    widget.setPetugas(
      widget.petugas.where((p) => p.id != id).toList(),
    );
    Navigator.pop(context);
  }

  void toggleStatus(String id) {
    widget.setPetugas(
      widget.petugas.map((p) {
        if (p.id == id) {
          p.status = p.status == StatusPetugas.aktif
              ? StatusPetugas.nonaktif
              : StatusPetugas.aktif;
        }
        return p;
      }).toList(),
    );
    setState(() {});
  }

  void openDetail(Petugas p) {
    selected = p;
    editMode = false;
    namaCtrl.text = p.nama;
    nipCtrl.text = p.nip;
    jabatanCtrl.text = p.jabatan;
    emailCtrl.text = p.email;
    telpCtrl.text = p.telepon;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => buildDetailModal(),
    );
  }

  void clearForm() {
    namaCtrl.clear();
    nipCtrl.clear();
    jabatanCtrl.clear();
    emailCtrl.clear();
    telpCtrl.clear();
    editMode = false;
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Petugas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              clearForm();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => buildFormModal(),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Cari nama, NIP, atau jabatan...",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("Tidak ada data ditemukan"))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (c, i) {
                        final p = filtered[i];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(p.nama)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: p.status == StatusPetugas.aktif
                                        ? Colors.green.shade100
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    p.status == StatusPetugas.aktif ? 'aktif' : 'nonaktif',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                )
                              ],
                            ),
                            subtitle:
                                Text("${p.jabatan} • ${p.nip}"),
                            trailing:
                                const Icon(Icons.more_vert),
                            onTap: () => openDetail(p),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================
  // FORM MODAL
  // =====================
  Widget buildFormModal() {
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
            "Tambah Petugas Baru",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          input(namaCtrl, "Nama Lengkap *"),
          input(nipCtrl, "NIP *"),
          input(jabatanCtrl, "Jabatan"),
          input(emailCtrl, "Email"),
          input(telpCtrl, "No. Telepon"),
          ElevatedButton(
            onPressed: addPetugas,
            child: const Text("Simpan Petugas"),
          )
        ],
      ),
    );
  }

  // =====================
  // DETAIL MODAL
  // =====================
  Widget buildDetailModal() {
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
          Text(
            editMode ? "Edit Petugas" : "Detail Petugas",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          editMode
              ? Column(
                  children: [
                    input(namaCtrl, "Nama"),
                    input(nipCtrl, "NIP"),
                    input(jabatanCtrl, "Jabatan"),
                    input(emailCtrl, "Email"),
                    input(telpCtrl, "Telepon"),
                    ElevatedButton(
                      onPressed: saveEdit,
                      child: const Text("Simpan Perubahan"),
                    )
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama: ${selected!.nama}"),
                    Text("Jabatan: ${selected!.jabatan}"),
                    Text("NIP: ${selected!.nip}"),
                    Text("Email: ${selected!.email}"),
                    Text("Telepon: ${selected!.telepon}"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => editMode = true),
                            child: const Text("Edit"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                toggleStatus(selected!.id),
                            child: Text(selected!.status == StatusPetugas.aktif
                                ? "Nonaktifkan"
                                : "Aktifkan"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () =>
                              deletePetugas(selected!.id),
                          child: const Text("Hapus"),
                        ),
                      ],
                    )
                  ],
                ),
        ],
      ),
    );
  }

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