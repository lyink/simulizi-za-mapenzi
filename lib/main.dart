import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore offline persistence with unlimited cache.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await NotificationService().initialize();

  // Initialize AdMob
  await AdService.initialize();

  // Preload ads
  final adService = AdService();
  adService.loadInterstitialAd();
  adService.loadRewardedAd();
  adService.loadAppOpenAd();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const HadithibooksApp(),
    ),
  );
}

class HadithibooksApp extends StatelessWidget {
  const HadithibooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Hadithi kwa Watoto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.theme,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
