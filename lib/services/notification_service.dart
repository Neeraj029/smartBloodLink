import 'dart:async';
import '../models/notification_model.dart';
import 'mock_data_service.dart';

/// Service managing push and in-app emergency notifications
class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _notificationStream =
      StreamController<List<NotificationModel>>.broadcast();
  Stream<List<NotificationModel>> get notificationStream =>
      _notificationStream.stream;

  List<NotificationModel> get notifications =>
      List.unmodifiable(MockDataService.initialNotifications);

  int get unreadCount =>
      MockDataService.initialNotifications.where((n) => !n.isRead).length;

  /// Dispatch a new notification
  void addNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) {
    final notif = NotificationModel(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      data: data,
    );

    MockDataService.initialNotifications.insert(0, notif);
    _notificationStream.add(MockDataService.initialNotifications);
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < MockDataService.initialNotifications.length; i++) {
      MockDataService.initialNotifications[i] =
          MockDataService.initialNotifications[i].copyWith(isRead: true);
    }
    _notificationStream.add(MockDataService.initialNotifications);
  }
}
