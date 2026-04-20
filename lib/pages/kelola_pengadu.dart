import 'package:flutter/material.dart';
import '../services/api_service.dart';

class KelolaPengaduPage extends StatefulWidget {
  const KelolaPengaduPage({super.key});

  @override
  State<KelolaPengaduPage> createState() => _KelolaPengaduPageState();
}

class _KelolaPengaduPageState extends State<KelolaPengaduPage> {
  final TextEditingController searchCtrl = TextEditingController();

  List<dynamic> orangtua = [];
  List<dynamic> filtered = [];
  List<dynamic> siswaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchCtrl.addListener(_onSearch);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final res = await ApiService.getAllOrangtua();
    final resSiswa = await ApiService.getAllSiswa();

    if (res['success']) {
      setState(() {
        orangtua = res['data'];
        filtered = orangtua;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal memuat orang tua')),
        );
      }
    }

    if (resSiswa['success']) {
      setState(() {
        siswaList = resSiswa['data'];
      });
    }

    setState(() => isLoading = false);
  }

  void _onSearch() {
    final q = searchCtrl.text.toLowerCase();
    setState(() {
      filtered = orangtua.where((p) {
        final nama = p['User']['nama_lengkap']?.toLowerCase() ?? '';
        final username = p['User']['username']?.toLowerCase() ?? '';
        return nama.contains(q) || username.contains(q);
      }).toList();
    });
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Orang Tua'),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final res = await ApiService.deleteOrangtua(id);
              if (!context.mounted) return;
              if (res['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Berhasil menghapus orang tua')),
                );
                _loadData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'Gagal menghapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showForm(BuildContext context, {Map<String, dynamic>? data}) {
    final bool isEdit = data != null;

    final namaCtrl = TextEditingController(
      text: isEdit ? data['User']['nama_lengkap'] : '',
    );
    final usernameCtrl = TextEditingController(
      text: isEdit ? data['User']['username'] : '',
    );
    final passwordCtrl = TextEditingController();
    final emailCtrl = TextEditingController(
      text: isEdit ? data['User']['email'] : '',
    );
    final noHpCtrl = TextEditingController(
      text: isEdit ? data['User']['no_hp'] : '',
    );

    String? selectedHubungan = isEdit ? data['hubungan'] : 'ayah';
    int? selectedSiswa = isEdit
        ? data['id_siswa']
        : (siswaList.isNotEmpty ? siswaList[0]['id_siswa'] : null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEdit ? "Edit Orang Tua" : "Tambah Orang Tua",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: namaCtrl,
                      decoration: const InputDecoration(
                        labelText: "Nama Lengkap *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Username *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: isEdit
                            ? "Password (Kosongi jika tidak diubah)"
                            : "Password *",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email *",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noHpCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "No. HP",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Hubungan",
                        border: OutlineInputBorder(),
                      ),
                      initialValue: selectedHubungan,
                      items: ['ayah', 'ibu', 'wali'].map((h) {
                        return DropdownMenuItem(
                          value: h,
                          child: Text(h.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateModal(() => selectedHubungan = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: "Data Siswa",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedSiswa,
                      isExpanded: true,
                      items: siswaList.map((s) {
                        return DropdownMenuItem<int>(
                          value: s['id_siswa'],
                          child: Text(
                            "${s['nama_siswa']} (Kelas ${s['kelas']})",
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateModal(() => selectedSiswa = val);
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        if (namaCtrl.text.isEmpty ||
                            usernameCtrl.text.isEmpty ||
                            emailCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Nama, Username, dan Email wajib diisi',
                              ),
                            ),
                          );
                          return;
                        }
                        if (!isEdit && passwordCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password wajib diisi untuk data baru',
                              ),
                            ),
                          );
                          return;
                        }
                        if (selectedSiswa == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data Siswa wajib dipilih'),
                            ),
                          );
                          return;
                        }

                        final payload = {
                          "nama_lengkap": namaCtrl.text,
                          "username": usernameCtrl.text,
                          "email": emailCtrl.text,
                          "no_hp": noHpCtrl.text,

                          "hubungan": selectedHubungan,
                          "id_siswa": selectedSiswa,
                        };

                        if (passwordCtrl.text.isNotEmpty) {
                          payload["password"] = passwordCtrl.text;
                        }

                        Navigator.pop(context);
                        setState(() => isLoading = true);

                        final res = isEdit
                            ? await ApiService.updateOrangtua(
                                data['id_orangtua'],
                                payload,
                              )
                            : await ApiService.createOrangtua(payload);

                        if (!context.mounted) return;

                        if (res['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit
                                    ? 'Berhasil update'
                                    : 'Berhasil menambah orang tua',
                              ),
                            ),
                          );
                          _loadData();
                        } else {
                          setState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                res['message'] ?? 'Terjadi kesalahan',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Simpan Data",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kelola Orang Tua",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadData(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showForm(context),
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Orang Tua',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Cari nama atau username...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text("Tidak ada data ditemukan"))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final p = filtered[index];
                              final user = p['User'] ?? {};
                              final siswa = p['Siswa'] ?? {};
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                child: InkWell(
                                  onTap: () => showForm(context, data: p),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.blue.shade100,
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user['nama_lengkap'] ??
                                                    'Tanpa Nama',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Username: ${user['username'] ?? '-'}",
                                              ),
                                              Text(
                                                "Siswa: ${siswa['nama_siswa'] ?? '-'} (${p['hubungan']?.toUpperCase() ?? '-'})",
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _showDeleteDialog(
                                            p['id_orangtua'],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
}
