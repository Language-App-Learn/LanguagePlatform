import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../domain/course.dart';

/// CEFR seviye rozeti (A1 ... C2). A: başlangıç, B: orta, C: ileri tonları.
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level});

  final CourseLevel level;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (level) {
      CourseLevel.a1 || CourseLevel.a2 => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      CourseLevel.b1 ||
      CourseLevel.b2 => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      CourseLevel.c1 ||
      CourseLevel.c2 => (scheme.primaryContainer, scheme.onPrimaryContainer),
    };
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        level.code.isolateLtr,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}
