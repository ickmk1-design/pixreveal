import '../utils/localization.dart';

/// Returns the correct background image path based on current language.
/// TR images have Turkish text baked in, EN images have English text.
String uiBg(String baseName) {
  if (L.isTr) {
    return 'assets/images/ui/${baseName}_tr.png';
  }
  return 'assets/images/ui/$baseName.png';
}
