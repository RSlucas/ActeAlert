import 'package:flutter/material.dart';

IconData getIconForCategory(String category) {
  final lower = category.toLowerCase();

  if (lower.contains('auto')) return Icons.directions_car;
  if (lower.contains('personal')) return Icons.badge;
  if (lower.contains('cas')) return Icons.home;

  return Icons.description;
}

String normalizeCategory(String category) {
  final lower = category.toLowerCase();

  if (lower.contains('auto')) return 'Auto';
  if (lower.contains('personal')) return 'Personal';
  if (lower.contains('cas')) return 'Casă';

  return 'Altele';
}