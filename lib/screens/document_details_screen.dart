import 'package:flutter/material.dart';

import '../models/document_item.dart';
import '../utils/date_helpers.dart';
import 'add_document_screen.dart';

class DocumentDetailsResult {
  final bool shouldDelete;
  final DocumentItem? updatedDocument;

  const DocumentDetailsResult({
    this.shouldDelete = false,
    this.updatedDocument,
  });
}

class DocumentDetailsScreen extends StatelessWidget {
  final DocumentItem document;

  const DocumentDetailsScreen({
    super.key,
    required this.document,
  });

  void _editDocument(BuildContext context) async {
    final updatedDocument = await Navigator.push<DocumentItem>(
      context,
      MaterialPageRoute(
        builder: (context) => AddDocumentScreen(
          initialDocument: document,
        ),
      ),
    );

    if (updatedDocument != null) {
      Navigator.pop(
        context,
        DocumentDetailsResult(updatedDocument: updatedDocument),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Ștergi documentul?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Ești sigur că vrei să ștergi „${document.name}”? Această acțiune nu poate fi anulată.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Anulează'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Șterge'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      Navigator.pop(
        context,
        const DocumentDetailsResult(shouldDelete: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(document.expiryDate);
    final remainingTime = formatRemainingTime(document.expiryDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Icon(
                    document.icon,
                    color: statusColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Text(
                  document.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard('Categorie', document.category),
              const SizedBox(height: 12),
              _buildInfoCard('Expiră la', formatDate(document.expiryDate)),
              const SizedBox(height: 12),
              _buildInfoCard('Status', remainingTime, color: statusColor),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Notificări',
                formatReminderDays(document.reminderDays),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    _editDocument(context);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'Editează document',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    _confirmDelete(context);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text(
                    'Șterge document',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value, {
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}