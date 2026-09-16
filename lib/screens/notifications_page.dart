import 'package:flutter/material.dart';
import '../repositories/notification_repository.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontFamily: 'Inter')),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
        actions: [
          TextButton(
            onPressed: () {
              NotificationRepository.instance.markAllAsRead();
            },
            child: const Text('Mark all as read', style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: NotificationRepository.instance,
        builder: (context, _) {
          final notifications = NotificationRepository.instance.notifications;
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No notifications yet', style: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Inter')),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: notif.isRead ? Colors.white : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  border: notif.isRead ? null : Border.all(color: const Color(0xFF1B4332).withOpacity(0.2), width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: notif.isRead ? const Color(0xFFE6E3D8) : const Color(0xFF1B4332),
                    child: Icon(Icons.notifications_active, color: notif.isRead ? Colors.grey : Colors.white),
                  ),
                  title: Text(notif.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: notif.isRead ? Colors.black87 : const Color(0xFF1B4332), fontFamily: 'Inter')),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(notif.message, style: const TextStyle(fontSize: 14, color: Colors.black54, fontFamily: 'Inter')),
                  ),
                  trailing: Text(
                    '${notif.timestamp.day}/${notif.timestamp.month}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
