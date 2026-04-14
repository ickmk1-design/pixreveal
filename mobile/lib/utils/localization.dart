import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class L {
  static String _lang = 'tr';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('lang') ?? _detectLang();
  }

  static String _detectLang() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    return locale.languageCode == 'tr' ? 'tr' : 'en';
  }

  static Future<void> setLang(String lang) async {
    _lang = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang);
  }

  static String get lang => _lang;
  static bool get isTr => _lang == 'tr';

  static String get(String key) => (_strings[key]?[_lang]) ?? key;

  static const _strings = <String, Map<String, String>>{
    // Menu
    'play': {'tr': 'OYNA', 'en': 'PLAY'},
    'shop': {'tr': 'MAĞAZA', 'en': 'SHOP'},
    'settings': {'tr': 'AYARLAR', 'en': 'SETTINGS'},
    'levels': {'tr': 'BÖLÜMLER', 'en': 'LEVELS'},
    'collection': {'tr': 'KOLEKSİYON', 'en': 'COLLECTION'},

    // Game
    'paused': {'tr': 'DURAKLATILDI', 'en': 'PAUSED'},
    'resume': {'tr': 'DEVAM', 'en': 'RESUME'},
    'restart': {'tr': 'YENİDEN', 'en': 'RESTART'},
    'quit': {'tr': 'ÇIK', 'en': 'QUIT'},
    'game_over': {'tr': 'OYUN BİTTİ', 'en': 'GAME OVER'},
    'continue_token': {'tr': 'DEVAM (1 JETON)', 'en': 'CONTINUE (1 TOKEN)'},
    'main_menu': {'tr': 'ANA MENÜ', 'en': 'MAIN MENU'},
    'captured': {'tr': 'AÇILDI', 'en': 'CAPTURED'},
    'insert_coin': {'tr': 'JETON AT', 'en': 'INSERT COIN'},
    'tap_skip': {'tr': 'ATLAMAK İÇİN DOKUN', 'en': 'TAP TO SKIP'},
    'no_tokens': {'tr': 'JETON YOK!', 'en': 'NO TOKENS!'},
    'tokens_left': {'tr': 'jeton kaldı', 'en': 'tokens left'},

    // Level select
    'locked': {'tr': 'Önce Level {0}\'i geç!', 'en': 'Complete Level {0} first!'},
    'neon_city': {'tr': 'NEON ŞEHİR', 'en': 'NEON CITY'},

    // Result
    'level_complete': {'tr': 'BÖLÜM TAMAM!', 'en': 'LEVEL COMPLETE!'},
    'next_level': {'tr': 'SONRAKİ', 'en': 'NEXT'},
    'retry': {'tr': 'TEKRAR', 'en': 'RETRY'},
    'score': {'tr': 'PUAN', 'en': 'SCORE'},
    'time': {'tr': 'SÜRE', 'en': 'TIME'},

    // HUD
    'lives': {'tr': 'CAN', 'en': 'LIVES'},
    'tokens': {'tr': 'JETON', 'en': 'TOKENS'},
    'level': {'tr': 'SEVİYE', 'en': 'LEVEL'},

    // Settings
    'language': {'tr': 'DİL', 'en': 'LANGUAGE'},
    'sound': {'tr': 'SES', 'en': 'SOUND'},
    'music': {'tr': 'MÜZİK', 'en': 'MUSIC'},

    // Image select
    'choose_image': {'tr': 'RESİM SEÇ', 'en': 'CHOOSE IMAGE'},
    'custom_image': {'tr': 'KENDİ RESMİN', 'en': 'YOUR IMAGE'},
    'premium': {'tr': 'PREMIUM', 'en': 'PREMIUM'},
    'start_in': {'tr': 'BAŞLIYOR', 'en': 'STARTING'},

    // Popups
    'great': {'tr': 'HARİKA!', 'en': 'GREAT!'},
    'excellent': {'tr': 'MÜKEMMEL!', 'en': 'EXCELLENT!'},
    'combo': {'tr': 'KOMBO', 'en': 'COMBO'},

    // Shop
    'watch_ad': {'tr': 'REKLAM İZLE', 'en': 'WATCH AD'},
    'watch_ad_for_tokens': {'tr': 'Reklam izle, jeton kazan!', 'en': 'Watch ad, earn tokens!'},
    'free_tokens': {'tr': 'BEDAVA JETON', 'en': 'FREE TOKENS'},
    'token_packs': {'tr': 'JETON PAKETLERİ', 'en': 'TOKEN PACKS'},
    'theme_packs': {'tr': 'TEMA PAKETLERİ', 'en': 'THEME PACKS'},

    // Settings
    'sound_effects': {'tr': 'Ses Efektleri', 'en': 'Sound Effects'},
    'vibration': {'tr': 'Titreşim', 'en': 'Vibration'},
    'account': {'tr': 'HESAP', 'en': 'ACCOUNT'},
    'provider_guest': {'tr': 'Sağlayıcı: Misafir', 'en': 'Provider: Guest'},
    'link_account': {'tr': 'HESAP BAĞLA', 'en': 'LINK ACCOUNT'},
    'purchases': {'tr': 'SATINALMA', 'en': 'PURCHASES'},
    'restore_purchases': {'tr': 'SATINALMALARI GERİ YÜKLE', 'en': 'RESTORE PURCHASES'},
    'legal': {'tr': 'YASAL', 'en': 'LEGAL'},
    'privacy_policy': {'tr': 'Gizlilik Politikası', 'en': 'Privacy Policy'},
    'terms_of_service': {'tr': 'Kullanım Şartları', 'en': 'Terms of Service'},

    // Result
    'victory': {'tr': 'ZAFER!', 'en': 'VICTORY!'},
    'combo_bonus': {'tr': 'KOMBO BONUS', 'en': 'COMBO BONUS'},
    'continue_question': {'tr': 'Devam etmek ister misin?', 'en': 'Want to continue?'},
    'use_token': {'tr': 'JETON KULLAN', 'en': 'USE TOKEN'},
    'menu': {'tr': 'MENÜ', 'en': 'MENU'},

    // Paywall
    'go_premium': {'tr': 'PREMIUM OL', 'en': 'GO PREMIUM'},
    'subscribe': {'tr': 'ABONE OL', 'en': 'SUBSCRIBE'},
    'loading': {'tr': 'YÜKLENİYOR...', 'en': 'LOADING...'},

    // Categories
    'select_category': {'tr': 'KATEGORİ SEÇ', 'en': 'SELECT CATEGORY'},
    'your_own_image': {'tr': 'KENDİ FOTOĞRAFIN', 'en': 'YOUR OWN IMAGE'},
    'super_cars': {'tr': 'SÜPER ARABALAR', 'en': 'SUPER CARS'},
    'deep_space': {'tr': 'DERİN UZAY', 'en': 'DEEP SPACE'},
    'wild_animals': {'tr': 'VAHŞİ HAYVANLAR', 'en': 'WILD ANIMALS'},
    'beach_glamour': {'tr': 'PLAJ GLAMOUR', 'en': 'BEACH GLAMOUR'},
    'fitness': {'tr': 'FİTNESS', 'en': 'FITNESS'},
  };
}
