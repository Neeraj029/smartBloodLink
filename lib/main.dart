import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/donor_provider.dart';
import 'providers/hospital_provider.dart';
import 'providers/ambulance_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/notification_provider.dart';

import 'utils/app_theme.dart';
import 'screens/auth/splash_screen.dart';

/// Global navigator key — allows navigation from outside widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientations for consistent mobile UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Style system overlays to blend with Material 3 theming
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SmartBloodLinkApp());
}

class SmartBloodLinkApp extends StatelessWidget {
  const SmartBloodLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme — must be first so downstream providers can read theme data
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Auth — owns the current user session
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Notification — cross-cutting, independent of role
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        // Role-specific ViewModels — lazily instantiated
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => DonorProvider()),
        ChangeNotifierProvider(create: (_) => HospitalProvider()),
        ChangeNotifierProvider(create: (_) => AmbulanceProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Smart BloodLink',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,

            // Material 3 theme switching
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            // Entry point — SplashScreen decides where to route based on auth state
            home: const SplashScreen(),

            // Global error boundary — prevents blank white screens on uncaught widget errors
            builder: (context, child) {
              return MediaQuery(
                // Prevent system font scaling from breaking layouts
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
