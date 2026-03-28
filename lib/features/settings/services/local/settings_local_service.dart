import '../../../../core/enum/constants.dart';
import '../../../../core/extension/font_family.dart';
import '../../../../core/extension/font_size.dart';
import '../../../../core/extension/language.dart';
import '../../../../core/extension/theme_mode.dart';
import '../../../../core/local_services/local_storage.dart';

class SettingsLocalService {
  final LocalStorage _storage;

  SettingsLocalService(this._storage);

  Thememode getThemeMode() {
    final value = _storage.get(Constants.theme.name);
    return Thememode.fromString(value as String?);
  }

  Future<void> saveThemeMode(Thememode mode) async {
    await _storage.add(Constants.theme.name, mode.toStr);
  }

  FontSizes getFontSize() {
    final value = _storage.get(Constants.fontSize.name);
    return FontSizes.fromString(value as String?);
  }

  Future<void> saveFontSize(FontSizes size) async {
    await _storage.add(Constants.fontSize.name, size.toStr);
  }

  Language getLanguage() {
    final value = _storage.get(Constants.language.name);
    return Language.fromString(value as String?);
  }

  Future<void> saveLanguage(Language language) async {
    await _storage.add(Constants.language.name, language.toStr);
  }

  FontFamily getFontFamily() {
    final value = _storage.get('fontFamily');
    return FontFamily.fromString(value as String?);
  }

  Future<void> saveFontFamily(FontFamily family) async {
    await _storage.add('fontFamily', family.toStr);
  }

  bool getNotifications() {
    final value = _storage.get('notifications');
    return value as bool? ?? true;
  }

  Future<void> saveNotifications(bool enabled) async {
    await _storage.add('notifications', enabled);
  }
}
