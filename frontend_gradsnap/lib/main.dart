import 'package:flutter/material.dart';
import 'package:grad_snap/pages/profile_page.dart';
import 'package:grad_snap/pages/splash_page.dart';
import 'package:grad_snap/pages/select_role_page.dart';
import 'package:grad_snap/pages/login_page.dart';
import 'package:grad_snap/pages/history_booking_page.dart';
import 'package:grad_snap/pages/booking_detail_page.dart';
import 'package:grad_snap/pages/vendor_catalog_page.dart';
import 'package:grad_snap/models/user_model.dart'; // IMPORT INI!
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'pages/main_page.dart';
import 'providers/auth_provider.dart';
import 'providers/mua_provider.dart';
import 'providers/photographer_provider.dart';
import 'providers/booking_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GradSnapApp());
}

class GradSnapApp extends StatelessWidget {
  const GradSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MuaProvider()),
        ChangeNotifierProvider(create: (_) => PhotographerProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Grad-Snap',
        theme: ThemeData(
          fontFamily: 'Poppins',
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashPage(),
        onGenerateRoute: (settings) {
          // Handle route dengan parameter
          if (settings.name == '/booking-detail') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => BookingDetailPage(
                mapData: args,
              ),
            );
          }
          
          // Named routes
          switch (settings.name) {
            case '/main':
              return MaterialPageRoute(builder: (_) => const MainPage());
            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfilePage());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case '/select-role':
              return MaterialPageRoute(builder: (_) => const SelectRolePage());
            case '/booking-history':
              return MaterialPageRoute(builder: (_) => const HistoryBookingPage());
            case '/mua-catalog':
              return MaterialPageRoute(builder: (_) => const VendorCatalogPage(role: UserRole.mua));
            case '/photographer-catalog':
              return MaterialPageRoute(builder: (_) => const VendorCatalogPage(role: UserRole.photographer));
            default:
              return MaterialPageRoute(builder: (_) => const SplashPage());
          }
        },
      ),
    );
  }
}