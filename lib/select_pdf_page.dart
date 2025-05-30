import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectPdfPage extends StatelessWidget {
  final VoidCallback onPickPdf;

  SelectPdfPage({required this.onPickPdf});

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
                color: Color(0xFF4FC3F7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.file_upload,
                size: 60,
                color: Color(0xFF4FC3F7),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Select PDF Document',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1565C0),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Choose the PDF document you want to sign',
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
                onPressed: onPickPdf,
                icon: Icon(Icons.upload_file, size: 24),
                label: Text('Choose PDF'),
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