import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fb_auth_bloc/firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // adjust import path as needed

// ─── Background handler: must be top-level + pragma ───────────────────────────

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background - Title: ${message.notification?.title}');
  debugPrint('Background - Body: ${message.notification?.body}');
  debugPrint('Background - Payload: ${message.data}');

  if (message.notification != null) {
    await FirebaseUtils._showLocalNotification(
      title: message.notification!.title ?? 'No Title',
      body: message.notification!.body ?? 'No Body',
      payload: message.data.toString(),
    );
  } else if (message.data.isNotEmpty) {
    await FirebaseUtils._showLocalNotification(
      title: message.data['title'] ?? 'No Title',
      body: message.data['body'] ?? 'No Body',
      payload: message.data.toString(),
    );
  }
}

// ─── FirebaseUtils ─────────────────────────────────────────────────────────────

class FirebaseUtils {
  static final TextEditingController textEditingController =
      TextEditingController();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Call once in main() after Firebase.initializeApp()
  /// Only handles local notifications init — background handler
  /// is registered in main(), not here.
  static Future<void> initFirebase() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);

      await _localNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification tapped: ${response.payload}');
        },
      );
    } catch (e) {
      debugPrint('Error initializing Firebase utils: $e');
    }
  }

  /// Call after navigating to home screen
  static Future<void> initFirebaseHome() async {
    try {
      // Handle notification that launched the app from terminated state
      final RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        await processNotification(message: initialMessage.data);
      }

      // Handle notifications while app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint('onMessage received: ${DateTime.now()}');
        if (message.notification != null) {
          await _showLocalNotification(
            title: message.notification!.title ?? 'No Title',
            body: message.notification!.body ?? 'No Body',
            payload: message.data.toString(),
          );
        }
      });

      // Handle notification tap when app is in background (not terminated)
      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        await processNotification(message: message.data);
      });
    } catch (e) {
      debugPrint('Error in initFirebaseHome: $e');
    }
  }

  /// Request notification permissions from the user
  static Future<bool> reqForNotification() async {
  try {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final NotificationSettings settings =
        await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      announcement: true,
      sound: true,
    );

    // Just call it without capturing return value
    await _localNotificationsPlugin
    .resolvePlatformSpecificImplementation
        <AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();

    debugPrint('Local notification permission requested');

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  } catch (e) {
    debugPrint('Error requesting notification permission: $e');
    return false;
  }
}

  /// Get and store the FCM token — safe, won't throw on emulator
  static Future<void> requestFirebaseToken() async {
    try {
      _firebaseMessaging.onTokenRefresh.listen((token) {
        debugPrint('FCM token refreshed: $token');
        textEditingController.text = token;
      });

      final String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('Initial FCM token: $token');
        textEditingController.text = token;
      } else {
        debugPrint('FCM token is null (emulator or Play Services unavailable)');
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Subscribe or unsubscribe from a topic
  static Future<void> firebaseSetUnsetTopic({
    required bool isSubscribe,
    required String strTopic,
  }) async {
    try {
      if (isSubscribe) {
        await _firebaseMessaging.subscribeToTopic(strTopic);
        debugPrint('Subscribed to topic: $strTopic');
      } else {
        await _firebaseMessaging.unsubscribeFromTopic(strTopic);
        debugPrint('Unsubscribed from topic: $strTopic');
      }
    } catch (e) {
      debugPrint('Error managing topic subscription: $e');
    }
  }

  /// Show a local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'Firebase_demo',
      channelDescription: 'Channel for FCM notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      ticker: 'firebase ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Process notification data and handle redirection
  static Future<void> processNotification({
    required Map<String, dynamic> message,
  }) async {
    try {
      final String redirectionUrl =
          message['redirection_url']?.toString() ?? '';
      final String type = message['type']?.toString() ?? '';
      final String eventTitle = message['event_title']?.toString() ?? '';
      final String typeSlug = message['type_slug']?.toString() ?? '';

      debugPrint(
          'Processing notification: type=$type, slug=$typeSlug, url=$redirectionUrl, event=$eventTitle');

      // Add your redirection logic here
    } catch (e) {
      debugPrint('Error processing notification: $e');
    }
  }
}