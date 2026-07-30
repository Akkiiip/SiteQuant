import 'package:flutter/material.dart';

/// Reserved fixed-height location for a future AdMob banner.
class BottomBannerSlot extends StatelessWidget {
  const BottomBannerSlot({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFDCE4EE))),
        ),
        alignment: Alignment.center,
        child: Text(
          'Advertisement',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF7A8798),
              ),
        ),
      ),
    );
  }
}
