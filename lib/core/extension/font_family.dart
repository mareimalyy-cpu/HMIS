enum FontFamily {
  cairo('Cairo');

  const FontFamily(this.displayName);
  final String displayName;

  static FontFamily fromString(String? value) {
    if (value == null) return FontFamily.cairo;

    return FontFamily.values.firstWhere(
      (font) => font.name == value || font.displayName == value,
      orElse: () => FontFamily.cairo,
    );
  }

  String get toStr => name;

  String get fontFamily => displayName;
}

extension FontFamilyExtension on FontFamily {
  String get displayName => this.displayName;

  String get fontFamily => this.fontFamily;

  static FontFamily get defaultFont => FontFamily.cairo;
}
