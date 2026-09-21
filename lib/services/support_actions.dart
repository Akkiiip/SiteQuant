import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

typedef SupportUrlLauncher = Future<bool> Function(Uri uri);
typedef SupportTextSharer = Future<void> Function(String text);

class SupportActions {
  // Matches android/app/build.gradle.kts applicationId.
  static const packageId = 'com.sitequant.app';
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageId';
  static const shareText =
      "I'm using SiteQuant — a civil engineering calculator app for concrete, masonry, plaster, paint, tiles, shuttering, water tanks and more.\nhttps://play.google.com/store/apps/details?id=com.sitequant.app";
  static const _channel = MethodChannel('com.sitequant.app/support');

  final SupportUrlLauncher launch;
  final SupportTextSharer shareOperation;

  const SupportActions({
    this.launch = _launchExternal,
    this.shareOperation = _shareNative,
  });

  static Future<bool> _launchExternal(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  static Future<void> _shareNative(String text) =>
      _channel.invokeMethod<void>('shareText', {'text': text});

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launch(uri);
    } catch (_) {
      return false;
    }
  }

  Future<bool> rate() async {
    if (await _tryLaunch(Uri.parse('market://details?id=$packageId'))) {
      return true;
    }
    return _tryLaunch(Uri.parse(playStoreUrl));
  }

  Future<bool> share() async {
    try {
      await shareOperation(shareText);
      return true;
    } catch (_) {
      return false;
    }
  }
}



