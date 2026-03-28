import '../../../core/extension/font_family.dart';
import '../../../core/extension/font_size.dart';
import '../../../core/extension/language.dart';
import '../../../core/extension/theme_mode.dart';

class SettingsStates {
  final Thememode mode;
  final FontSizes fontSize;
  final Language language;
  final FontFamily fontFamily;
  final bool notifications;
  final bool isLoading;
  final String? errorMessage;

  const SettingsStates({
    this.mode = Thememode.system,
    this.fontSize = FontSizes.medium,
    this.language = Language.english,
    this.fontFamily = FontFamily.cairo,
    this.notifications = true,
    this.isLoading = false,
    this.errorMessage,
  });

  factory SettingsStates.initial() => const SettingsStates();

  // Derived getters
  bool get isDarkMode => mode == Thememode.dark;
  bool get isLightMode => mode == Thememode.light;
  bool get isSystemMode => mode == Thememode.system;
  bool get isArabic => language == Language.arabic;
  bool get isEnglish => language == Language.english;
  String get fontFamilyName => fontFamily.displayName;
  String get fontSizeName => fontSize.displayName;
  String get languageName => Language.getLanguageName(language);
  String get themeName => mode.displayName;

  SettingsStates copyWith({
    Thememode? mode,
    FontSizes? fontSize,
    Language? language,
    FontFamily? fontFamily,
    bool? notifications,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsStates(
      mode: mode ?? this.mode,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
      fontFamily: fontFamily ?? this.fontFamily,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
