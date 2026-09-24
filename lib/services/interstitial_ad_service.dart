import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_consent_manager.dart';
import 'admob_config.dart';
import 'analytics_service.dart';

class InterstitialAdService {
  InterstitialAdService._({InterstitialLoader? loader})
    : _loader =
          loader ??
          _GoogleInterstitialLoader(AdMobConfig.androidInterstitialAdUnitId) {
    AdConsentManager.canRequestAds.addListener(_onConsentChanged);
  }
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

  void _onConsentChanged() {
    if (AdConsentManager.canRequestAds.value) {
      unawaited(preload());
      return;
    }
    final ad = _ad;
    _ad = null;
    ad?.dispose();
  }

  @visibleForTesting
  void dispose() {
    AdConsentManager.canRequestAds.removeListener(_onConsentChanged);
    final ad = _ad;
    _ad = null;
    ad?.dispose();
  }

  Future<void> preload() async {
    if (_loading || _ad != null || !AdConsentManager.canRequestAds.value)
      return;
    _loading = true;
    AnalyticsService.logInterstitialLoadAttempted();
    try {
      final loaded = await _loader.load();
      if (!AdConsentManager.canRequestAds.value) {
        loaded.dispose();
        return;
      }
      _ad = loaded;
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
    if (!AdConsentManager.canRequestAds.value) {
      final ad = _ad;
      _ad = null;
      ad?.dispose();
      return;
    }
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
  const _GoogleInterstitialLoader(this.adUnitId);

  final String? adUnitId;

  @override
  Future<InterstitialHandle> load() {
    final id = adUnitId;
    if (id == null) {
      return Future.error(
        StateError('Production interstitial ad unit ID is not configured.'),
      );
    }
    final result = Completer<InterstitialHandle>();
    InterstitialAd.load(
      adUnitId: id,
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
