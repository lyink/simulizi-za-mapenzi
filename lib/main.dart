import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/bible_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/story_sync_service.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/story_provider.dart';
import 'widgets/app_drawer.dart';
import 'widgets/ad_banner_widget.dart';
import 'widgets/animated_splash_screen.dart';
import 'firebase_options.dart';

/// Initialize services in background to avoid blocking UI
Future<void> _initializeServicesAsync() async {
  // Wait a bit for the UI to render first
  await Future.delayed(const Duration(milliseconds: 500));

  // Initialize Ad Service
  try {
    await AdService.initialize();
    // Load ads with delays to prevent network congestion
    AdService.loadInterstitialAd();
    await Future.delayed(const Duration(milliseconds: 200));
    AdService.loadAppOpenAd();
    await Future.delayed(const Duration(milliseconds: 200));
    AdService.loadRewardedAd();
  } catch (e) {
    debugPrint('Failed to initialize Ad Service: $e');
  }

  // Initialize notifications
  try {
    await NotificationService().initialize();
    // Subscribe to topic without blocking
    NotificationService().subscribeToTopic('all_users').catchError((e) {
      debugPrint('Failed to subscribe to topic: $e');
    });

    // Enable reading reminders by default
    final remindersEnabled = await NotificationService().areReadingRemindersEnabled();
    if (remindersEnabled) {
      await NotificationService().enableReadingReminders(hour: 19, minute: 0);
    }
  } catch (e) {
    debugPrint('Failed to initialize Notification Service: $e');
  }

  // Initialize story sync service for background updates
  try {
    await StorySyncService().initialize();
  } catch (e) {
    debugPrint('Failed to initialize Story Sync Service: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set system UI overlay for light theme only
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Dark icons for light theme
      systemNavigationBarColor: Color(0xFFFFFDF9), // Light background
      systemNavigationBarIconBrightness: Brightness.dark, // Dark icons for light theme
    ),
  );

  // Initialize services asynchronously (don't block app startup)
  _initializeServicesAsync();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => StoryProvider()),
      ],
      child: const SimuliziApp(),
    ),
  );
}

class SimuliziApp extends StatefulWidget {
  const SimuliziApp({super.key});

  @override
  State<SimuliziApp> createState() => _SimuliziAppState();
}

class _SimuliziAppState extends State<SimuliziApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          key: ValueKey('${themeProvider.colorScheme}_${themeProvider.fontSize}'),
          title: 'Simulizi za Mapenzi',
          theme: AppTheme.lightTheme(
            colorScheme: themeProvider.colorScheme,
            fontSizeMultiplier: themeProvider.fontSizeMultiplier,
          ),
          // Force light theme only
          themeMode: ThemeMode.light,
          home: _showSplash
              ? AnimatedSplashScreen(
                  onAnimationComplete: () {
                    setState(() {
                      _showSplash = false;
                    });
                  },
                )
              : const MainScreen(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/admin': (context) => const AdminPanelScreen(),
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      AdService.showAppOpenAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulizi za Mapenzi'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: 'Settings',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const Column(
        children: [
          Expanded(child: BibleScreen()),
          AdBannerWidget(),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.color_lens),
                title: Text('Theme'),
                subtitle: Text('Use the Drawer menu for more theme options'),
              ),
              ListTile(
                leading: Icon(Icons.text_fields),
                title: Text('Text Size'),
                subtitle: Text('Can be changed in the Drawer menu'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

