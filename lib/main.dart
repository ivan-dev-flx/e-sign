import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import 'models/saved_signature.dart';

void main() {
  runApp(PdfESignApp());
}

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
      home: PdfESignHomePage(),
    );
  }
}

class PdfESignHomePage extends StatefulWidget {
  @override
  _PdfESignHomePageState createState() => _PdfESignHomePageState();
}

class _PdfESignHomePageState extends State<PdfESignHomePage> {
  PdfDocument? _document;
  String? _filePath;
  String? _originalFileName;
  Uint8List? _signatureImage;
  Color _selectedColor = Colors.black;
  final _signaturePadKey = GlobalKey<SfSignaturePadState>();
  double _signatureX = 100;
  double _signatureY = 300;
  double _signatureWidth = 150;
  double _signatureHeight = 75;
  bool _isSignatureCreated = false;
  PageController _pageController = PageController();
  int _currentStep = 0;

  List<SavedSignature> _savedSignatures = [];
  SavedSignature? _selectedSignature;
  final TextEditingController _signatureNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _document = PdfDocument();
    _loadSavedSignatures();
  }

  Future<void> _loadSavedSignatures() async {
    final prefs = await SharedPreferences.getInstance();
    final signaturesJson = prefs.getStringList('saved_signatures') ?? [];

    setState(() {
      _savedSignatures = signaturesJson
          .map((json) => SavedSignature.fromJson(jsonDecode(json)))
          .toList();
    });
  }

  Future<void> _showDeleteConfirmation(String signatureId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Иконка с анимацией
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.delete_rounded,
                    size: 48,
                    color: Colors.red[400],
                  ),
                ),

                const SizedBox(height: 20),

                // Заголовок
                Text(
                  'Delete Signature?',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Описание
                Text(
                  'This action cannot be undone. The signature will be permanently deleted.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (shouldDelete == true) {
      await _deleteSignatureFromCache(signatureId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Center(
            child: Text(
              'Signature deleted',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _deleteSignatureFromCache(String signatureId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedSignaturesJson = prefs.getStringList('saved_signatures') ?? [];

      final updatedSignatures = savedSignaturesJson.where((signatureJson) {
        final signatureMap = jsonDecode(signatureJson);
        return signatureMap['id'] != signatureId;
      }).toList();

      await prefs.setStringList('saved_signatures', updatedSignatures);

      _loadSavedSignatures();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Signature deleted', style: GoogleFonts.inter()),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to delete signature', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveSignatureToCache(String name, Uint8List imageData) async {
    final signature = SavedSignature(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      imageData: imageData,
      createdAt: DateTime.now(),
    );

    _savedSignatures.add(signature);

    final prefs = await SharedPreferences.getInstance();
    final signaturesJson =
        _savedSignatures.map((sig) => jsonEncode(sig.toJson())).toList();

    await prefs.setStringList('saved_signatures', signaturesJson);
  }

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path!;
        _originalFileName =
            path.basenameWithoutExtension(result.files.single.name);
        _document = PdfDocument(inputBytes: File(_filePath!).readAsBytesSync());
        _currentStep = 1;
      });
      _pageController.animateToPage(1,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _createSignature() async {
    final image = await _signaturePadKey.currentState?.toImage(pixelRatio: 3.0);
    if (image != null) {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final imageData = byteData.buffer.asUint8List();
        bool? shouldSave = await _showSaveSignatureDialog();
        if (shouldSave == true && _signatureNameController.text.isNotEmpty) {
          await _saveSignatureToCache(_signatureNameController.text, imageData);
          await _loadSavedSignatures();
          _signatureNameController.clear();
        }

        setState(() {
          _signatureImage = imageData;
          _isSignatureCreated = true;
          _currentStep = 2;
        });
        _pageController.animateToPage(2,
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  Future<bool?> _showSaveSignatureDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: 48, color: Colors.blue),
                SizedBox(height: 16),
                Text(
                  'Save Signature?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Would you like to save this signature for quick access in the future?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: _signatureNameController,
                  decoration: InputDecoration(
                    labelText: 'Signature Name',
                    hintText: 'e.g. My Primary Signature',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                      child: Text('DISCARD'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text('SAVE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> showSaveSignatureDialog(BuildContext context,
      TextEditingController signatureNameController) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Save Signature?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Would you like to save this signature for quick use in the future?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: signatureNameController,
                    decoration: InputDecoration(
                      labelText: 'Signature Name',
                      hintText: 'e.g., Primary Signature',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          'Don\'t Save',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          elevation: 2,
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectSavedSignature(SavedSignature signature) {
    setState(() {
      _selectedSignature = signature;
      _signatureImage = signature.imageData;
      _isSignatureCreated = true;
      _currentStep = 2;
    });
    _pageController.animateToPage(2,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _clearSignature() {
    _signaturePadKey.currentState?.clear();
    setState(() {
      _isSignatureCreated = false;
      _signatureImage = null;
      _selectedSignature = null;
    });
  }

  Future<void> _savePdfWithSignature() async {
    if (_document != null && _signatureImage != null) {
      try {
        final page = _document!.pages.count > 0
            ? _document!.pages[0]
            : _document!.pages.add();

        page.graphics.drawImage(
          PdfBitmap(_signatureImage!),
          Rect.fromLTWH(
              _signatureX, _signatureY, _signatureWidth, _signatureHeight),
        );

        final bytes = await _document!.save();
        final fileName = '${_originalFileName ?? 'document'}_signed.pdf';

        // Save file using file_saver with iOS Files app integration
        final String? filePath = await FileSaver.instance.saveAs(
          name: fileName,
          bytes: Uint8List.fromList(bytes),
          ext: 'pdf',
          mimeType: MimeType.pdf,
        );

        if (filePath != null) {
          // File saved successfully
          setState(() {
            _filePath = null; // Clear the original file path
            _currentStep = 3;
          });

          // Navigate to completion page
          _pageController.animateToPage(3,
              duration: Duration(milliseconds: 300), curve: Curves.easeInOut);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Document successfully signed and saved to Files')),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Open Files',
                textColor: Colors.white,
                onPressed: () {
                  // This will be handled by iOS automatically when user taps
                },
              ),
            ),
          );
        } else {
          throw Exception('Failed to save file - no path returned');
        }
      } catch (e) {
        print('Error saving PDF: $e'); // Debug log

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                    child: Text('Error saving document. Please try again.')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _resetProcess() {
    setState(() {
      _document = PdfDocument();
      _filePath = null;
      _originalFileName = null;
      _signatureImage = null;
      _isSignatureCreated = false;
      _selectedSignature = null;
      _currentStep = 0;
      _signatureX = 100;
      _signatureY = 300;
    });
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

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
          if (_currentStep > 0)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetProcess,
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
                _buildStepIndicator(0, 'Select PDF', Icons.file_present),
                Expanded(child: _buildStepLine(0)),
                _buildStepIndicator(1, 'Create Signature', Icons.draw),
                Expanded(child: _buildStepLine(1)),
                _buildStepIndicator(2, 'Place & Save', Icons.place),
                Expanded(child: _buildStepLine(2)),
                _buildStepIndicator(3, 'Complete', Icons.check_circle),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildSelectPdfPage(),
                _buildCreateSignaturePage(),
                _buildPlaceSignaturePage(),
                _buildCompletePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Color(0xFF4FC3F7) : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
            border: isCurrent
                ? Border.all(color: Color(0xFF1565C0), width: 2)
                : null,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? Color(0xFF1565C0) : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    bool isActive = _currentStep > step;
    return Container(
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF4FC3F7) : Colors.grey[300],
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildSelectPdfPage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4FC3F7), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF4FC3F7).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 3,
                  )
                ],
              ),
              child: Icon(
                Icons.insert_drive_file_rounded,
                size: 70,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Upload PDF Document',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1565C0),
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Select the PDF file you want to sign from your device',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 48),
            SizedBox(
              width: 220,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _pickPdfFile,
                icon: Icon(
                  Icons.cloud_upload_rounded,
                  size: 24,
                  color: Colors.white,
                ),
                label: Text('Select PDF'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF1565C0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateSignaturePage() {
    return SingleChildScrollView(
      child: Padding(
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

            // Сохраненные подписи
            if (_savedSignatures.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      'SAVED SIGNATURES',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey[700],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.blueGrey[400]),
                  ],
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _savedSignatures.length,
                  itemBuilder: (context, index) {
                    final signature = _savedSignatures[index];
                    return Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 16),
                      child: Material(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.blue.withOpacity(0.1),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _selectSavedSignature(signature),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        size: 12,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        signature.name,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Colors.blueGrey[800],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, size: 16),
                                      color: Colors.blueGrey[300],
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () =>
                                          _showDeleteConfirmation(signature.id),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      border:
                                          Border.all(color: Colors.grey[200]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.memory(
                                        signature.imageData,
                                        fit: BoxFit.contain,
                                      ),
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
              const Divider(),
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

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildColorCircle(Colors.black),
                    const SizedBox(width: 8),
                    _buildColorCircle(Colors.blue),
                    const SizedBox(width: 8),
                    _buildColorCircle(Colors.red),
                    const SizedBox(width: 8),
                    _buildColorCircle(Colors.green),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showColorPicker,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.red,
                              Colors.orange,
                              Colors.yellow,
                              Colors.green,
                              Colors.blue,
                              Colors.indigo,
                              Colors.purple
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border:
                              Border.all(color: Colors.grey[400]!, width: 1),
                        ),
                        child: const Icon(Icons.colorize,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Container(
                  height: 200, // Уменьшенная высота окна для подписи
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: SfSignaturePad(
                    key: _signaturePadKey,
                    backgroundColor: Colors.transparent,
                    strokeColor: _selectedColor,
                    minimumStrokeWidth: 2.0,
                    maximumStrokeWidth: 4.0,
                  ),
                ),
                const SizedBox(height: 12),
                // Color selection row
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _clearSignature,
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
                        onPressed: _createSignature,
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
                const SizedBox(
                    height: 20), // Добавлено дополнительное пространство внизу
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                _selectedColor == color ? Colors.grey[800]! : Colors.grey[400]!,
            width: _selectedColor == color ? 2 : 1,
          ),
        ),
      ),
    );
  }

  Future<void> _showColorPicker() async {
    final color = await showModalBottomSheet<Color>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок
            ListTile(
              leading:
                  Icon(Icons.colorize, color: Theme.of(context).primaryColor),
              title: Text(
                'Choose color',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              contentPadding: EdgeInsets.zero,
            ),

            // Цветовой пикер
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged: (color) => _selectedColor = color,
                displayThumbColor: true,
                enableAlpha: false,
                showLabel: false,
                paletteType: PaletteType.hsvWithHue,
                pickerAreaHeightPercent: 0.7,
                hexInputBar: true,
                portraitOnly: true,
                pickerAreaBorderRadius: BorderRadius.circular(16),
              ),
            ),

            // Кнопки
            ButtonBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedColor),
                  child: const Text('APPLY'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (color != null) {
      setState(() => _selectedColor = color);
    }
  }

  Widget _buildPlaceSignaturePage() {
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
                    if (_filePath != null)
                      SfPdfViewer.file(
                        File(_filePath!),
                        canShowScrollHead: false,
                      ),
                    if (_signatureImage != null)
                      Positioned(
                        left: _signatureX,
                        top: _signatureY,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _signatureX += details.delta.dx;
                              _signatureY += details.delta.dy;
                            });
                          },
                          child: Container(
                            width: _signatureWidth,
                            height: _signatureHeight,
                            child: Stack(
                              children: [
                                // Подпись с прозрачным фоном
                                Container(
                                  width: _signatureWidth,
                                  height: _signatureHeight,
                                  child: Image.memory(
                                    _signatureImage!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                // Граница для выделения
                                Container(
                                  width: _signatureWidth,
                                  height: _signatureHeight,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blueAccent.withOpacity(0.7),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                // Угловые ручки для изменения размера
                                // Правый нижний угол
                                Positioned(
                                  right: -6,
                                  bottom: -6,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        _signatureWidth =
                                            (_signatureWidth + details.delta.dx)
                                                .clamp(50.0, 300.0);
                                        _signatureHeight = (_signatureHeight +
                                                details.delta.dy)
                                            .clamp(30.0, 200.0);
                                      });
                                    },
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
                                // Правый верхний угол
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        double newHeight =
                                            _signatureHeight - details.delta.dy;
                                        if (newHeight >= 30.0 &&
                                            newHeight <= 200.0) {
                                          _signatureHeight = newHeight;
                                          _signatureY += details.delta.dy;
                                        }
                                        _signatureWidth =
                                            (_signatureWidth + details.delta.dx)
                                                .clamp(50.0, 300.0);
                                      });
                                    },
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
                                // Левый нижний угол
                                Positioned(
                                  left: -6,
                                  bottom: -6,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        double newWidth =
                                            _signatureWidth - details.delta.dx;
                                        if (newWidth >= 50.0 &&
                                            newWidth <= 300.0) {
                                          _signatureWidth = newWidth;
                                          _signatureX += details.delta.dx;
                                        }
                                        _signatureHeight = (_signatureHeight +
                                                details.delta.dy)
                                            .clamp(30.0, 200.0);
                                      });
                                    },
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
                                // Левый верхний угол
                                Positioned(
                                  left: -6,
                                  top: -6,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        double newWidth =
                                            _signatureWidth - details.delta.dx;
                                        double newHeight =
                                            _signatureHeight - details.delta.dy;

                                        if (newWidth >= 50.0 &&
                                            newWidth <= 300.0) {
                                          _signatureWidth = newWidth;
                                          _signatureX += details.delta.dx;
                                        }

                                        if (newHeight >= 30.0 &&
                                            newHeight <= 200.0) {
                                          _signatureHeight = newHeight;
                                          _signatureY += details.delta.dy;
                                        }
                                      });
                                    },
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
              onPressed: _savePdfWithSignature,
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

  Widget _buildCompletePage() {
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
                onPressed: _resetProcess,
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

  @override
  void dispose() {
    _document?.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
