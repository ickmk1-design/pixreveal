import 'dart:ui' as ui;

/// Returns locale-suffixed asset path: assets/images/<base>_tr.webp or _en.webp
String localeAsset(String base) {
  final lang = ui.PlatformDispatcher.instance.locale.languageCode;
  final suffix = lang == 'tr' ? 'tr' : 'en';
  return 'assets/images/${base}_$suffix.webp';
}

bool isTurkish() =>
    ui.PlatformDispatcher.instance.locale.languageCode == 'tr';
