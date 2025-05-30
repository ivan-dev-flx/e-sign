import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PdfESignHomeView extends StatelessWidget {
  final int currentStep;
  final VoidCallback onReset;
  final Widget Function(int, String, IconData) buildStepIndicator;
  final Widget Function(int) buildStepLine;
  final List<Widget> children;

  PdfESignHomeView({
    required this.currentStep,
    required this.onReset,
    required this.buildStepIndicator,
    required this.buildStepLine,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF4FC3F7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit_document, color: Color(0xFF1565C0)),
            ),
            SizedBox(width: 12),
            Text('PDF E-Signature'),
          ],
        ),
        actions: [
          if (currentStep > 0)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: onReset,
              tooltip: 'Start Over',
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                buildStepIndicator(0, 'Select PDF', Icons.file_present),
                Expanded(child: buildStepLine(0)),
                buildStepIndicator(1, 'Create Signature', Icons.draw),
                Expanded(child: buildStepLine(1)),
                buildStepIndicator(2, 'Place & Save', Icons.place),
                Expanded(child: buildStepLine(2)),
                buildStepIndicator(3, 'Complete', Icons.check_circle),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
