import 'package:flutter/material.dart';
import 'package:grad_snap/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'pages/main_page.dart';
import 'providers/auth_provider.dart';
import 'providers/mua_provider.dart';
import 'providers/photographer_provider.dart';
import 'providers/booking_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
      child: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          // Ambil user saat app mulai
          WidgetsBinding.instance.addPostFrameCallback((_) {
            auth.getCurrentUser();
          });
          
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Grad-Snap',
            theme: ThemeData(
              fontFamily: 'Poppins',
              primarySwatch: Colors.blue,
            ),
            home: const MainPage(),
            routes: {
              '/main': (context) => const MainPage(),
              '/profile': (context) => const ProfilePage(),
            },
          );
        },
      ),
    );
  }
}