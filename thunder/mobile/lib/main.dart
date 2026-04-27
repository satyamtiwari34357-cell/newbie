import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:provider/provider.dart";

import "core/theme.dart";
import "providers/auth_provider.dart";
import "providers/booking_provider.dart";
import "providers/location_provider.dart";
import "providers/mode_provider.dart";
import "providers/vendor_provider.dart";
import "screens/auth/login_screen.dart";
import "screens/shared/main_shell.dart";
import "services/notification_service.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  // Note: If you have firebase_options.dart, use DefaultFirebaseOptions.currentPlatform
  await Firebase.initializeApp();
  
  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.initialization();

  runApp(const ServiceMarketplaceApp());
}


class ServiceMarketplaceApp extends StatelessWidget {
  const ServiceMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ModeProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()..fetchLocation()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "newbie",
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (_, auth, __) => auth.isLoggedIn ? const MainShell() : const LoginScreen(),
        ),
      ),
    );
  }
}
