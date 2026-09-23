// The pinned ads SDK deprecates compact anchored sizes in favor of large ads.
// A compact persistent banner is required beside calculator forms.
// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_consent_manager.dart';
import '../services/admob_config.dart';

enum SiteQuantBannerPlacement { anchored, inline }

/// Shared loading, disposal and sizing for the app's single-placement banners.
class SiteQuantBannerSlot extends StatefulWidget {
  const SiteQuantBannerSlot({
    super.key,
    required this.placement,
    this.slotKey,
    this.previewAd,
  });

  final SiteQuantBannerPlacement placement;
  final Key? slotKey;

  /// Test seam: renders layout without an AdMob platform call.
  final Widget? previewAd;

  @override
  State<SiteQuantBannerSlot> createState() => _SiteQuantBannerSlotState();
}

class _SiteQuantBannerSlotState extends State<SiteQuantBannerSlot> {
  BannerAd? _ad;
  AdSize? _displaySize;
  int? _availableWidth;
  int _generation = 0;
  bool _loading = false;

  bool get _inline => widget.placement == SiteQuantBannerPlacement.inline;
  double get _verticalInset => _inline ? 4 : 8;

  @override
  void initState() {
    super.initState();
    AdConsentManager.canRequestAds.addListener(_onConsentChanged);
  }

  @override
  void dispose() {
    AdConsentManager.canRequestAds.removeListener(_onConsentChanged);
    _ad?.dispose();
    super.dispose();
  }

  void _onConsentChanged() {
    if (AdConsentManager.canRequestAds.value) {
      _loadIfAllowed();
      return;
    }
    _clearAd();
  }

  void _clearAd() {
    _generation++;
    final previous = _ad;
    if (mounted) {
      setState(() {
        _ad = null;
        _displaySize = null;
        _loading = false;
      });
    }
    previous?.dispose();
  }

  Future<void> _loadIfAllowed() async {
    final width = _availableWidth;
    if (!mounted ||
        widget.previewAd != null ||
        width == null ||
        _loading ||
        _ad != null ||
        !AdConsentManager.canRequestAds.value ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    final id = AdMobConfig.androidBannerAdUnitId;
    if (id == null) return;
    _loading = true;
    final generation = _generation;
    try {
      AdSize? requested;
      if (_inline) {
        requested = AdSize.getInlineAdaptiveBannerAdSize(width, 50);
      } else {
        // Keep the compact anchored format; the newer large format dominates forms.
        requested =
            await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
              width,
            );
      }
      if (!mounted || generation != _generation || requested == null) {
        if (generation == _generation) _loading = false;
        return;
      }
      final ad = BannerAd(
        adUnitId: id,
        size: requested,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (loadedAd) async {
            AdSize? actual;
            try {
              actual = await (loadedAd as BannerAd).getPlatformAdSize();
            } catch (_) {
              actual = null;
            }
            if (!mounted || !identical(_ad, loadedAd)) {
              loadedAd.dispose();
              return;
            }
            setState(() => _displaySize = actual ?? requested);
          },
          onAdFailedToLoad: (failedAd, _) {
            failedAd.dispose();
            if (mounted && identical(_ad, failedAd)) {
              setState(() {
                _ad = null;
                _displaySize = null;
                _loading = false;
              });
            }
          },
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (_) {
      if (mounted && generation == _generation) {
        _clearAd();
      }
    }
  }

  void _widthChanged(int width) {
    if (!mounted || _availableWidth != width) return;
    _clearAd();
    _loadIfAllowed();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = (constraints.maxWidth - 32).floor().clamp(1, 2000);
      if (_availableWidth != width) {
        _availableWidth = width;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _widthChanged(width),
        );
      }
      final size = _displaySize;
      final height = (size?.height.toDouble() ?? 50) + _verticalInset * 2;
      return Container(
        key: widget.slotKey,
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: .45),
            ),
          ),
        ),
        alignment: Alignment.center,
        child:
            widget.previewAd ??
            (size != null && _ad != null
                ? SizedBox(
                    width: size.width.toDouble(),
                    height: size.height.toDouble(),
                    child: AdWidget(ad: _ad!),
                  )
                : const SizedBox.shrink()),
      );
    },
  );
}
