import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _about(BuildContext context) => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('SiteQuant'), content: const Text('SiteQuant is a civil engineering toolkit designed to help engineers, contractors, students and site supervisors perform everyday construction calculations quickly and accurately.\n\nv1.0.0'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));

  @override
  Widget build(BuildContext context) => AppScaffold(title: 'Settings', bodyBuilder: (context, padding) => ListView(padding: padding, children: [
    const SectionHeader(title: 'General'), const SizedBox(height: 10),
    _Card(children: [_Tile(icon: Icons.dark_mode_outlined, title: 'Theme', subtitle: 'System', onTap: () => _message(context, 'Theme settings coming soon.')), _Tile(icon: Icons.straighten_rounded, title: 'Units', subtitle: 'Metric', onTap: () => _message(context, 'Imperial units coming soon.'))]), const SizedBox(height: 24),
    const SectionHeader(title: 'About'), const SizedBox(height: 10),
    _Card(children: [_Tile(icon: Icons.info_outline_rounded, title: 'About SiteQuant', onTap: () => _about(context)), _Tile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () => _message(context, 'Privacy Policy will be available before Play Store release.')), _Tile(icon: Icons.email_outlined, title: 'Contact Developer', onTap: () => _message(context, 'Contact feature coming soon.')), const _Tile(icon: Icons.info_rounded, title: 'Version', subtitle: 'v1.0.0')]), const SizedBox(height: 24),
    const SectionHeader(title: 'Support'), const SizedBox(height: 10),
    _Card(children: [_Tile(icon: Icons.star_outline_rounded, title: 'Rate App', onTap: () => _message(context, 'Available after Play Store release.')), _Tile(icon: Icons.share_outlined, title: 'Share App', onTap: () => _message(context, 'Share feature coming soon.'))]), const SizedBox(height: 24),
    const SectionHeader(title: 'Premium'), const SizedBox(height: 10),
    const _Card(children: [_Tile(icon: Icons.workspace_premium_outlined, title: 'Remove Ads', subtitle: 'Coming Soon', enabled: false), _Tile(icon: Icons.restore_rounded, title: 'Restore Purchase', subtitle: 'Coming Soon', enabled: false)]),
  ]));
}

class _Card extends StatelessWidget { final List<Widget> children; const _Card({required this.children}); @override Widget build(BuildContext context) => Card(child: Column(children: children)); }
class _Tile extends StatelessWidget {
  final IconData icon; final String title; final String? subtitle; final VoidCallback? onTap; final bool enabled;
  const _Tile({required this.icon, required this.title, this.subtitle, this.onTap, this.enabled = true});
  @override Widget build(BuildContext context) => ListTile(leading: Icon(icon), title: Text(title), subtitle: subtitle == null ? null : Text(subtitle!), trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded), enabled: enabled, onTap: onTap);
}
