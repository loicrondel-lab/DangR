import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Bienvenue sur DangR',
      subtitle: 'Votre application de sécurité urbaine',
      description: 'Signalez et visualisez les zones à risque en temps réel pour vous déplacer en toute sécurité.',
      icon: Icons.shield,
      gradient: AppTheme.primaryGradient,
      lottieAsset: 'assets/animations/security.json',
    ),
    OnboardingStep(
      title: 'Signalez rapidement',
      subtitle: 'En 2 clics',
      description: 'Découvrez un incident ? Signalez-le en quelques secondes pour alerter votre communauté.',
      icon: Icons.warning_rounded,
      gradient: AppTheme.warningGradient,
      lottieAsset: 'assets/animations/report.json',
    ),
    OnboardingStep(
      title: 'Carte en temps réel',
      subtitle: 'Visualisez les risques',
      description: 'Consultez la carte interactive pour voir les incidents signalés autour de vous.',
      icon: Icons.map,
      gradient: AppTheme.secondaryGradient,
      lottieAsset: 'assets/animations/map.json',
    ),
    OnboardingStep(
      title: 'Communauté sécurisée',
      subtitle: 'Ensemble, plus forts',
      description: 'Rejoignez une communauté qui veille sur la sécurité de tous.',
      icon: Icons.people,
      gradient: const LinearGradient(
        colors: [AppTheme.primaryGreen, AppTheme.success],
      ),
      lottieAsset: 'assets/animations/community.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Contenu principal
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return _OnboardingStepWidget(step: _steps[index]);
                },
              ),
            ),
            
            // Indicateurs de page
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index 
                          ? AppTheme.primaryOrange
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Boutons de navigation
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Bouton Précédent
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: AppTheme.primaryOrange),
                        ),
                        child: const Text(
                          'Précédent',
                          style: TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  
                  if (_currentPage > 0) const SizedBox(width: 16),
                  
                  // Bouton Suivant/Commencer
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _steps.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _startApp();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage < _steps.length - 1 ? 'Suivant' : 'Commencer',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Lien de saut
            if (_currentPage < _steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextButton(
                  onPressed: _startApp,
                  child: Text(
                    'Passer',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startApp() {
    HapticFeedback.lightImpact();
    context.go('/auth');
  }
}

class OnboardingStep {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final String lottieAsset;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.lottieAsset,
  });
}

class _OnboardingStepWidget extends StatelessWidget {
  final OnboardingStep step;

  const _OnboardingStepWidget({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation Lottie
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: step.gradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                // Animation de fond
                Positioned.fill(
                  child: Lottie.asset(
                    step.lottieAsset,
                    fit: BoxFit.cover,
                  ),
                ),
                
                // Icône principale
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        step.icon,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Titre
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Sous-titre
          Text(
            step.subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryOrange,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            step.description,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
