import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('fr', 'FR'),
    Locale('es', 'ES'),
    Locale('de', 'DE'),
    Locale('it', 'IT'),
    Locale('pt', 'BR'),
    Locale('ja', 'JP'),
    Locale('ko', 'KR'),
    Locale('zh', 'CN'),
    Locale('ar', 'SA'),
  ];

  // English translations
  static const Map<String, String> _localizedValues = {
    'en': {
      'appTitle': 'DangR',
      'onboardingTitle': 'Welcome to DangR',
      'onboardingSubtitle': 'Your urban safety companion',
      'onboardingGetStarted': 'Get Started',
      'onboardingSkip': 'Skip',
      'onboardingNext': 'Next',
      'authTitle': 'Welcome Back',
      'authSignIn': 'Sign In',
      'authSignUp': 'Sign Up',
      'authSignInAnonymously': 'Continue as Guest',
      'mapTitle': 'Map',
      'feedTitle': 'Activity Feed',
      'profileTitle': 'Profile',
      'profileLanguage': 'Language',
      'languageEnglish': 'English',
      'languageFrench': 'Français',
      'languageSpanish': 'Español',
      'languageGerman': 'Deutsch',
      'languageItalian': 'Italiano',
      'languagePortuguese': 'Português',
      'languageJapanese': '日本語',
      'languageKorean': '한국어',
      'languageChinese': '中文',
      'languageArabic': 'العربية',
    },
    'fr': {
      'appTitle': 'DangR',
      'onboardingTitle': 'Bienvenue sur DangR',
      'onboardingSubtitle': 'Votre compagnon de sécurité urbaine',
      'onboardingGetStarted': 'Commencer',
      'onboardingSkip': 'Passer',
      'onboardingNext': 'Suivant',
      'authTitle': 'Bon Retour',
      'authSignIn': 'Se Connecter',
      'authSignUp': 'S\'inscrire',
      'authSignInAnonymously': 'Continuer en tant qu\'invité',
      'mapTitle': 'Carte',
      'feedTitle': 'Fil d\'Activité',
      'profileTitle': 'Profil',
      'profileLanguage': 'Langue',
      'languageEnglish': 'English',
      'languageFrench': 'Français',
      'languageSpanish': 'Español',
      'languageGerman': 'Deutsch',
      'languageItalian': 'Italiano',
      'languagePortuguese': 'Português',
      'languageJapanese': '日本語',
      'languageKorean': '한국어',
      'languageChinese': '中文',
      'languageArabic': 'العربية',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]?['appTitle'] ?? 'DangR';
  String get onboardingTitle => _localizedValues[locale.languageCode]?['onboardingTitle'] ?? 'Welcome to DangR';
  String get onboardingSubtitle => _localizedValues[locale.languageCode]?['onboardingSubtitle'] ?? 'Your urban safety companion';
  String get onboardingGetStarted => _localizedValues[locale.languageCode]?['onboardingGetStarted'] ?? 'Get Started';
  String get onboardingSkip => _localizedValues[locale.languageCode]?['onboardingSkip'] ?? 'Skip';
  String get onboardingNext => _localizedValues[locale.languageCode]?['onboardingNext'] ?? 'Next';
  String get authTitle => _localizedValues[locale.languageCode]?['authTitle'] ?? 'Welcome Back';
  String get authSignIn => _localizedValues[locale.languageCode]?['authSignIn'] ?? 'Sign In';
  String get authSignUp => _localizedValues[locale.languageCode]?['authSignUp'] ?? 'Sign Up';
  String get authSignInAnonymously => _localizedValues[locale.languageCode]?['authSignInAnonymously'] ?? 'Continue as Guest';
  String get mapTitle => _localizedValues[locale.languageCode]?['mapTitle'] ?? 'Map';
  String get feedTitle => _localizedValues[locale.languageCode]?['feedTitle'] ?? 'Activity Feed';
  String get profileTitle => _localizedValues[locale.languageCode]?['profileTitle'] ?? 'Profile';
  String get profileLanguage => _localizedValues[locale.languageCode]?['profileLanguage'] ?? 'Language';
  String get languageEnglish => _localizedValues[locale.languageCode]?['languageEnglish'] ?? 'English';
  String get languageFrench => _localizedValues[locale.languageCode]?['languageFrench'] ?? 'Français';
  String get languageSpanish => _localizedValues[locale.languageCode]?['languageSpanish'] ?? 'Español';
  String get languageGerman => _localizedValues[locale.languageCode]?['languageGerman'] ?? 'Deutsch';
  String get languageItalian => _localizedValues[locale.languageCode]?['languageItalian'] ?? 'Italiano';
  String get languagePortuguese => _localizedValues[locale.languageCode]?['languagePortuguese'] ?? 'Português';
  String get languageJapanese => _localizedValues[locale.languageCode]?['languageJapanese'] ?? '日本語';
  String get languageKorean => _localizedValues[locale.languageCode]?['languageKorean'] ?? '한국어';
  String get languageChinese => _localizedValues[locale.languageCode]?['languageChinese'] ?? '中文';
  String get languageArabic => _localizedValues[locale.languageCode]?['languageArabic'] ?? 'العربية';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr', 'es', 'de', 'it', 'pt', 'ja', 'ko', 'zh', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
