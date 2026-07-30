import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool compact;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleWidget = Text(
      title,
      style: compact ? textTheme.titleMedium : textTheme.titleLarge,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon == null)
          titleWidget
        else
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(child: titleWidget),
            ],
          ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!, style: textTheme.bodyMedium),
        ],
      ],
    );
  }
}
