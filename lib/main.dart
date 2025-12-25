import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitify/providers/habit_provider.dart';
import 'package:habitify/providers/theme_provider.dart';
import 'package:habitify/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:habitify/services/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final notificationService = NotificationService();
  await notificationService.init();

  await notificationService.requestPermissions();

  await notificationService.scheduleAllHabitReminders();

  final DateTime now = DateTime.now();
  final DateTime testTime = now.add(Duration(minutes: 2));

  await notificationService.scheduleDailyNotification(
    id: 999,
    title: "Test Notifikasi",
    body: "Halo! Ini test notifikasi",
    hour: testTime.hour,
    minute: testTime.minute,
  );

  print("Memulai penjadwalan..."); // Log
  await notificationService.scheduleAllHabitReminders();

  // --- DEBUG CONSOLE ---
  // Cek apakah benar-benar sudah masuk ke sistem Android?
  await notificationService.checkPendingNotifications();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => themeProvider),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Habitify',
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
              background: const Color(0xFFF9FAFB),
              surface: Colors.white,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF9FAFB),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
              background: const Color(0xFF111827),
              surface: const Color(0xFF1F2937),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF111827),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              ThemeData.dark().textTheme,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F2937),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}
