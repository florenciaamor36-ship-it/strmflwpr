import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sale_model.dart';
import '../models/profile_model.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import '../firebase_options.dart';

class NotificationService {
  static const String dailyCheckTask = 'dailyExpirationCheck';
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels
    const AndroidNotificationChannel expirationChannel =
        AndroidNotificationChannel(
      AppConstants.expirationChannelId,
      AppConstants.expirationChannelName,
      description: 'Alertas de vencimiento de servicios',
      importance: Importance.high,
    );

    const AndroidNotificationChannel lowStockChannel =
        AndroidNotificationChannel(
      AppConstants.lowStockChannelId,
      AppConstants.lowStockChannelName,
      description: 'Alertas de stock bajo',
      importance: Importance.defaultImportance,
    );

    const AndroidNotificationChannel adminChannel =
        AndroidNotificationChannel(
      'admin_notifications',
      'Alertas Administrativas',
      description: 'Notificaciones enviadas por el administrador',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(expirationChannel);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(lowStockChannel);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(adminChannel);

    // Request FCM permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup FCM listeners
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Get and save token
    _saveFcmToken();
  }

  static Future<void> _saveFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    _showAdminNotification(message);
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handled by system if data contains 'notification' key
  }

  static Future<void> _showAdminNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await _plugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'admin_notifications',
            'Alertas Administrativas',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Navigation handled in app via notification payload
  }

  static Future<void> showExpirationNotification({
    required int id,
    required String clientName,
    required String platformName,
    required int daysRemaining,
  }) async {
    final String title = daysRemaining <= 0
        ? '⚠️ Servicio vencido'
        : '⏰ Servicio por vencer';
    final String body = daysRemaining <= 0
        ? '$clientName - $platformName venció hoy'
        : '$clientName - $platformName vence en $daysRemaining día(s)';

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.expirationChannelId,
          AppConstants.expirationChannelName,
          channelDescription: 'Alertas de vencimiento',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> showLowStockNotification({
    required String platformName,
    required int availableCount,
  }) async {
    final String title = '📦 Stock bajo';
    final String body = availableCount == 0
        ? '$platformName: sin perfiles disponibles'
        : '$platformName: solo $availableCount perfil(es) disponible(s)';

    await _plugin.show(
      platformName.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.lowStockChannelId,
          AppConstants.lowStockChannelName,
          channelDescription: 'Alertas de stock bajo',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Background task — runs via Workmanager
  static Future<void> runBackgroundExpirationCheck() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await initialize();

      final firestore = FirebaseFirestore.instance;

      // Get all active sales
      final salesSnap = await firestore
          .collection(AppConstants.salesCollection)
          .where('status', isEqualTo: 'active')
          .get();

      int notificationId = 1000;

      for (final doc in salesSnap.docs) {
        final sale = SaleModel.fromFirestore(doc);
        final days = sale.daysRemaining;

        // Check if a reminder should be sent for configured days
        for (final reminderDay in sale.reminderDays) {
          if (days == reminderDay &&
              !sale.remindersSent.contains(reminderDay)) {
            await showExpirationNotification(
              id: notificationId++,
              clientName: sale.clientName,
              platformName: sale.platformName,
              daysRemaining: days,
            );

            // Mark reminder as sent
            await firestore
                .collection(AppConstants.salesCollection)
                .doc(sale.id)
                .update({
              'remindersSent': FieldValue.arrayUnion([reminderDay]),
            });
          }
        }

        // Also alert on day 0 (expired today)
        if (days == 0 && !sale.remindersSent.contains(0)) {
          await showExpirationNotification(
            id: notificationId++,
            clientName: sale.clientName,
            platformName: sale.platformName,
            daysRemaining: 0,
          );
          await firestore
              .collection(AppConstants.salesCollection)
              .doc(sale.id)
              .update({
            'remindersSent': FieldValue.arrayUnion([0]),
          });
        }
      }

      // Check low stock
      final profilesSnap = await firestore
          .collection(AppConstants.profilesCollection)
          .get();

      final Map<String, int> availableByPlatform = {};
      for (final doc in profilesSnap.docs) {
        final profile = ProfileModel.fromFirestore(doc);
        if (!availableByPlatform.containsKey(profile.platformName)) {
          availableByPlatform[profile.platformName] = 0;
        }
        if (profile.status == ProfileStatus.available) {
          availableByPlatform[profile.platformName] =
              availableByPlatform[profile.platformName]! + 1;
        }
      }

      for (final entry in availableByPlatform.entries) {
        if (entry.value <= 1) {
          await showLowStockNotification(
            platformName: entry.key,
            availableCount: entry.value,
          );
        }
      }
    } catch (e) {
      // Swallow errors in background task
    }
  }
}
