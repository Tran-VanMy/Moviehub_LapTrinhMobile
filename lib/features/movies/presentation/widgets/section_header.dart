// Path: lib/features/movies/presentation/widgets/section_header.dart
import 'package:flutter/material.dart';
import '../../../../core/i18n/app_i18n.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAll,
    this.trailingIcon,
  });

  final String title;
  final VoidCallback onSeeAll;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final i18n = AppI18n.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          if (trailingIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(trailingIcon, size: 20, color: theme.colorScheme.primary),
            ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          TextButton.icon(
            onPressed: onSeeAll,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            label: Text(i18n.t("see_all")),
          )
        ],
      ),
    );
  }
}
