import 'package:flutter/material.dart';
import '../services/api_service.dart';

class KelolaPetugasPage extends StatefulWidget {
  const KelolaPetugasPage({super.key});

  @override
  State<KelolaPetugasPage> createState() => _KelolaPetugasPageState();
}

class _KelolaPetugasPageState extends State<KelolaPetugasPage> {
  final TextEditingController searchCtrl = TextEditingController();

  List<dynamic> users = [];
  List<dynamic> filtered = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchCtrl.addListener(_onSearch);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final res = await ApiService.getAllUsers();
    
    if (res['success']) {
      setState(() {
        // Filter out orangtua (id_role = 3) as per request "kelola user selain orangtua"
        users = (res['data'] as List).where((u) => u['id_role'] != 3).toList();
        filtered = users;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal memuat pengguna')),
        );
      }
    }
    setState(() => isLoading = false);
  }

  void _onSearch() {
    final q = searchCtrl.text.toLowerCase();
    setState(() {
      filtered = users.where((u) {
        final nama = u['nama_lengkap']?.toLowerCase() ?? '';
        final username = u['username']?.toLowerCase() ?? '';
        return nama.contains(q) || username.contains(q);
      }).toList();
    });
  }

  String _getRoleName(int idRole) {
    switch (idRole) {
      case 1: return 'Admin / TU';
      case 2: return 'Guru';
      case 4: return 'Kepala Sekolah';
      default: return 'User';
    }
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
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
              setState(() => isLoading = true);
              final res = await ApiService.deleteUser(id);
              if (!context.mounted) return;
              if (res['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Berhasil menghapus pengguna')),
                );
                _loadData();
              } else {
                setState(() => isLoading = false);
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

    final namaCtrl = TextEditingController(text: isEdit ? data['nama_lengkap'] : '');
    final usernameCtrl = TextEditingController(text: isEdit ? data['username'] : '');
    final passwordCtrl = TextEditingController();
    final emailCtrl = TextEditingController(text: isEdit ? data['email'] : '');
    final noHpCtrl = TextEditingController(text: isEdit ? data['no_hp'] : '');
    final nipCtrl = TextEditingController(text: isEdit && data['Guru'] != null ? data['Guru']['nip'] ?? '' : '');
    final kelasCtrl = TextEditingController(text: isEdit && data['Guru'] != null ? data['Guru']['kelas'] ?? '' : '');
    
    int selectedRole = isEdit ? data['id_role'] : 2;

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
                      isEdit ? "Edit Pengguna" : "Tambah Pengguna Baru",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: namaCtrl,
                      decoration: const InputDecoration(labelText: "Nama Lengkap *", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(labelText: "Username *", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: isEdit ? "Password (Kosongkan jika tidak diubah)" : "Password *",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: "Email *", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noHpCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: "No. HP", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: "Role/Peran", border: OutlineInputBorder()),
                      initialValue: selectedRole,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Admin / TU')),
                        DropdownMenuItem(value: 2, child: Text('Guru')),
                        DropdownMenuItem(value: 4, child: Text('Kepala Sekolah')),
                      ],
                      onChanged: (val) {
                         if (val != null) setStateModal(() => selectedRole = val);
                      },
                    ),
                    // Field NIP & Kelas hanya tampil jika role = Guru
                    if (selectedRole == 2) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: nipCtrl,
                        decoration: const InputDecoration(labelText: "NIP *", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: kelasCtrl,
                        decoration: const InputDecoration(labelText: "Kelas (Opsional)", hintText: "Misal: 6A", border: OutlineInputBorder()),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        if (namaCtrl.text.isEmpty || usernameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nama, Username, dan Email wajib diisi')),
                          );
                          return;
                        }
                        if (!isEdit && passwordCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password wajib diisi untuk data baru')),
                          );
                          return;
                        }
                        // Validasi NIP wajib jika role Guru
                        if (selectedRole == 2 && nipCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('NIP wajib diisi untuk role Guru')),
                          );
                          return;
                        }

                        final payload = {
                          "nama_lengkap": namaCtrl.text,
                          "username": usernameCtrl.text,
                          "email": emailCtrl.text,
                          "no_hp": noHpCtrl.text,
                          "id_role": selectedRole,
                        };

                        if (passwordCtrl.text.isNotEmpty) {
                          payload["password"] = passwordCtrl.text;
                        }

                        // Sertakan NIP & Kelas jika role Guru
                        if (selectedRole == 2) {
                          payload["nip"] = nipCtrl.text.trim();
                          if (kelasCtrl.text.trim().isNotEmpty) {
                            payload["kelas"] = kelasCtrl.text.trim();
                          }
                        }

                        Navigator.pop(context);
                        setState(() => isLoading = true);

                        final res = isEdit
                            ? await ApiService.updateUser(data['id_user'], payload)
                            : await ApiService.createUser(payload);

                        if (!context.mounted) return;

                        if (res['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isEdit ? 'Berhasil mengupdate pengguna' : 'Berhasil menambah pengguna')),
                          );
                          _loadData();
                        } else {
                          setState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res['message'] ?? 'Terjadi kesalahan')),
                          );
                        }
                      },
                      child: const Text("Simpan Data", style: TextStyle(fontSize: 16)),
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
        title: const Text("Kelola Pengguna", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadData(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showForm(context),
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Pengguna', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                              final u = filtered[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                child: InkWell(
                                  onTap: () => showForm(context, data: u),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.indigo.shade100,
                                          child: const Icon(Icons.person, color: Colors.indigo),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                u['nama_lengkap'] ?? 'Tanpa Nama',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              const SizedBox(height: 4),
                                              Text("Username: ${u['username'] ?? '-'}"),
                                              Text("Peran: ${_getRoleName(u['id_role'])}", style: const TextStyle(color: Colors.blue)),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _showDeleteDialog(u['id_user']),
                                        )
                                      ],
                                    ),
                                  ),
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
}