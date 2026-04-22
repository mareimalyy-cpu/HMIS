import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/extension/font_family.dart';
import '../../../../core/extension/font_size.dart';
import '../../../../core/extension/language.dart';
import '../../../../core/extension/theme_mode.dart';
import '../../../../core/local_services/local_storage.dart';
import '../../data/models/settings_states.dart';
import '../../data/services/local/settings_local_service.dart';

part 'generated/settings_provider.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  late final SettingsLocalService _localService;

  @override
  Future<SettingsStates> build() async {
    _localService = SettingsLocalService(LocalStorage.instance);
    try {
      return _loadFromLocal() ?? SettingsStates.initial();
    } catch (e) {
      return SettingsStates(errorMessage: e.toString());
    }
  }

  SettingsStates? _loadFromLocal() {
    try {
      return SettingsStates(
        mode: _localService.getThemeMode(),
        fontSize: _localService.getFontSize(),
        language: _localService.getLanguage(),
        fontFamily: _localService.getFontFamily(),
        notifications: _localService.getNotifications(),
      );
    } catch (e) {
      log('error_loading_settings_from_local_e');
      return null;
    }
  }

  Future<void> changeThemeMode(Thememode mode) async {
    await _localService.saveThemeMode(mode);
    state = AsyncData(state.value!.copyWith(mode: mode));
  }

  Future<void> changeFontSize(FontSizes size) async {
    await _localService.saveFontSize(size);
    state = AsyncData(state.value!.copyWith(fontSize: size));
  }

  Future<void> changeLanguage(Language language) async {
    await _localService.saveLanguage(language);
    state = AsyncData(state.value!.copyWith(language: language));
  }

  Future<void> changeFontFamily(FontFamily family) async {
    await _localService.saveFontFamily(family);
    state = AsyncData(state.value!.copyWith(fontFamily: family));
  }

  Future<void> changeNotifications({required bool enabled}) async {
    await _localService.saveNotifications(enabled: enabled);
    state = AsyncData(state.value!.copyWith(notifications: enabled));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _loadFromLocal() ?? SettingsStates.initial();
    });
  }
}
