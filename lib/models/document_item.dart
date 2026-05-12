import 'package:flutter/material.dart';
import '../utils/category_helpers.dart';

class DocumentItem {
  final String name;
  final String category;
  final DateTime expiryDate;
  final IconData icon;
  final List<int> reminderDays;

  const DocumentItem({
    required this.name,
    required this.category,
    required this.expiryDate,
    required this.icon,
    required this.reminderDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'expiryDate': expiryDate.toIso8601String(),
      'reminderDays': reminderDays,
    };
  }

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    final category = json['category'];

    final List<int> reminders = json['reminderDays'] == null
        ? [30, 7, 1]
        : List<int>.from(json['reminderDays']);

    return DocumentItem(
      name: json['name'],
      category: category,
      expiryDate: DateTime.parse(json['expiryDate']),
      icon: getIconForCategory(category),
      reminderDays: reminders,
    );
  }
}