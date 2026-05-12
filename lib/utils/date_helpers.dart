import 'package:flutter/material.dart';

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day.$month.${date.year}';
}

int daysUntil(DateTime expiryDate) {
  final today = DateTime.now();
  final todayOnly = DateTime(today.year, today.month, today.day);
  final expiryOnly = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

  return expiryOnly.difference(todayOnly).inDays;
}

String formatRemainingTime(DateTime expiryDate) {
  final days = daysUntil(expiryDate);

  if (days < 0) {
    final expiredDays = days.abs();
    return expiredDays == 1 ? 'Expirat ieri' : 'Expirat de $expiredDays zile';
  }

  if (days == 0) return 'Expiră azi';
  if (days == 1) return 'Mâine';
  if (days < 7) return '$days zile';

  if (days < 30) {
    final weeks = days ~/ 7;
    return weeks == 1 ? '1 săptămână' : '$weeks săptămâni';
  }

  final now = DateTime.now();

  int months =
      (expiryDate.year - now.year) * 12 + expiryDate.month - now.month;

  if (expiryDate.day < now.day) {
    months--;
  }

  if (months < 12) {
    if (months <= 0) return '$days zile';
    return months == 1 ? '1 lună' : '$months luni';
  }

  final years = months ~/ 12;

  return years == 1 ? '1 an' : '$years ani';
}

Color getStatusColor(DateTime expiryDate) {
  final days = daysUntil(expiryDate);

  if (days < 0) return Colors.red;
  if (days <= 30) return Colors.orange;

  return Colors.green;
}

String reminderLabel(int days) {
  if (days == 0) return 'În ziua expirării';
  if (days == 1) return '1 zi înainte';
  return '$days zile înainte';
}

String formatReminderDays(List<int> reminderDays) {
  if (reminderDays.isEmpty) {
    return 'Fără notificări';
  }

  final sorted = [...reminderDays]..sort((a, b) => b.compareTo(a));

  return sorted.map(reminderLabel).join(', ');
}