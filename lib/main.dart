import 'package:flutter/material.dart';
import 'package:bus_ticketing_app/login_page.dart';
import 'package:bus_ticketing_app/signup_page.dart';
import 'package:bus_ticketing_app/forgot_password_page.dart';
import 'package:bus_ticketing_app/home_screen.dart';
import 'package:bus_ticketing_app/booking_screen.dart';
import 'package:bus_ticketing_app/map_screen.dart';
import 'package:bus_ticketing_app/booking_history_screen.dart';
import 'package:bus_ticketing_app/user_profile_screen.dart';
import 'package:bus_ticketing_app/payment_screen.dart';
import 'package:bus_ticketing_app/services/auth_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start warming up the backend early
  AuthService().warmup();
  
  try {
    Stripe.publishableKey = 'pk_test_TYu3EQhXgYy01sF23456789';
    if (kIsWeb) {
      await Stripe.instance.applySettings();
    }
  } catch (e) {
    debugPrint('Stripe initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Ticketing System',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Deep Indigo
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFFFFD700), // Gold Accent
          surface: Colors.white,
          surfaceTint: Colors.transparent,
          onSurface: Colors.black87,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        cardTheme: CardThemeData(
          elevation: 8,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.black54),
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIconColor: const Color(0xFF1A237E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.w800, 
            color: Color(0xFF1A237E),
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: Color(0xFF1A237E),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomeScreen(),
        '/booking': (context) => const BookingScreen(),
        '/map': (context) => const MapScreen(),
        '/bookingHistory': (context) => const BookingHistoryScreen(),
        '/userProfile': (context) => const UserProfileScreen(),
        '/payment': (context) => const PaymentScreen(bookingId: 'test_id'),
      },
    );
  }
}
