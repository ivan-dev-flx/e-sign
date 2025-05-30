import 'dart:convert';
import 'dart:typed_data';

class SavedSignature {
  final String id;
  final String name;
  final Uint8List imageData;
  final DateTime createdAt;

  SavedSignature({
    required this.id,
    required this.name,
    required this.imageData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageData': base64Encode(imageData), // Encode Uint8List as base64 string
      'createdAt': createdAt.toIso8601String(), // Use ISO 8601 for DateTime
    };
  }

  factory SavedSignature.fromJson(Map<String, dynamic> json) {
    try {
      return SavedSignature(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        imageData: json['imageData'] != null
            ? base64Decode(json['imageData'] as String)
            : Uint8List(0),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing SavedSignature from JSON: $e');
      return SavedSignature(
        id: '',
        name: '',
        imageData: Uint8List(0),
        createdAt: DateTime.now(),
      );
    }
  }
}
