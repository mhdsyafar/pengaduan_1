import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ProfileImageService {
  static Future<File?> loadProfileImage() async {
    final user = await ApiService.getUserData();
    if (user != null && user['id_user'] != null) {
      final id = user['id_user'];
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString('profile_pic_$id');
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
           return file;
        }
      }
    }
    return null;
  }

  static Future<File?> pickAndSaveImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final user = await ApiService.getUserData();
      if (user != null && user['id_user'] != null) {
        final id = user['id_user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_pic_$id', pickedFile.path);
      }
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<void> removeProfileImage() async {
    final user = await ApiService.getUserData();
    if (user != null && user['id_user'] != null) {
      final id = user['id_user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_pic_$id');
    }
  }
}
