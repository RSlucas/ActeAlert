import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'icon': Icons.description,
      'title': 'Toate actele într-un loc',
      'text':
          'Adaugă RCA, ITP, buletin, pașaport sau orice document important.',
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Primești notificări',
      'text': 'ActeAlert îți amintește înainte ca documentele tale să expire.',
    },
    {
      'icon': Icons.search,
      'title': 'Găsești rapid ce cauți',
      'text': 'Folosește categorii, filtre și căutare pentru documentele tale.',
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  void _nextPage() {
    if (currentPage == pages.length - 1) {
      _finishOnboarding();
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    'Sari peste',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = pages[index];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2563EB),
                                Color(0xFF60A5FA),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(34),
                          ),
                          child: Icon(
                            page['icon'],
                            color: Colors.white,
                            size: 52,
                          ),
                        ),
                        const SizedBox(height: 34),
                        Text(
                          page['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page['text'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) {
                    final isSelected = currentPage == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isSelected ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : Colors.black.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
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
                  onPressed: _nextPage,
                  child: Text(
                    isLastPage ? 'Începe' : 'Continuă',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}