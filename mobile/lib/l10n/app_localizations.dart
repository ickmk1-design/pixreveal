import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @play.
  ///
  /// In tr, this message translates to:
  /// **'OYNA'**
  String get play;

  /// No description provided for @shop.
  ///
  /// In tr, this message translates to:
  /// **'MAĞAZA'**
  String get shop;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'AYARLAR'**
  String get settings;

  /// No description provided for @premium.
  ///
  /// In tr, this message translates to:
  /// **'PREMİUM'**
  String get premium;

  /// No description provided for @categorySelect.
  ///
  /// In tr, this message translates to:
  /// **'KATEGORİ SEÇ'**
  String get categorySelect;

  /// No description provided for @superCars.
  ///
  /// In tr, this message translates to:
  /// **'SÜPER ARABALAR'**
  String get superCars;

  /// No description provided for @deepSpace.
  ///
  /// In tr, this message translates to:
  /// **'DERİN UZAY'**
  String get deepSpace;

  /// No description provided for @wildAnimals.
  ///
  /// In tr, this message translates to:
  /// **'VAHŞİ HAYVANLAR'**
  String get wildAnimals;

  /// No description provided for @beachGlamour.
  ///
  /// In tr, this message translates to:
  /// **'PLAJ GLAMOUR'**
  String get beachGlamour;

  /// No description provided for @fitness.
  ///
  /// In tr, this message translates to:
  /// **'FITNESS'**
  String get fitness;

  /// No description provided for @yourOwnImage.
  ///
  /// In tr, this message translates to:
  /// **'KENDİ FOTOĞRAFIN'**
  String get yourOwnImage;

  /// No description provided for @victory.
  ///
  /// In tr, this message translates to:
  /// **'ZAFER!'**
  String get victory;

  /// No description provided for @gameOver.
  ///
  /// In tr, this message translates to:
  /// **'OYUN BİTTİ'**
  String get gameOver;

  /// No description provided for @continueQ.
  ///
  /// In tr, this message translates to:
  /// **'Devam Edelim mi?'**
  String get continueQ;

  /// No description provided for @useToken.
  ///
  /// In tr, this message translates to:
  /// **'1 JETON KULLAN'**
  String get useToken;

  /// No description provided for @watchAd.
  ///
  /// In tr, this message translates to:
  /// **'REKLAM İZLE'**
  String get watchAd;

  /// No description provided for @quit.
  ///
  /// In tr, this message translates to:
  /// **'ÇIK'**
  String get quit;

  /// No description provided for @nextLevel.
  ///
  /// In tr, this message translates to:
  /// **'SONRAKİ LEVEL'**
  String get nextLevel;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'TEKRAR DENE'**
  String get retry;

  /// No description provided for @menu.
  ///
  /// In tr, this message translates to:
  /// **'MENÜ'**
  String get menu;

  /// No description provided for @score.
  ///
  /// In tr, this message translates to:
  /// **'SKOR'**
  String get score;

  /// No description provided for @level.
  ///
  /// In tr, this message translates to:
  /// **'LEVEL'**
  String get level;

  /// No description provided for @time.
  ///
  /// In tr, this message translates to:
  /// **'SÜRE'**
  String get time;

  /// No description provided for @fill.
  ///
  /// In tr, this message translates to:
  /// **'KAPLA'**
  String get fill;

  /// No description provided for @comboBonus.
  ///
  /// In tr, this message translates to:
  /// **'KOMBO BONUS'**
  String get comboBonus;

  /// No description provided for @goPremium.
  ///
  /// In tr, this message translates to:
  /// **'PREMIUM OL'**
  String get goPremium;

  /// No description provided for @subscribe.
  ///
  /// In tr, this message translates to:
  /// **'ABONE OL'**
  String get subscribe;

  /// No description provided for @monthly.
  ///
  /// In tr, this message translates to:
  /// **'AYLIK'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In tr, this message translates to:
  /// **'YILLIK'**
  String get yearly;

  /// No description provided for @restorePurchases.
  ///
  /// In tr, this message translates to:
  /// **'SATIN ALMALARI GERİ YÜKLE'**
  String get restorePurchases;

  /// No description provided for @soundEffects.
  ///
  /// In tr, this message translates to:
  /// **'Ses Efektleri'**
  String get soundEffects;

  /// No description provided for @music.
  ///
  /// In tr, this message translates to:
  /// **'Müzik'**
  String get music;

  /// No description provided for @vibration.
  ///
  /// In tr, this message translates to:
  /// **'Titreşim'**
  String get vibration;

  /// No description provided for @linkAccount.
  ///
  /// In tr, this message translates to:
  /// **'HESAP BAĞLA'**
  String get linkAccount;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları'**
  String get termsOfService;

  /// No description provided for @support.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get support;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @yourTurn.
  ///
  /// In tr, this message translates to:
  /// **'SIRA SENDE'**
  String get yourTurn;

  /// No description provided for @go.
  ///
  /// In tr, this message translates to:
  /// **'BAŞLA'**
  String get go;

  /// No description provided for @freeTokens.
  ///
  /// In tr, this message translates to:
  /// **'BEDAVA JETON'**
  String get freeTokens;

  /// No description provided for @tokenPacks.
  ///
  /// In tr, this message translates to:
  /// **'JETON PAKETLERİ'**
  String get tokenPacks;

  /// No description provided for @themePacks.
  ///
  /// In tr, this message translates to:
  /// **'PREMIUM TEMALAR'**
  String get themePacks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
