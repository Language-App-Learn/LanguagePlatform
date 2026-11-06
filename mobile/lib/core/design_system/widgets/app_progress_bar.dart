import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// Yuvarlak uçlu, animasyonlu ilerleme çubuğu. [value] 0..1 arasıdır.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.semanticLabel,
  });

  final double value;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final clamped = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: '${(clamped * 100).round()}%',
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.progressBarHeight),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: clamped),
            duration: AppMotion.normal,
            curve: AppMotion.curve,
            builder: (context, animated, _) => LinearProgressIndicator(
              value: animated,
              minHeight: AppSizes.progressBarHeight,
              color: color ?? scheme.primary,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ),
      ),
    );
  }
}
