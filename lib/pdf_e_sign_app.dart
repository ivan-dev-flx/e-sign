import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart'; // Import main.dart to use the stateful PdfESignHomePage

class PdfESignApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF E-Signature',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF4FC3F7, {
          50: Color(0xFFE1F5FE),
          100: Color(0xFFB3E5FC),
          200: Color(0xFF81D4FA),
          300: Color(0xFF4FC3F7),
          400: Color(0xFF29B6F6),
          500: Color(0xFF03A9F4),
          600: Color(0xFF039BE5),
          700: Color(0xFF0288D1),
          800: Color(0xFF0277BD),
          900: Color(0xFF01579B),
        }),
        scaffoldBackgroundColor: Color(0xFFF8FBFF),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
            color: Color(0xFF1565C0),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1565C0)),
        ),
        textTheme: GoogleFonts.interTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4FC3F7),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: PdfESignHomePage(), // Use the stateful widget from main.dart
    );
  }
}
