import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  int _nextId = 0;

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> showBellNotification(String tabTitle, {bool playSound = true}) async {
    final android = AndroidNotificationDetails(
      'terminal_bell',
      'Terminal Bell',
      channelDescription: 'Notifications when terminal bell rings',
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
    );
    final details = NotificationDetails(
      android: android,
      iOS: DarwinNotificationDetails(presentSound: playSound),
    );
    await _plugin.show(
      _nextId++,
      tabTitle,
      'Terminal bell',
      details,
    );
  }

  Future<void> showClaudeNotification({
    required String event,
    required String tabTitle,
    String? cwd,
    bool playSound = true,
  }) async {
    final (body, channelSuffix) = switch (event) {
      'stop' => ('Claude 任务完成${cwd != null ? ' - $cwd' : ''}', 'complete'),
      'permission_request' => ('Claude 需要授权${cwd != null ? ' - $cwd' : ''}', 'permission'),
      'stop_failure' => ('Claude 任务失败${cwd != null ? ' - $cwd' : ''}', 'failure'),
      _ => ('Claude: $event${cwd != null ? ' - $cwd' : ''}', 'other'),
    };

    final android = AndroidNotificationDetails(
      'claude_cli_$channelSuffix',
      'Claude CLI',
      channelDescription: 'Notifications from Claude CLI running on remote servers',
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
    );
    final details = NotificationDetails(
      android: android,
      iOS: DarwinNotificationDetails(presentSound: playSound),
    );
    await _plugin.show(
      _nextId++,
      tabTitle,
      body,
      details,
    );
  }
}
