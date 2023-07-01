import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../block/settings/settings_cubit.dart';

class AppLocalizations {
  static List<String> supportedLanguages = ['en', 'tr', 'fr'];

  late Locale locale;
  late Map<String, String> _valueText;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static bool isSupported(String locale) {
    return supportedLanguages.any((element) => locale.contains(element));
  }

  static String getSupportedLocaleCode(String locale) {
    return supportedLanguages
        .where((element) => locale.contains(element))
        .first;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  Future loadTranslateFile() async {
    String _langFile =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');

    Map<String, dynamic> _json = jsonDecode(_langFile);
    _valueText = _json.map((key, value) => MapEntry(key, value.toString()));
  }

  String getTranslate(String key) {
    return _valueText[key]!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLanguages.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations appLocalizations = AppLocalizations(locale);
    await appLocalizations.loadTranslateFile();
    return appLocalizations;
  }

  @override
  bool shouldReload(covariant AppLocalizationsDelegate old) => false;
}

Locale? localeResolutionCallback(
    Locale? deviceLocale, Iterable<Locale> supportedLocales) {
  for (var supportedLocale in supportedLocales) {
    if (supportedLocale.languageCode == deviceLocale?.languageCode &&
        supportedLocale.countryCode == deviceLocale?.countryCode) {
      return supportedLocale;
    }
  }
  return supportedLocales.first;
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showActionSheet(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    var settings = context.read<SettingsCubit>();

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(appLocalizations.getTranslate('language_selection')),
        message: Text(appLocalizations.getTranslate('language_selection2')),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              settings.changeLanguage("tr");
              Navigator.pop(context);
            },
            child: const Text('Turkce'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              settings.changeLanguage("en");
              Navigator.pop(context);
            },
            child: const Text('English'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(appLocalizations.getTranslate('cancel')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    var settings = context.watch<SettingsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.getTranslate('settings')),
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () {
              _showActionSheet(context);
            },
            child: Text(
              '${appLocalizations.getTranslate('language')}: ${settings.state.language}',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${appLocalizations.getTranslate('darkMode')}: '),
              Switch(
                value: settings.state.darkMode,
                onChanged: (value) {
                  settings.changeDarkMode(value);
                },
              ),
            ],
          ),
          Divider(),
          ElevatedButton(
            child: Text('Hello World'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
