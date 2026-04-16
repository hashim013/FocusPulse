import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'data/models/tracker_session.dart';
import 'presentation/home/splash_screen.dart';
import 'core/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // Initialize local storage
  await Hive.initFlutter();
  Hive.registerAdapter(TrackerSessionAdapter());

  await Hive.openBox<TrackerSession>('sessions');

  await Hive.openBox('settings');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(keys: ['isDarkMode']),
      builder: (context, Box box, _) {
        final isDarkMode = box.get('isDarkMode', defaultValue: false) as bool;

        return MaterialApp(
          title: 'Mood & Study Tracker',
          debugShowCheckedModeBanner: false,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.getLightTheme(context),
          darkTheme: AppTheme.getDarkTheme(context),
          home: const SplashScreen(),
        );
      },
    );
  }
}
