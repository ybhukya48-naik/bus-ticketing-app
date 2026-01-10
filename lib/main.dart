import 'package:flutter/material.dart';
import 'package:bus_ticketing_app/login_page.dart';
import 'package:bus_ticketing_app/signup_page.dart';
import 'package:bus_ticketing_app/forgot_password_page.dart';
import 'package:bus_ticketing_app/home_screen.dart';
import 'package:bus_ticketing_app/booking_screen.dart';
import 'package:bus_ticketing_app/bus_list_screen.dart';

import 'package:bus_ticketing_app/map_screen.dart';
import 'package:bus_ticketing_app/booking_history_screen.dart';
import 'package:bus_ticketing_app/user_profile_screen.dart';
import 'package:bus_ticketing_app/payment_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_TYu3EQhXgYy01sF23456789'; // TODO: Replace with your actual publishable key
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
          background: const Color(0xFFF5F7FB),
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
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => const LoginPage(), // Login page as the default
        '/signup': (context) => const SignupPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomeScreen(), // Home screen route
        '/booking': (context) => const BookingScreen(), // Booking screen route
        '/busList': (context) => BusListScreen(), // Bus list screen route
        '/userProfile': (context) => const UserProfileScreen(), // User profile screen route
        '/map': (context) => const MapScreen(), // Map screen route
        '/bookingHistory': (context) => const BookingHistoryScreen(), // Booking history screen route
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/payment') {
          final args = settings.arguments as String? ?? 'DEMO-123';
          return MaterialPageRoute(
            builder: (context) => PaymentScreen(bookingId: args),
          );
        }
        return null;
      },
    );
  }
}



