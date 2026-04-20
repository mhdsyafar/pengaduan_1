import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Menggunakan URL Server yang di-deploy di Render
  static String get baseUrl {
    return 'https://expressbackend-xe83.onrender.com/api';
  }

  /// Login ke backend Express
  /// Mengirim username & password, menerima JWT token + data user
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Simpan data login ke memori lokal
        final prefs = await SharedPreferences.getInstance();
        final userData = data['data'];

        await prefs.setString('token', userData['token']);
        await prefs.setInt('id_user', userData['id_user']);
        await prefs.setString('username', userData['username']);
        await prefs.setString('nama_lengkap', userData['nama_lengkap']);
        await prefs.setString('email', userData['email']);
        await prefs.setInt('id_role', userData['id_role']);

        if (userData['kelas'] != null) {
          await prefs.setString('kelas', userData['kelas']);
        } else {
          await prefs.remove('kelas');
        }

        if (userData['no_hp'] != null) {
          await prefs.setString('no_hp', userData['no_hp']);
        } else {
          await prefs.remove('no_hp');
        }

        return {'success': true, 'data': userData};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// AMBIL TOKEN UNTUK REQUEST API LAINNYA
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// AMBIL INFO USER YG LOGIN
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    return {
      'id_user': prefs.getInt('id_user'),
      'username': prefs.getString('username'),
      'nama_lengkap': prefs.getString('nama_lengkap'),
      'email': prefs.getString('email'),
      'id_role': prefs.getInt('id_role'),
      'kelas': prefs.getString('kelas'),
      'no_hp': prefs.getString('no_hp'),
    };
  }

  /// LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Hapus kredensial login saja, pertahankan profile_pic_* dan pengaturan notifikasi
    final keysToRemove = [
      'token', 'id_user', 'username', 'nama_lengkap', 
      'email', 'id_role', 'kelas', 'no_hp'
    ];
    
    for (String key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  /// AMBIL DATA PROFIL SENDIRI DARI BACKEND
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// UPDATE PROFIL SENDIRI
  static Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> body) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan'};

      final response = await http.put(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        final userData = data['data'];
        await prefs.setString('nama_lengkap', userData['nama_lengkap']);
        await prefs.setString('email', userData['email']);
        if (userData['no_hp'] != null) {
          await prefs.setString('no_hp', userData['no_hp']);
        }
        return {'success': true, 'data': userData};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal update profil'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// UBAH PASSWORD
  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak ditemukan'};

      final response = await http.put(
        Uri.parse('$baseUrl/auth/me/password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] == true,
        'message': data['message'] ?? (data['success'] == true ? 'Password berhasil diubah' : 'Gagal ubah password')
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// AMBIL DAFTAR PENGADUAN
  static Future<Map<String, dynamic>> getAllPengaduan({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/pengaduan?page=$page&limit=$limit'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data pengaduan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// BUAT PENGADUAN BARU
  static Future<Map<String, dynamic>> createPengaduan(
    String judul,
    String isi,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/pengaduan'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'judul_pengaduan': judul, 'isi_pengaduan': isi}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat pengaduan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// UPDATE STATUS PENGADUAN
  static Future<Map<String, dynamic>> updateStatusPengaduan(
    String idPengaduan,
    String status,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .put(
            Uri.parse('$baseUrl/pengaduan/$idPengaduan/status'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// GET TANGGAPAN
  static Future<Map<String, dynamic>> getTanggapan(String idPengaduan) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/tanggapan/$idPengaduan'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil tanggapan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// CREAT TEXT TANGGAPAN
  static Future<Map<String, dynamic>> createTanggapan(
    String idPengaduan,
    String isiTanggapan,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/tanggapan/$idPengaduan'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'isi_tanggapan': isiTanggapan}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat tanggapan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// GET SEMUA DAFTAR ORANG TUA
  static Future<Map<String, dynamic>> getAllOrangtua() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/orangtua'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data orangtua',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }

  /// BUAT ORANG TUA BARU
  static Future<Map<String, dynamic>> createOrangtua(
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/orangtua'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat orangtua',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }

  /// UPDATE ORANG TUA
  static Future<Map<String, dynamic>> updateOrangtua(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .put(
            Uri.parse('$baseUrl/orangtua/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal update orangtua',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }

  /// DELETE ORANG TUA
  static Future<Map<String, dynamic>> deleteOrangtua(int id) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .delete(
            Uri.parse('$baseUrl/orangtua/$id'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus orangtua',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }

  /// GET SEMUA SISWA
  static Future<Map<String, dynamic>> getAllSiswa() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/siswa'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data siswa',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }

  /// CREAT SISWA BARU
  static Future<Map<String, dynamic>> createSiswa(
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/siswa'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat data siswa',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }

  /// UPDATE SISWA
  static Future<Map<String, dynamic>> updateSiswa(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .put(
            Uri.parse('$baseUrl/siswa/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui data siswa',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }

  /// DELETE SISWA
  static Future<Map<String, dynamic>> deleteSiswa(int id) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .delete(
            Uri.parse('$baseUrl/siswa/$id'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus data siswa',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }

  /// GET SEMUA DAFTAR USER
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/users'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data user',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }

  /// BUAT USER BARU
  static Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if ((response.statusCode == 201 || response.statusCode == 200) &&
          data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat user',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }

  /// UPDATE USER
  static Future<Map<String, dynamic>> updateUser(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .put(
            Uri.parse('$baseUrl/users/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal update user',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }

  /// DELETE USER
  static Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http
          .delete(
            Uri.parse('$baseUrl/users/$id'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus user',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung: $e'};
    }
  }
}

