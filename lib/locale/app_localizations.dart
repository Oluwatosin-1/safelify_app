import 'package:flutter/material.dart';
import 'package:safelify/locale/base_language_key.dart';
import 'package:safelify/locale/language_ar.dart';
import 'package:safelify/locale/language_de.dart';
import 'package:safelify/locale/language_en.dart';
import 'package:safelify/locale/language_fr.dart';
import 'package:safelify/locale/language_hi.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:safelify/locale/language_ja.dart';
import 'package:safelify/locale/language_pt.dart';
import 'package:safelify/locale/language_ru.dart';
import 'package:safelify/locale/language_se.dart';
import 'package:safelify/locale/language_zh.dart';

class AppLocalizations extends LocalizationsDelegate<BaseLanguage> {
  const AppLocalizations();

  @override
  Future<BaseLanguage> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'ar':
        return LanguageAr();
      case 'hi':
        return LanguageHi();
      case 'fr':
        return LanguageFr();
      case 'de':
        return LanguageDe();
      case 'zh':
        return LanguageZh();
      case 'se':
        return LanguageSe();
      case 'ru':
        return LanguageRu();
      case 'pt':
        return LanguagePt();
      case 'ja':
        return LanguageJa();

      default:
        return LanguageEn();
    }
  }

  @override
  bool isSupported(Locale locale) =>
      LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<BaseLanguage> old) => false;
}
