import 'package:flutter/material.dart';

/// Interaktiv startguide — 5 skjermer som viser de vanligste brukstilfellene.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.groups,
      title: 'Opprett grupper',
      description:
          'Start med å opprette en gruppe og legg til elever.\n'
          'Importer fra CSV eller legg til manuelt.',
    ),
    _OnboardingPage(
      icon: Icons.school,
      title: 'Klasseromsmodus',
      description:
          'Trykk på en elev for å registrere til stede.\n'
          'Trykk igjen for fravær. Hold inne for flere valg.',
    ),
    _OnboardingPage(
      icon: Icons.hiking,
      title: 'Turmodus',
      description:
          'Designet for en-hånds bruk ute.\n'
          'Søk etter elever med tre bokstaver — ett trykk registrerer.',
    ),
    _OnboardingPage(
      icon: Icons.description,
      title: 'Visma-rapport',
      description:
          'Generer rapport med ett trykk.\n'
          'Kopier tekst rett inn i Visma InSchool — ingen dobbeltarbeid.',
    ),
    _OnboardingPage(
      icon: Icons.lock,
      title: 'Trygt og privat',
      description:
          'All data lagres kryptert på din enhet.\n'
          'Biometrisk lås beskytter elevdata.\n'
          'Fungerer helt uten internett.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip-knapp
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onComplete,
                child: const Text('Hopp over'),
              ),
            ),
            // Sider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page.icon,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indikatorer og navigasjon
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prikker
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: index == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Neste/Ferdig-knapp
                  FilledButton(
                    onPressed: () {
                      if (isLast) {
                        widget.onComplete();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 48),
                    ),
                    child: Text(isLast ? 'Kom i gang' : 'Neste'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
