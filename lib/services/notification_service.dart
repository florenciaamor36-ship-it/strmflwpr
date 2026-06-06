import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to relevant screen
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showExpirationNotification({
    required int id,
    required String clientName,
    required String platformName,
    required int daysUntilExpiration,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'expiration_channel',
      'Vencimientos',
      channelDescription: 'Notificaciones de perfiles próximos a vencer',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String body = daysUntilExpiration == 0
        ? '⚠️ $clientName ($platformName) vence HOY'
        : daysUntilExpiration == 1
            ? '⚠️ $clientName ($platformName) vence mañana'
            : '⚠️ $clientName ($platformName) vence en $daysUntilExpiration días';

    await _plugin.show(
      id,
      '🔔 Perfil por vencer',
      body,
      details,
    );
  }

  Future<void> checkAndNotifyExpiringProfiles(
      List<ProfileModel> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    for (int i = 0; i < profiles.length; i++) {
      final profile = profiles[i];
      if (profile.expirationDate == null) continue;
      if (profile.status != ProfileStatus.sold) continue;

      final days = profile.expirationDate!.difference(today).inDays;
      if (days < 0) continue;

      for (final reminderDay in profile.reminderDays) {
        if (days == reminderDay) {
          final notifKey = 'notif_${profile.id}_${todayKey}_$reminderDay';
          final alreadySent = prefs.getBool(notifKey) ?? false;
          if (!alreadySent) {
            await showExpirationNotification(
              id: i * 100 + reminderDay,
              clientName: profile.clientName.isNotEmpty
                  ? profile.clientName
                  : profile.profileName,
              platformName: profile.platformName,
              daysUntilExpiration: days,
            );
            await prefs.setBool(notifKey, true);
          }
        }
      }
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
