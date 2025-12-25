import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notifikasi diklik: ${response.payload}");
      },
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final scheduledTime = _nextInstanceOfTime(hour, minute);

    print("--------------------------------------------------");
    print("📅 MENJADWALKAN NOTIFIKASI (ID: $id)");
    print("Target Waktu: ${scheduledTime.toString()}");
    print("Judul       : $title");
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_habit_channel',
          'Daily Habit Reminders',
          channelDescription: 'Pengingat untuk mengisi habit harian',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> checkPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    print('\n========= 📋 CEK STATUS SYSTEM ANDROID =========');
    if (pendingNotificationRequests.isEmpty) {
      print('📭 Kosong: Tidak ada notifikasi yang terdaftar di sistem.');
    } else {
      print(
        '✅ Ditemukan ${pendingNotificationRequests.length} notifikasi aktif:',
      );
      for (var notification in pendingNotificationRequests) {
        print(
          '   🔔 [ID: ${notification.id}] "${notification.title}" (Body: ${notification.body})',
        );
      }
    }
    print('================================================\n');
  }

  Future<void> scheduleAllHabitReminders() async {
    await scheduleDailyNotification(
      id: 1,
      title: "Selamat Pagi! ☀️",
      body: "Sudah siap memulai habit pagimu?",
      hour: 6,
      minute: 0,
    );

    await scheduleDailyNotification(
      id: 2,
      title: "Istirahat Siang 🍱",
      body: "Jangan lupa cek habit siangmu ya.",
      hour: 12,
      minute: 0,
    );

    await scheduleDailyNotification(
      id: 3,
      title: "Tetap Semangat 💪",
      body: "Waktunya cek progres sore ini.",
      hour: 15,
      minute: 0,
    );

    await scheduleDailyNotification(
      id: 4,
      title: "Evaluasi Hari Ini 🌙",
      body: "Yuk selesaikan habit yang tersisa hari ini!",
      hour: 18,
      minute: 0,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
