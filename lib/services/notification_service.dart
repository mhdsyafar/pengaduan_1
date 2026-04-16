import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'pengaduan_baru', 'status_update', 'tanggapan_baru'
  final String? referenceId;
  final String timestamp;
  bool isRead;
  bool isDeleted;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    required this.timestamp,
    this.isRead = false,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type,
    'referenceId': referenceId,
    'timestamp': timestamp,
    'isRead': isRead,
    'isDeleted': isDeleted,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    type: json['type'],
    referenceId: json['referenceId'],
    timestamp: json['timestamp'],
    isRead: json['isRead'] ?? false,
    isDeleted: json['isDeleted'] ?? false,
  );
}

class NotificationService {
  static const _notifKey = 'app_notifications';
  static const _notifEnabledKey = 'notif_enabled';
  static const _lastCheckKey = 'notif_last_check';

  /// Check if notifications are enabled
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notifEnabledKey) ?? true;
  }

  /// Toggle notifications on/off
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifEnabledKey, enabled);
  }

  /// Get all stored notifications (internal)
  static Future<List<AppNotification>> _getAllStoredNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notifKey);
    if (raw == null) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((e) => AppNotification.fromJson(e)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get active visible notifications
  static Future<List<AppNotification>> getNotifications() async {
    final all = await _getAllStoredNotifications();
    return all.where((n) => !n.isDeleted).toList();
  }

  /// Get unread count
  static Future<int> getUnreadCount() async {
    final enabled = await isEnabled();
    if (!enabled) return 0;
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  /// Save notifications list
  static Future<void> _saveNotifications(List<AppNotification> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notifKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  /// Add a new notification
  static Future<void> addNotification(AppNotification notif) async {
    final enabled = await isEnabled();
    if (!enabled) return;

    final list = await _getAllStoredNotifications();
    // avoid duplicates (including soft-deleted ones so they don't pop up again)
    if (list.any((n) => n.id == notif.id)) return;
    list.insert(0, notif);
    // keep max 100 notifications
    if (list.length > 100) {
      list.removeRange(100, list.length);
    }
    await _saveNotifications(list);
  }

  /// Mark notification as read
  static Future<void> markAsRead(String id) async {
    final list = await _getAllStoredNotifications();
    for (var n in list) {
      if (n.id == id) n.isRead = true;
    }
    await _saveNotifications(list);
  }

  /// Mark all as read
  static Future<void> markAllAsRead() async {
    final list = await _getAllStoredNotifications();
    for (var n in list) {
      if (!n.isDeleted) n.isRead = true;
    }
    await _saveNotifications(list);
  }

  /// Delete a notification
  static Future<void> deleteNotification(String id) async {
    final list = await _getAllStoredNotifications();
    for (var n in list) {
      if (n.id == id) n.isDeleted = true;
    }
    await _saveNotifications(list);
  }

  /// Clear all notifications
  static Future<void> clearAll() async {
    final list = await _getAllStoredNotifications();
    for (var n in list) {
      n.isDeleted = true;
    }
    await _saveNotifications(list);
  }

  /// Check for new pengaduan & tanggapan from backend and generate notifications
  static Future<int> checkForUpdates() async {
    final enabled = await isEnabled();
    if (!enabled) return 0;

    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString(_lastCheckKey);
    final now = DateTime.now().toIso8601String();

    int newCount = 0;

    try {
      // Check for pengaduan updates
      final pengaduanRes = await ApiService.getAllPengaduan();
      if (pengaduanRes['success'] == true) {
        final List pengaduanList = pengaduanRes['data'] as List;

        for (var p in pengaduanList) {
          final tanggal = p['tanggal_pengaduan'] ?? '';
          final status = p['status'] ?? '';
          final judul = p['judul_pengaduan'] ?? 'Tanpa Judul';
          final idPengaduan = p['id_pengaduan']?.toString() ?? '';

          String namaPengadu = 'Seseorang';
          if (p['Orangtua'] != null && p['Orangtua']['User'] != null) {
            namaPengadu = p['Orangtua']['User']['nama_lengkap'] ?? 'Seseorang';
          }

          // New pengaduan notification
          if (lastCheck == null || tanggal.compareTo(lastCheck) > 0) {
            final notifId = 'pengaduan_$idPengaduan';
            final existingList = await _getAllStoredNotifications();
            if (!existingList.any((n) => n.id == notifId)) {
              final notif = AppNotification(
                id: notifId,
                title: 'Pengaduan Baru',
                body: '$namaPengadu mengajukan: $judul',
                type: 'pengaduan_baru',
                referenceId: idPengaduan,
                timestamp: tanggal.isNotEmpty ? tanggal : now,
                // Removed isRead override so testing across logins shows as unread
              );
              await addNotification(notif);
              if (lastCheck != null) newCount++;
            }
          }

          // Status change notification
          if (status == 'diproses' || status == 'selesai' || status == 'ditolak') {
            final statusNotifId = 'status_${idPengaduan}_$status';
            final existingList = await _getAllStoredNotifications();
            if (!existingList.any((n) => n.id == statusNotifId)) {
              String statusLabel = status == 'diproses'
                  ? 'sedang diproses'
                  : status == 'selesai'
                      ? 'telah selesai'
                      : 'ditolak';
              final notif = AppNotification(
                id: statusNotifId,
                title: 'Status Diperbarui',
                body: 'Pengaduan "$judul" $statusLabel',
                type: 'status_update',
                referenceId: idPengaduan,
                timestamp: now,
                // Removed isRead override so testing across logins shows as unread
              );
              await addNotification(notif);
              if (lastCheck != null) newCount++;
            }
          }
        }
      }
    } catch (_) {
      // Silently fail on network errors
    }

    await prefs.setString(_lastCheckKey, now);
    return newCount;
  }
}
