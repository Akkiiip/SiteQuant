import 'package:flutter/material.dart';

import 'sitequant_banner_slot.dart';

/// One inline adaptive banner in the scrollable Home composition.
class HomeAdaptiveBannerSlot extends StatelessWidget {
  const HomeAdaptiveBannerSlot({super.key, this.previewAd});

  final Widget? previewAd;

  @override
  Widget build(BuildContext context) => SiteQuantBannerSlot(
    placement: SiteQuantBannerPlacement.inline,
    slotKey: const ValueKey('home-ad-slot'),
    previewAd: previewAd,
  );
}
