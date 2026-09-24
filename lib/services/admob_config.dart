import 'package:flutter/foundation.dart';

class AdMobConfig {
  AdMobConfig._();

  static const String _androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  static const String androidTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  /// Supplied at release build time with
  /// --dart-define=ADMOB_BANNER_AD_UNIT_ID=ca-app-pub-.../...
  static const String _releaseBannerAdUnitId = String.fromEnvironment(
    'ADMOB_BANNER_AD_UNIT_ID',
  );

  /// Supplied at release build time with
  /// --dart-define=ADMOB_INTERSTITIAL_AD_UNIT_ID=ca-app-pub-.../...
  static const String _releaseInterstitialAdUnitId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_AD_UNIT_ID',
  );

  static String? get androidBannerAdUnitId {
    if (!kReleaseMode) {
      return _androidTestBannerAdUnitId;
    }

    return _releaseBannerAdUnitId.isEmpty ? null : _releaseBannerAdUnitId;
  }

  static String? get androidInterstitialAdUnitId => interstitialAdUnitIdFor(
    releaseMode: kReleaseMode,
    releaseAdUnitId: _releaseInterstitialAdUnitId,
  );

  @visibleForTesting
  static String? interstitialAdUnitIdFor({
    required bool releaseMode,
    required String releaseAdUnitId,
  }) {
    if (!releaseMode) return androidTestInterstitialAdUnitId;
    return releaseAdUnitId.trim().isEmpty ? null : releaseAdUnitId.trim();
  }
}
