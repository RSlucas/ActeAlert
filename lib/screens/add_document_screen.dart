import 'package:flutter/material.dart';

import '../models/document_item.dart';
import '../utils/category_helpers.dart';
import '../utils/date_helpers.dart';

class AddDocumentScreen extends StatefulWidget {
  final DocumentItem? initialDocument;

  const AddDocumentScreen({
    super.key,
    this.initialDocument,
  });

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController customCategoryController =
      TextEditingController();
  final TextEditingController customReminderController =
      TextEditingController();

  final List<String> categories = [
    'Auto',
    'Personal',
    'Casă',
    'Altul',
  ];

  final List<int> defaultReminderOptions = [
    30,
    7,
    1,
    0,
  ];

  String selectedCategory = 'Auto';
  DateTime? selectedDate;

  Set<int> selectedReminderDays = {
    30,
    7,
    1,
  };

  bool useCustomReminder = false;

  bool get isEditing => widget.initialDocument != null;

  @override
  void initState() {
    super.initState();

    final document = widget.initialDocument;

    if (document != null) {
      nameController.text = document.name;
      selectedDate = document.expiryDate;

      final normalized = normalizeCategory(document.category);

      if (normalized == 'Altele') {
        selectedCategory = 'Altul';
        customCategoryController.text = document.category;
      } else {
        selectedCategory = normalized;
      }

      selectedReminderDays = document.reminderDays
          .where((days) => defaultReminderOptions.contains(days))
          .toSet();

      final customReminders = document.reminderDays
          .where((days) => !defaultReminderOptions.contains(days))
          .toList();

      if (customReminders.isNotEmpty) {
        useCustomReminder = true;
        customReminderController.text = customReminders.first.toString();
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    customCategoryController.dispose();
    customReminderController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  List<int>? _buildReminderDays() {
    final reminders = {...selectedReminderDays};

    if (useCustomReminder) {
      final customText = customReminderController.text.trim();
      final customValue = int.tryParse(customText);

      if (customValue == null || customValue < 0) {
        return null;
      }

      reminders.add(customValue);
    }

    final sorted = reminders.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  void _saveDocument() {
    final name = nameController.text.trim();

    final category = selectedCategory == 'Altul'
        ? customCategoryController.text.trim()
        : selectedCategory;

    final reminderDays = _buildReminderDays();

    if (name.isEmpty || category.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completează toate câmpurile.')),
      );
      return;
    }

    if (reminderDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminderul personalizat trebuie să fie un număr valid.'),
        ),
      );
      return;
    }

    if (reminderDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alege cel puțin un reminder.')),
      );
      return;
    }

    final savedDocument = DocumentItem(
      name: name,
      category: category,
      expiryDate: selectedDate!,
      icon: getIconForCategory(category),
      reminderDays: reminderDays,
    );

    Navigator.pop(context, savedDocument);
  }

  Widget _buildCategoryButton(String category) {
    final bool isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildReminderButton(int days) {
    final bool isSelected = selectedReminderDays.contains(days);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedReminderDays.remove(days);
          } else {
            selectedReminderDays.add(days);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          reminderLabel(days),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomReminderButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          useCustomReminder = !useCustomReminder;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: useCustomReminder ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Altul',
          style: TextStyle(
            color: useCustomReminder ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showCustomCategory = selectedCategory == 'Altul';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? 'Editează act' : 'Adaugă act',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nume document',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Categorie',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map(_buildCategoryButton).toList(),
            ),
            if (showCustomCategory) ...[
              const SizedBox(height: 16),
              TextField(
                controller: customCategoryController,
                decoration: InputDecoration(
                  labelText: 'Categorie personalizată',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            const Text(
              'Data expirării',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _selectExpiryDate,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  selectedDate == null
                      ? 'Alege data expirării'
                      : formatDate(selectedDate!),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Amintește-mi',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...defaultReminderOptions.map(_buildReminderButton),
                _buildCustomReminderButton(),
              ],
            ),
            if (useCustomReminder) ...[
              const SizedBox(height: 16),
              TextField(
                controller: customReminderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Zile înainte',
                  hintText: 'Ex: 14',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _saveDocument,
                child: Text(
                  isEditing ? 'Salvează modificările' : 'Salvează document',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}