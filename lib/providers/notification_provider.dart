import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// Notification ViewModel managing unread badges and live notification feed
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;

  List<NotificationModel> _notifications = [];

  NotificationProvider({NotificationService? notificationService})
      : _notificationService =
            notificationService ?? NotificationService() {
    _notifications = _notificationService.notifications;
    _notificationService.notificationStream.listen((list) {
      _notifications = list;
      notifyListeners();
    });
  }

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notificationService.unreadCount;

  void markAllAsRead() {
    _notificationService.markAllAsRead();
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String body,
    required String type,
  }) {
    _notificationService.addNotification(
      title: title,
      body: body,
      type: type,
    );
  }
}
