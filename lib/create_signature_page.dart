import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import 'models/saved_signature.dart';

class CreateSignaturePage extends StatelessWidget {
  final GlobalKey<SfSignaturePadState> signaturePadKey;
  final List<SavedSignature> savedSignatures;
  final VoidCallback onClearSignature;
  final VoidCallback onCreateSignature;
  final Function(SavedSignature) onSelectSavedSignature;
  final Function(String) onDeleteSignature;

  CreateSignaturePage({
    required this.signaturePadKey,
    required this.savedSignatures,
    required this.onClearSignature,
    required this.onCreateSignature,
    required this.onSelectSavedSignature,
    required this.onDeleteSignature,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Your Signature',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a saved signature or create a new one',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          if (savedSignatures.isNotEmpty) ...[
            Text(
              'Saved Signatures',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: savedSignatures.length,
                itemBuilder: (context, index) {
                  final signature = savedSignatures[index];
                  return Container(
                    width: 200,
                    margin: EdgeInsets.only(right: 12),
                    child: Card(
                      child: InkWell(
                        onTap: () => onSelectSavedSignature(signature),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      signature.name,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, size: 16),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    onPressed: () =>
                                        onDeleteSignature(signature.id),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.memory(
                                    signature.imageData,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Divider(),
            const SizedBox(height: 16),
          ],
          Text(
            'Draw New Signature',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: SfSignaturePad(
                key: signaturePadKey,
                backgroundColor: Colors.transparent,
                strokeColor: Colors.black,
                minimumStrokeWidth: 2.0,
                maximumStrokeWidth: 4.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClearSignature,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCreateSignature,
                  icon: const Icon(Icons.check, size: 24),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
