import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdConsentManager {
  AdConsentManager._();

  static final ValueNotifier<bool> canRequestAds = ValueNotifier(false);
  static final ValueNotifier<bool> privacyOptionsRequired = ValueNotifier(
    false,
  );
  static bool _isInitialized = false;
  static bool _mobileAdsInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    _isInitialized = true;

    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => _completeConsentFlow(completer),
      (_) => _finishConsentFlow(completer),
    );

    await completer.future;
  }

  static void _completeConsentFlow(Completer<void> completer) {
    ConsentForm.loadAndShowConsentFormIfRequired(
      (_) => _finishConsentFlow(completer),
    );
  }

  static Future<void> _finishConsentFlow(Completer<void> completer) async {
    privacyOptionsRequired.value =
        await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;

    if (await ConsentInformation.instance.canRequestAds()) {
      canRequestAds.value = true;
      if (!_mobileAdsInitialized) {
        _mobileAdsInitialized = true;
        await MobileAds.instance.initialize();
      }
    }

    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  static Future<void> showPrivacyOptions() async {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((_) {
      _refreshPrivacyOptionsStatus(completer);
    });
    await completer.future;
  }

  static Future<void> _refreshPrivacyOptionsStatus(
    Completer<void> completer,
  ) async {
    privacyOptionsRequired.value =
        await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
    completer.complete();
  }
}
