import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_consent_manager.dart';
import 'admob_config.dart';
import 'analytics_service.dart';

class InterstitialAdService {
  InterstitialAdService._({InterstitialLoader? loader})
    : _loader = loader ?? _GoogleInterstitialLoader();
  static final instance = InterstitialAdService._();
  static const int completedCalculationsPerInterstitial = 3;
  final InterstitialLoader _loader;
  InterstitialHandle? _ad;
  bool _loading = false;
  bool _showing = false;
  int _completedCalculations = 0;
  @visibleForTesting
  factory InterstitialAdService.forTesting(InterstitialLoader loader) =>
      InterstitialAdService._(loader: loader);
  @visibleForTesting
  int get completedCalculations => _completedCalculations;

  Future<void> preload() async {
    if (_loading || _ad != null || !AdConsentManager.canRequestAds.value)
      return;
    _loading = true;
    AnalyticsService.logInterstitialLoadAttempted();
    try {
      _ad = await _loader.load();
      AnalyticsService.logInterstitialLoaded();
    } catch (_) {
      AnalyticsService.logInterstitialLoadFailed();
    } finally {
      _loading = false;
    }
  }

  void onCalculationCompleted() {
    _completedCalculations++;
    if (_completedCalculations < completedCalculationsPerInterstitial) {
      unawaited(preload());
      return;
    }
    _completedCalculations = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(showIfReady());
    });
  }

  Future<void> showIfReady() async {
    if (_showing || _ad == null) {
      unawaited(preload());
      return;
    }
    final ad = _ad!;
    _ad = null;
    _showing = true;
    AnalyticsService.logInterstitialShowAttempted();
    try {
      ad.setCallbacks(
        onShown: AnalyticsService.logInterstitialShown,
        onDismissed: () {
          AnalyticsService.logInterstitialDismissed();
          _finish(ad);
        },
        onFailedToShow: () {
          AnalyticsService.logInterstitialFailed();
          _finish(ad);
        },
      );
      ad.show();
    } catch (_) {
      AnalyticsService.logInterstitialFailed();
      _finish(ad);
    }
  }

  void _finish(InterstitialHandle ad) {
    ad.dispose();
    _showing = false;
    unawaited(preload());
  }
}

abstract interface class InterstitialLoader {
  Future<InterstitialHandle> load();
}

abstract interface class InterstitialHandle {
  void setCallbacks({
    required VoidCallback onShown,
    required VoidCallback onDismissed,
    required VoidCallback onFailedToShow,
  });
  void show();
  void dispose();
}

class _GoogleInterstitialLoader implements InterstitialLoader {
  @override
  Future<InterstitialHandle> load() {
    final result = Completer<InterstitialHandle>();
    InterstitialAd.load(
      adUnitId: AdMobConfig.androidTestInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => result.complete(_GoogleInterstitial(ad)),
        onAdFailedToLoad: result.completeError,
      ),
    );
    return result.future;
  }
}

class _GoogleInterstitial implements InterstitialHandle {
  _GoogleInterstitial(this._ad);
  final InterstitialAd _ad;
  @override
  void setCallbacks({
    required VoidCallback onShown,
    required VoidCallback onDismissed,
    required VoidCallback onFailedToShow,
  }) {
    _ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => onShown(),
      onAdDismissedFullScreenContent: (_) => onDismissed(),
      onAdFailedToShowFullScreenContent: (_, __) => onFailedToShow(),
    );
  }

  @override
  void show() => _ad.show();
  @override
  void dispose() => _ad.dispose();
}
