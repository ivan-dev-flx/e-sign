import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompletePage extends StatelessWidget {
  final VoidCallback onReset;

  CompletePage({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Document Signed!',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1565C0),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your document has been successfully signed and saved',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),
            SizedBox(
              width: 200,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onReset,
                icon: Icon(Icons.add_circle_outline, size: 24),
                label: Text('Sign Another'),
                style: ElevatedButton.styleFrom(
                  textStyle: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}