# dart run flutter_native_splash:create
# dart run flutter_launcher_icons
dart run easy_localization:generate --source-dir assets/translations
dart run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart
dart run build_runner build