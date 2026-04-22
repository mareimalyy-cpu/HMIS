import 'package:url_launcher/url_launcher.dart';

mixin UrlLauncherMixin {
  Future<void> myLaunchUrl(String url) async {
    await launchUrl(Uri.parse(url));
  }
}
