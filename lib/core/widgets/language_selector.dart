import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    final supportedLanguages = [
      {'code': 'en', 'country': 'US', 'name': l10n.languageEnglish, 'flag': '🇺🇸'},
      {'code': 'fr', 'country': 'FR', 'name': l10n.languageFrench, 'flag': '🇫🇷'},
      {'code': 'es', 'country': 'ES', 'name': l10n.languageSpanish, 'flag': '🇪🇸'},
      {'code': 'de', 'country': 'DE', 'name': l10n.languageGerman, 'flag': '🇩🇪'},
      {'code': 'it', 'country': 'IT', 'name': l10n.languageItalian, 'flag': '🇮🇹'},
      {'code': 'pt', 'country': 'BR', 'name': l10n.languagePortuguese, 'flag': '🇧🇷'},
      {'code': 'ja', 'country': 'JP', 'name': l10n.languageJapanese, 'flag': '🇯🇵'},
      {'code': 'ko', 'country': 'KR', 'name': l10n.languageKorean, 'flag': '🇰🇷'},
      {'code': 'zh', 'country': 'CN', 'name': l10n.languageChinese, 'flag': '🇨🇳'},
      {'code': 'ar', 'country': 'SA', 'name': l10n.languageArabic, 'flag': '🇸🇦'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileLanguage),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: supportedLanguages.length,
        itemBuilder: (context, index) {
          final language = supportedLanguages[index];
          final locale = Locale(language['code']!, language['country']!);
          final isSelected = currentLocale.languageCode == language['code'];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Text(
                language['flag']!,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                language['name']!,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              onTap: () {
                ref.read(localeNotifierProvider.notifier).setLocale(locale);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
