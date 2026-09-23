import 'package:flutter/material.dart';

import 'sitequant_banner_slot.dart';

/// Single separated anchored banner for calculator flows and AppScaffold.
class BottomBannerSlot extends StatelessWidget {
  const BottomBannerSlot({super.key, this.previewAd});

  final Widget? previewAd;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SiteQuantBannerSlot(
      placement: SiteQuantBannerPlacement.anchored,
      slotKey: const ValueKey('calculator-ad-slot'),
      previewAd: previewAd,
    ),
  );
}
