import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/document_item.dart';

class StorageService {
  static const String storageKey = 'saved_documents';

  static Future<List<DocumentItem>> loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(storageKey);

    if (savedData == null) {
      return [];
    }

    final List decodedData = jsonDecode(savedData);

    return decodedData.map((item) {
      return DocumentItem.fromJson(item);
    }).toList();
  }

  static Future<void> saveDocuments(List<DocumentItem> documents) async {
    final prefs = await SharedPreferences.getInstance();

    final encodedData = jsonEncode(
      documents.map((document) => document.toJson()).toList(),
    );

    await prefs.setString(storageKey, encodedData);
  }
}