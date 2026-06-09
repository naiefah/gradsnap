import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local = 
      FlutterLocalNotificationsPlugin();
  
  static Future<void> init() async {
    // 1. Setup local notification
    const AndroidInitializationSettings android = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings();
    const InitializationSettings settings = 
        InitializationSettings(android: android, iOS: ios);
    
    await _local.initialize(settings);
    
    // 2. Request permission
    NotificationSettings permission = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (permission.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ FCM permission granted');
    }
    
    // 3. Get FCM Token
    String? token = await _fcm.getToken();
    debugPrint('📱 FCM Token: $token');
    
    // 4. Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_showNotification);
    
    // 5. Listen to background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    
    // 6. Listen when app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('App opened from notification: ${message.data}');
    });
  }
  
  static void _showNotification(RemoteMessage message) {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'gradsnap_channel',
      'GradSnap Notifications',
      importance: Importance.high,
      priority: Priority.high,
      channelDescription: 'Notifikasi dari GradSnap',
    );
    const NotificationDetails details = NotificationDetails(android: android);
    
    _local.show(
      message.hashCode,
      message.notification?.title ?? 'GradSnap',
      message.notification?.body ?? 'Ada notifikasi baru',
      details,
    );
  }
  
  @pragma('vm:entry-point')
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    debugPrint('📱 Background message: ${message.messageId}');
  }
  
  // Kirim notification ke customer (panggil dari backend)
  static Future<void> sendNotificationToCustomer({
    required String customerId,
    required String title,
    required String body,
  }) async {
    // Ini nanti dipanggil dari backend PHP
    debugPrint('Send to customer $customerId: $title - $body');
  }
  
  // Kirim notification ke vendor
  static Future<void> sendNotificationToVendor({
    required String vendorId,
    required String title,
    required String body,
  }) async {
    debugPrint('Send to vendor $vendorId: $title - $body');
  }
}