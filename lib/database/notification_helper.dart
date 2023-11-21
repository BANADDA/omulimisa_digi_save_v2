import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flip;

  NotificationService() : _flip = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    var settings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: null, macOS: null);
    await _flip.initialize(settings);

    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    Workmanager().registerPeriodicTask(
      '1',
      'notificationTask',
      frequency:
          Duration(minutes: 15), // Set the frequency to 1 minute (60 seconds)
      initialDelay: Duration(seconds: 0), // Set initial delay to 0 seconds
      inputData: <String, dynamic>{
        'title': 'Notification Title',
        'body': 'Notification Body',
      },
    );
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      // Retrieve data from input data
      String title = inputData!['title'];
      String body = inputData['body'];

      // Show notification
      showNotification(title, body);

      return Future.value(true);
    });
  }

  static Future<void> showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      enableVibration: true,
      channelShowBadge: true,
      playSound: true,
      sound:
          RawResourceAndroidNotificationSound('assets/audio_notification.wav'),
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await FlutterLocalNotificationsPlugin()
        .show(0, title, body, platformChannelSpecifics);
  }
}
