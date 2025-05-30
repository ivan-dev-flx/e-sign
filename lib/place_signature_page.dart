import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';

class PlaceSignaturePage extends StatelessWidget {
  final String? filePath;
  final Uint8List? signatureImage;
  final double signatureX;
  final double signatureY;
  final double signatureWidth;
  final double signatureHeight;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragUpdateDetails) onResizeBottomRight;
  final Function(DragUpdateDetails) onResizeTopRight;
  final Function(DragUpdateDetails) onResizeBottomLeft;
  final Function(DragUpdateDetails) onResizeTopLeft;
  final VoidCallback onSave;

  PlaceSignaturePage({
    required this.filePath,
    required this.signatureImage,
    required this.signatureX,
    required this.signatureY,
    required this.signatureWidth,
    required this.signatureHeight,
    required this.onPanUpdate,
    required this.onResizeBottomRight,
    required this.onResizeTopRight,
    required this.onResizeBottomLeft,
    required this.onResizeTopLeft,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Place Your Signature',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Drag your signature to position it on the document. Use corner handles to resize.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    if (filePath != null)
                      SfPdfViewer.file(
                        File(filePath!),
                        canShowScrollHead: false,
                      ),
                    if (signatureImage != null)
                      Positioned(
                        left: signatureX,
                        top: signatureY,
                        child: GestureDetector(
                          onPanUpdate: onPanUpdate,
                          child: Container(
                            width: signatureWidth,
                            height: signatureHeight,
                            child: Stack(
                              children: [
                                Container(
                                  width: signatureWidth,
                                  height: signatureHeight,
                                  child: Image.memory(
                                    signatureImage!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Container(
                                  width: signatureWidth,
                                  height: signatureHeight,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blueAccent.withOpacity(0.7),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Positioned(
                                  right: -6,
                                  bottom: -6,
                                  child: GestureDetector(
                                    onPanUpdate: onResizeBottomRight,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: GestureDetector(
                                    onPanUpdate: onResizeTopRight,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: -6,
                                  bottom: -6,
                                  child: GestureDetector(
                                    onPanUpdate: onResizeBottomLeft,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: -6,
                                  top: -6,
                                  child: GestureDetector(
                                    onPanUpdate: onResizeTopLeft,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save, size: 24),
              label: const Text('Save Signed Document'),
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
    );
  }
}
