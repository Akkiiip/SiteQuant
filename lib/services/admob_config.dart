import 'package:flutter/foundation.dart';

class AdMobConfig {
  AdMobConfig._();

  static const String _androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  /// Supplied at release build time with
  /// --dart-define=ADMOB_BANNER_AD_UNIT_ID=ca-app-pub-.../...
  static const String _releaseBannerAdUnitId = String.fromEnvironment(
    'ADMOB_BANNER_AD_UNIT_ID',
  );

  static String? get androidBannerAdUnitId {
    if (!kReleaseMode) {
      return _androidTestBannerAdUnitId;
    }

    return _releaseBannerAdUnitId.isEmpty ? null : _releaseBannerAdUnitId;
  }
}
