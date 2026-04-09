import '../models/models.dart';

final List<Petugas> dummyPetugas = [
  Petugas(
    id: 'P001',
    nama: 'Ahmad Fauzi',
    nip: '198501012010011001',
    jabatan: 'Kepala TU',
    email: 'ahmad@gov.id',
    telepon: '081234567890',
    status: StatusPetugas.aktif,
    tanggalDibuat: '2024-01-15',
  ),
];

final List<Pengadu> dummyPengadu = [
  Pengadu(
    id: 'PD001',
    nama: 'Rina Marlina',
    nik: '3201012345670001',
    alamat: 'Jl. Merdeka',
    telepon: '082111222333',
    email: 'rina@email.com',
    tanggalDaftar: '2024-06-01',
  ),
];

final List<Pengaduan> dummyPengaduan = [
  Pengaduan(
    id: 'ADU001',
    pengaduId: 'PD001',
    namaPengadu: 'Rina Marlina',
    judul: 'Jalan Rusak',
    isi: 'Jalan berlubang',
    kategori: 'Infrastruktur',
    status: StatusPengaduan.masuk,
    tanggal: '2024-07-01',
    prioritas: Prioritas.tinggi,
  ),
];