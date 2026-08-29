import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_consent_manager.dart';
import '../services/admob_config.dart';

/// Fixed banner placement used by [AppScaffold].
class BottomBannerSlot extends StatefulWidget {
  const BottomBannerSlot({super.key});

  @override
  State<BottomBannerSlot> createState() => _BottomBannerSlotState();
}

class _BottomBannerSlotState extends State<BottomBannerSlot> {
  BannerAd? _bannerAd;
  var _isLoaded = false;

  @override
  void initState() {
    super.initState();
    AdConsentManager.canRequestAds.addListener(_loadBannerIfAllowed);
    _loadBannerIfAllowed();
  }

  @override
  void dispose() {
    AdConsentManager.canRequestAds.removeListener(_loadBannerIfAllowed);
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerIfAllowed() {
    if (!AdConsentManager.canRequestAds.value || _bannerAd != null) {
      return;
    }

    final adUnitId = AdMobConfig.androidBannerAdUnitId;
    if (adUnitId == null) {
      return;
    }

    final bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) {
            setState(() => _bannerAd = null);
          }
        },
      ),
    );

    _bannerAd = bannerAd;
    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        height: _bannerAd!.size.height.toDouble(),
        width: double.infinity,
        alignment: Alignment.center,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
