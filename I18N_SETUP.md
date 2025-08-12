# Internationalization (i18n) Setup for DangR

## Overview

DangR has been configured with comprehensive internationalization support to anticipate international deployment. The app supports 10 languages:

- 🇺🇸 English (en-US)
- 🇫🇷 French (fr-FR)
- 🇪🇸 Spanish (es-ES)
- 🇩🇪 German (de-DE)
- 🇮🇹 Italian (it-IT)
- 🇧🇷 Portuguese (pt-BR)
- 🇯🇵 Japanese (ja-JP)
- 🇰🇷 Korean (ko-KR)
- 🇨🇳 Chinese (zh-CN)
- 🇸🇦 Arabic (ar-SA)

## Architecture

### 1. Localization Structure

```
lib/
├── core/
│   ├── l10n/
│   │   └── app_localizations.dart    # Main localization class
│   └── widgets/
│       └── language_selector.dart    # Language selection UI
assets/
└── l10n/
    ├── app_en.arb                    # English translations
    └── app_fr.arb                    # French translations
```

### 2. Key Components

#### AppLocalizations Class
- **Location**: `lib/core/l10n/app_localizations.dart`
- **Purpose**: Central localization management
- **Features**:
  - Static translation maps for each language
  - Getter methods for all localized strings
  - Localization delegate for Flutter integration
  - Supported locales configuration

#### Language Selector Widget
- **Location**: `lib/core/widgets/language_selector.dart`
- **Purpose**: UI for language selection
- **Features**:
  - List of all supported languages with flags
  - Current language highlighting
  - Integration with Riverpod state management

#### Locale Provider
- **Location**: `lib/core/providers/providers.dart`
- **Purpose**: State management for language settings
- **Features**:
  - Persistent language storage using SharedPreferences
  - Automatic locale loading on app startup
  - Real-time language switching

## Implementation Details

### 1. Main App Configuration

The main app (`lib/main.dart`) is configured with:

```dart
MaterialApp.router(
  locale: locale,                                    // Current locale from provider
  supportedLocales: AppLocalizations.supportedLocales, // All supported locales
  localizationsDelegates: AppLocalizations.localizationsDelegates, // Delegates
  // ... other configurations
)
```

### 2. State Management

The locale is managed through Riverpod providers:

```dart
// Locale notifier for state management
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() => const Locale('en', 'US');
  
  Future<void> setLocale(Locale locale) async {
    // Save to SharedPreferences and update state
  }
  
  Future<void> loadSavedLocale() async {
    // Load saved locale from SharedPreferences
  }
}

// Provider for accessing current locale
@riverpod
Locale locale(LocaleRef ref) {
  return ref.watch(localeNotifierProvider);
}
```

### 3. Translation Files

#### ARB Files Structure
Translation files use the ARB (Application Resource Bundle) format:

```json
{
  "@@locale": "en",
  "appTitle": "DangR",
  "onboardingTitle": "Welcome to DangR",
  "@onboarding": {},
  "onboardingSubtitle": "Your urban safety companion"
}
```

#### Current Coverage
- **English**: Complete translation file (`app_en.arb`)
- **French**: Complete translation file (`app_fr.arb`)
- **Other languages**: Basic translations in `AppLocalizations` class

### 4. Usage in UI

#### Accessing Translations
```dart
// In any widget
final l10n = AppLocalizations.of(context);
Text(l10n.onboardingTitle)
```

#### Language Selection
```dart
// Navigate to language selector
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const LanguageSelector()),
);
```

## Adding New Languages

### 1. Create ARB File
Create a new file `assets/l10n/app_[language_code].arb`:

```json
{
  "@@locale": "es",
  "appTitle": "DangR",
  "onboardingTitle": "Bienvenido a DangR",
  // ... all other translations
}
```

### 2. Update AppLocalizations
Add the new language to the `_localizedValues` map in `app_localizations.dart`:

```dart
static const Map<String, String> _localizedValues = {
  'en': { /* English translations */ },
  'fr': { /* French translations */ },
  'es': { /* Spanish translations */ }, // Add new language
  // ... other languages
};
```

### 3. Add Language Support
Update the `isSupported` method in `_AppLocalizationsDelegate`:

```dart
@override
bool isSupported(Locale locale) {
  return ['en', 'fr', 'es', 'de', 'it', 'pt', 'ja', 'ko', 'zh', 'ar', 'es'].contains(locale.languageCode);
}
```

### 4. Update Language Selector
Add the new language to the `supportedLanguages` list in `language_selector.dart`:

```dart
final supportedLanguages = [
  // ... existing languages
  {'code': 'es', 'country': 'ES', 'name': l10n.languageSpanish, 'flag': '🇪🇸'},
];
```

## Best Practices

### 1. String Organization
- Group related strings with `@group` annotations in ARB files
- Use descriptive keys that indicate context
- Maintain consistent naming conventions

### 2. Pluralization
For strings with plural forms, use ICU message format:

```json
{
  "hazardCount": "{count, plural, =0{No hazards} =1{1 hazard} other{{count} hazards}}"
}
```

### 3. Context-Aware Translations
Some strings may need different translations based on context:

```json
{
  "reportButton": "Report",
  "@reportButton": {
    "description": "Button to report a hazard"
  }
}
```

### 4. RTL Support
For right-to-left languages (Arabic), ensure UI components support RTL layout:

```dart
// Use Directionality widget when needed
Directionality(
  textDirection: TextDirection.rtl,
  child: YourWidget(),
)
```

## Testing

### 1. Language Switching
- Test switching between all supported languages
- Verify persistence across app restarts
- Check for any layout issues with different text lengths

### 2. RTL Layout
- Test Arabic language specifically for RTL layout issues
- Verify text alignment and navigation flow

### 3. Text Overflow
- Test with long translations to ensure no text overflow
- Verify responsive design with different text lengths

## Future Enhancements

### 1. Dynamic Language Loading
- Load translation files dynamically from server
- Support for language packs and updates

### 2. Advanced Pluralization
- Implement full ICU message format support
- Handle complex pluralization rules

### 3. Context-Aware Translations
- Implement gender-aware translations
- Support for formal/informal address forms

### 4. Translation Management
- Integration with translation management systems
- Automated translation workflow
- Crowdsourced translation support

## Dependencies

The i18n implementation uses these Flutter packages:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  shared_preferences: ^2.2.2  # For persistent language storage
```

## Configuration

### 1. pubspec.yaml
Ensure the l10n assets are included:

```yaml
flutter:
  assets:
    - assets/l10n/
```

### 2. Build Configuration
For production builds, ensure all language files are included in the bundle.

## Troubleshooting

### Common Issues

1. **Strings not updating**: Ensure the locale provider is properly initialized
2. **Missing translations**: Check ARB file format and key consistency
3. **Layout issues**: Test with different text lengths and RTL languages
4. **Performance**: Monitor memory usage with multiple language files

### Debug Tips

- Use `flutter logs` to debug locale changes
- Test with device language settings
- Verify SharedPreferences storage
- Check for missing translation keys

This internationalization setup provides a solid foundation for DangR's global deployment while maintaining code quality and user experience standards.
