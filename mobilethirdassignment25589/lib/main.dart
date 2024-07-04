import 'package:battery/battery.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;

  static const String BATTERY_NOTIFICATION_CHANNEL_ID = "battery_notification";
  static const String INTERNET_NOTIFICATION_CHANNEL_ID = "internet_notification";

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void initNotifs() async {
    var initializationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void initState() {
    super.initState();
    final battery = Battery();
    initNotifs();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // The line below prints the connectivity status to console
      print("Connectivity status: $result");
      final hasInternet = result!= ConnectivityResult.none;
      if (hasInternet) {
        flutterLocalNotificationsPlugin.show(
          0,
          'Internet Connection',
          'You are now connected to the internet!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              INTERNET_NOTIFICATION_CHANNEL_ID,
              INTERNET_NOTIFICATION_CHANNEL_ID,
            ),
          ),
        );
      } else {
        flutterLocalNotificationsPlugin.show(
          0,
          'No Internet Connection',
          'You are not connected to the internet!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              INTERNET_NOTIFICATION_CHANNEL_ID,
              INTERNET_NOTIFICATION_CHANNEL_ID,
            ),
          ),
        );
      }
    });

    battery.onBatteryStateChanged.listen((BatteryState state) {
      if (state == BatteryState.charging) {
        battery.batteryLevel.then((level) {
            if (level >= 80) {
            flutterLocalNotificationsPlugin.show(
              0,
              'Battery health',
              'Battery level is now $level% ,please unplug your charger for maintenance of your battery ',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  BATTERY_NOTIFICATION_CHANNEL_ID,
                  BATTERY_NOTIFICATION_CHANNEL_ID,
                ),
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: themeMode == ThemeMode.light
          ? ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      )
          : ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: HomeScreen(
        onThemeChanged: (themeMode) {
          setState(() {
            this.themeMode = themeMode;
          });
        },
      ),
    );
  }
}