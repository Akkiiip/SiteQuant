import 'package:flutter/material.dart';

import 'bottom_banner_slot.dart';

typedef AppBodyBuilder =
    Widget Function(BuildContext context, EdgeInsets padding);

class AppScaffold extends StatelessWidget {
  final String title;
  final AppBodyBuilder bodyBuilder;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.bodyBuilder,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      bottomNavigationBar: const BottomBannerSlot(),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;
            return bodyBuilder(
              context,
              EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 28),
            );
          },
        ),
      ),
    );
  }
}
