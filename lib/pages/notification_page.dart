import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _notifEnabled = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final enabled = await NotificationService.isEnabled();
    final list = await NotificationService.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifEnabled = enabled;
      _notifications = list;
      _isLoading = false;
    });
  }

  Future<void> _markAllRead() async {
    await NotificationService.markAllAsRead();
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Semua notifikasi ditandai sudah dibaca'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Semua Notifikasi?'),
        content: const Text('Semua notifikasi akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await NotificationService.clearAll();
      await _loadData();
    }
  }

  Future<void> _deleteNotification(String id) async {
    await NotificationService.deleteNotification(id);
    await _loadData();
  }

  Future<void> _markAsRead(String id) async {
    await NotificationService.markAsRead(id);
    await _loadData();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'pengaduan_baru':
        return Icons.campaign_rounded;
      case 'status_update':
        return Icons.update_rounded;
      case 'tanggapan_baru':
        return Icons.reply_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'pengaduan_baru':
        return const Color(0xFFE03131);
      case 'status_update':
        return const Color(0xFF3B5BDB);
      case 'tanggapan_baru':
        return const Color(0xFF0D9488);
      default:
        return Colors.grey;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'pengaduan_baru':
        return 'Pengaduan Baru';
      case 'status_update':
        return 'Status Update';
      case 'tanggapan_baru':
        return 'Tanggapan Baru';
      default:
        return 'Notifikasi';
    }
  }

  String _timeAgo(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return timestamp.substring(0, 10);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_notifications.isNotEmpty) ...[
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'read_all') _markAllRead();
                if (val == 'clear_all') _clearAll();
              },
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'read_all', child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Tandai semua dibaca', style: TextStyle(fontSize: 13)),
                  ],
                )),
                const PopupMenuItem(value: 'clear_all', child: Row(
                  children: [
                    Icon(Icons.delete_sweep_rounded, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus semua', style: TextStyle(fontSize: 13)),
                  ],
                )),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_notifEnabled
              ? _buildDisabledView()
              : _notifications.isEmpty
                  ? _buildEmptyView()
                  : RefreshIndicator(
                      onRefresh: () async {
                        await NotificationService.checkForUpdates();
                        await _loadData();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notif = _notifications[index];
                          return _buildNotificationCard(notif, index);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif, int index) {
    final color = _colorForType(notif.type);
    final isUnread = !notif.isRead;

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notif.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 300)),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: () => _markAsRead(notif.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUnread ? Colors.white : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: isUnread
                  ? Border.all(color: color.withValues(alpha: 0.3), width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isUnread
                      ? color.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isUnread ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconForType(notif.type), color: color, size: 22),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _labelForType(notif.type),
                              style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _timeAgo(notif.timestamp),
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                          color: const Color(0xFF1C1C3A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notif.body,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Unread indicator
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4, left: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_outlined, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Notifikasi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Notifikasi baru akan muncul di sini',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_paused_rounded, size: 40, color: Colors.orange.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            'Notifikasi Dinonaktifkan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aktifkan notifikasi di halaman Profil',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
