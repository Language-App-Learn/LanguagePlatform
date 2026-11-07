import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';

/// Compact ISO code badge ("EN", "TR", "AR") used in language lists. The code
/// is isolated LTR so it never flips inside RTL layouts; decorative, because
/// the language name next to it carries the meaning.
class LanguageBadge extends StatelessWidget {
  const LanguageBadge({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        width: AppSizes.minTouchTarget - 8,
        height: AppSizes.minTouchTarget - 8,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: AppRadius.smAll,
        ),
        child: Text(
          code.toUpperCase().isolateLtr,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
