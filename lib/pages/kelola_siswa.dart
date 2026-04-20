import 'package:flutter/material.dart';
import '../services/api_service.dart';

class KelolaSiswaPage extends StatefulWidget {
  const KelolaSiswaPage({super.key});

  @override
  State<KelolaSiswaPage> createState() => _KelolaSiswaPageState();
}

class _KelolaSiswaPageState extends State<KelolaSiswaPage> {
  static const Color _primary = Color(0xFF0D9488);
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _listSiswa = [];
  List<dynamic> _filteredSiswa = [];
  String _selectedClass = 'Semua';
  bool _isLoading = true;

  final List<String> _classList = ['Semua', '1', '2', '3', '4', '5', '6'];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterSiswa);
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final resSiswa = await ApiService.getAllSiswa();

    if (resSiswa['success'] == true) {
      _listSiswa = resSiswa['data'];
      _filteredSiswa = _listSiswa;
    }
    setState(() => _isLoading = false);
  }

  void _filterSiswa() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSiswa = _listSiswa.where((s) {
        final nama = s['nama_siswa'].toString().toLowerCase();
        final kelas = s['kelas'].toString().toLowerCase();
        final tahun = s['tahun_ajaran'].toString().toLowerCase();
        
        final matchesQuery = nama.contains(query) || kelas.contains(query) || tahun.contains(query);
        final matchesClass = _selectedClass == 'Semua' || s['kelas'].toString() == _selectedClass;
        
        return matchesQuery && matchesClass;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Kelola Data Siswa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(onPressed: _fetchData, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildClassFilter(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredSiswa.isEmpty 
                ? _buildEmptyState()
                : _buildSiswaList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: _primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Siswa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari nama, kelas, atau tahun ajaran...',
          prefixIcon: const Icon(Icons.search_rounded, color: _primary),
          filled: true,
          fillColor: const Color(0xFFF1F3F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildClassFilter() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _classList.length,
        itemBuilder: (context, index) {
          final cls = _classList[index];
          final isSelected = _selectedClass == cls;
          return Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: ChoiceChip(
              label: Text(cls == 'Semua' ? 'Semua' : 'Kelas $cls'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedClass = cls;
                    _filterSiswa();
                  });
                }
              },
              selectedColor: _primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: const Color(0xFFF1F3F5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSiswaList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSiswa.length,
      itemBuilder: (context, index) {
        final s = _filteredSiswa[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person_rounded, color: _primary),
            ),
            title: Text(s['nama_siswa'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Kelas ${s['kelas'] ?? '-'} · TA ${s['tahun_ajaran'] ?? '-'}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow(Icons.class_rounded, 'Kelas', s['kelas'] ?? '-'),
                    const SizedBox(height: 8),
                    _detailRow(Icons.calendar_today_rounded, 'Tahun Ajaran', s['tahun_ajaran'] ?? '-'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showFormDialog(data: s),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primary,
                              side: const BorderSide(color: _primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmDelete(s['id_siswa']),
                            icon: const Icon(Icons.delete_rounded, size: 18),
                            label: const Text('Hapus'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Siswa tidak ditemukan', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        ],
      ),
    );
  }

  void _showFormDialog({Map<String, dynamic>? data}) {
    final bool isEdit = data != null;
    final namaCtrl = TextEditingController(text: isEdit ? data['nama_siswa'] : '');
    String selectedKelas = isEdit ? data['kelas'].toString() : '1';
    final tahunCtrl = TextEditingController(text: isEdit ? data['tahun_ajaran'] : '');

    final availableClasses = ['1', '2', '3', '4', '5', '6'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? 'Edit Data Siswa' : 'Tambah Siswa Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap *', hintText: 'Masukkan nama siswa'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: availableClasses.contains(selectedKelas) ? selectedKelas : availableClasses.first,
                decoration: const InputDecoration(labelText: 'Kelas *', border: OutlineInputBorder()),
                items: availableClasses.map((c) => DropdownMenuItem(value: c, child: Text('Kelas $c'))).toList(),
                onChanged: (val) => selectedKelas = val!,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tahunCtrl,
                decoration: const InputDecoration(labelText: 'Tahun Ajaran *', hintText: 'Contoh: 2024/2025', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namaCtrl.text.isEmpty || tahunCtrl.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Harap isi semua data yang bertanda *')),
                );
                return;
              }
              
              final payload = {
                'nama_siswa': namaCtrl.text,
                'kelas': selectedKelas,
                'tahun_ajaran': tahunCtrl.text,
              };

              final res = isEdit 
                ? await ApiService.updateSiswa(data['id_siswa'], payload)
                : await ApiService.createSiswa(payload);

              if (!dialogContext.mounted) return;

              if (res['success'] == true) {
                Navigator.pop(dialogContext);
                _fetchData();
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Data berhasil diupdate' : 'Siswa berhasil ditambah')),
                );
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'Gagal menyimpan data')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Apakah Anda yakin ingin menghapus data siswa ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final res = await ApiService.deleteSiswa(id);
              if (!mounted) return;
              if (res['success'] == true) {
                _fetchData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil dihapus')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'Gagal menghapus data')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
