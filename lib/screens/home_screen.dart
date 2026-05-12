import 'package:flutter/material.dart';

import '../models/document_item.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/category_helpers.dart';
import '../utils/date_helpers.dart';
import 'add_document_screen.dart';
import 'document_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentItem> documents = [];

  final List<String> filters = [
    'Toate',
    'Auto',
    'Casă',
    'Personal',
    'Altele',
  ];

  String selectedFilter = 'Toate';
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final loadedDocuments = await StorageService.loadDocuments();

    setState(() {
      documents = loadedDocuments;
      isLoading = false;
    });

    await NotificationService.scheduleAllDocuments(documents);
  }

  Future<void> _saveDocuments() async {
    await StorageService.saveDocuments(documents);
    await NotificationService.scheduleAllDocuments(documents);
  }

  List<DocumentItem> get filteredDocuments {
    return documents.where((doc) {
      final normalizedCategory = normalizeCategory(doc.category);

      final matchesFilter =
          selectedFilter == 'Toate' || normalizedCategory == selectedFilter;

      final lowerSearch = searchQuery.toLowerCase();

      final matchesSearch = doc.name.toLowerCase().contains(lowerSearch) ||
          doc.category.toLowerCase().contains(lowerSearch);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _openAddDocumentScreen() async {
    final newDocument = await Navigator.push<DocumentItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDocumentScreen(),
      ),
    );

    if (newDocument != null) {
      setState(() {
        documents.add(newDocument);
      });

      await _saveDocuments();
    }
  }

  void _openDetails(DocumentItem document) async {
    final result = await Navigator.push<DocumentDetailsResult>(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentDetailsScreen(
          document: document,
        ),
      ),
    );

    if (result == null) return;

    if (result.shouldDelete) {
      setState(() {
        documents.remove(document);
      });

      await _saveDocuments();
    }

    if (result.updatedDocument != null) {
      final index = documents.indexOf(document);

      if (index != -1) {
        setState(() {
          documents[index] = result.updatedDocument!;
        });

        await _saveDocuments();
      }
    }
  }

  Widget _buildHeader() {
  return const Center(
    child: Text(
      'ActeAlert',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF60A5FA),
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ai grijă de actele tale',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Primești notificări înainte să expire documentele importante.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          icon: Icon(
            Icons.search,
            color: Color(0xFF2563EB),
          ),
          hintText: 'Caută document...',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filter) {
    final bool isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return _buildFilterButton(filters[index]);
        },
      ),
    );
  }

  Widget _buildDocumentCard(DocumentItem document) {
    final statusColor = getStatusColor(document.expiryDate);
    final remainingTime = formatRemainingTime(document.expiryDate);

    return GestureDetector(
      onTap: () {
        _openDetails(document);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                document.icon,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${document.category} • ${formatDate(document.expiryDate)}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                remainingTime,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool hasNoDocumentsAtAll = documents.isEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasNoDocumentsAtAll ? Icons.add_card : Icons.folder_open,
              color: Colors.black38,
              size: 46,
            ),
            const SizedBox(height: 10),
            Text(
              hasNoDocumentsAtAll
                  ? 'Nu ai documente încă'
                  : 'Nu am găsit documente',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasNoDocumentsAtAll
                  ? 'Adaugă primul tău act și ActeAlert îți va aminti înainte să expire.'
                  : 'Schimbă filtrul sau termenul de căutare.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasNoDocumentsAtAll) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _openAddDocumentScreen,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Adaugă primul act',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleDocuments = filteredDocuments;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 12),
                    _buildHeroCard(),
                    const SizedBox(height: 14),
                    _buildSearchBar(),
                    const SizedBox(height: 10),
                    _buildFiltersRow(),
                    const SizedBox(height: 14),
                    const Text(
                      'Documentele mele',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: visibleDocuments.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 110),
                              itemCount: visibleDocuments.length,
                              itemBuilder: (context, index) {
                                return _buildDocumentCard(
                                  visibleDocuments[index],
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              onPressed: _openAddDocumentScreen,
              icon: const Icon(Icons.add),
              label: const Text(
                'Adaugă act',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}