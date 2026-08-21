import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NoficationService {
  /// Stream controller for incoming foreground / opened notifications
  static final StreamController<RemoteMessage> _onMessageStreamController =
      StreamController<RemoteMessage>.broadcast();
  static Stream<RemoteMessage> get onMessageStream =>
      _onMessageStreamController.stream;

  /// ✅ Declare the local notification plugin here
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> requestNotificationPermission() async {
    /// Request permission for notifications
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  static Future<String?> getToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      print("FCM Token: $token");
      return token;
    } catch (e) {
      print("Error getting FCM token: $e");
      return null;
    }
  }

  /// ✅ Initialize local notifications and create the custom sound channel
  static void initLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create the Order Assignment Channel with the custom sound
    // This allows the sound to play even if the app is in the background
    const AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      'order_assignment_channel_v2', 
      'Order Assignments',
      description: 'Critical notifications for new order assignments',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_bell'),
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(orderChannel);

    print("Notification channels initialized with custom sound.");
  }

  /// Stop all active notification sounds/alerts
  static void cancelAll() {
    _flutterLocalNotificationsPlugin.cancelAll();
    print("🔔 All notifications cancelled.");
  }

  static void showLocalNotification(RemoteMessage message) async {
    // Skip manual local notification on iOS
    if (Platform.isIOS) return;

    final String? title = message.notification?.title;
    final String? body = message.notification?.body;
    final Map<String, dynamic> data = message.data;

    // Check if this is an order assignment notification
    final bool isOrderAssignment = 
        (title?.toLowerCase().contains('order') ?? false) || 
        (title?.toLowerCase().contains('assign') ?? false) ||
        (title?.toLowerCase().contains('new task') ?? false) ||
        data['type'] == 'order_assignment' ||
        data['notification_type'] == 'ASSIGNED' ||
        data['status'] == 'assigned';

    print("🔔 Processing notification: '$title'");
    print("🔔 Is Order Assignment: $isOrderAssignment");

    final String? imageUrl =
        message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl;

    BigPictureStyleInformation? bigPictureStyleInformation;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      final String filePath = await _downloadAndSaveImage(
        imageUrl,
        'notif_img.jpg',
      );
      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(filePath),
        contentTitle: title,
        summaryText: body,
      );
    }

    // Default Channel
    String channelId = 'general_channel';
    String channelName = 'General';
    AndroidNotificationSound? customSound;

    // Assignment Channel
    if (isOrderAssignment) {
      channelId = 'order_assignment_channel_v2';
      channelName = 'Order Assignments';
      customSound = const RawResourceAndroidNotificationSound('notification_bell');
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Channel for $channelName',
          importance: Importance.max,
          priority: Priority.high,
          sound: customSound,
          playSound: true,
          additionalFlags: isOrderAssignment ? Int32List.fromList([4]) : null, // FLAG_INSISTENT loops sound
          styleInformation:
              bigPictureStyleInformation ??
              const DefaultStyleInformation(true, true),
        );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Unique ID to allow multiple notifications
      title,
      body,
      platformDetails,
      payload: data['payload'],
    );
  }

  static void initNotificationListener() {
    /// Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.notification?.title}');
      print("📩 Foreground Message: ${message.notification?.title}");
      print("📩 Message Body: ${message.notification?.body}");
      print("📩 Message Data: ${message.data}");
      // Handle the message here, e.g., show a dialog or notificatio

      // Log everything from the message
      print('📬 Full RemoteMessage payload: ${message.toMap()}');

      // Print structured logs
      print("🔔 Title: ${message.notification?.title}");
      print("📝 Body: ${message.notification?.body}");
      print("📦 Data: ${message.data}");

      // Print the image URL if present (Android or Apple)
      final String? imageUrl =
          message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        print("🖼️ Image URL: $imageUrl");
      } else {
        print("🖼️ No image URL found in notification");
      }

      // ✅ Show local notification for foreground messages
      showLocalNotification(message);

      // ✅ Emit message to stream listeners for immediate UI refresh
      _onMessageStreamController.add(message);
    });

    /// Listen for background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _onMessageStreamController.add(message);

      /// Handle the message when the app is opened from a notification
    });
  }

  static Future<String> _downloadAndSaveImage(
    String url,
    String fileName,
  ) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
