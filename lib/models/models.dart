enum StatusPetugas { aktif, nonaktif }
enum StatusPengaduan { masuk, diproses, selesai, ditolak }
enum Prioritas { rendah, sedang, tinggi }

class Petugas {
  final String id;
  String nama;
  String nip;
  String jabatan;
  String email;
  String telepon;
  StatusPetugas status;
  String tanggalDibuat;

  Petugas({
    required this.id,
    required this.nama,
    required this.nip,
    required this.jabatan,
    required this.email,
    required this.telepon,
    required this.status,
    required this.tanggalDibuat,
  });
}

class Pengadu {
  final String id;
  final String nama;
  final String nik;
  final String alamat;
  final String telepon;
  final String email;
  final String tanggalDaftar;

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

class Pengaduan {
  final String id;
  final String pengaduId;
  final String namaPengadu;
  final String judul;
  final String isi;
  final String kategori;
  final StatusPengaduan status;
  final String tanggal;
  final Prioritas prioritas;

  Pengaduan({
    required this.id,
    required this.pengaduId,
    required this.namaPengadu,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.status,
    required this.tanggal,
    required this.prioritas,
  });
}