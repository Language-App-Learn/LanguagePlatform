import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// Tiny dependency-free bar chart (one bar per label). The last bar is
/// highlighted (usually "today"). Values must come from real recorded data.
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.height = 72,
    this.semanticLabel,
  }) : assert(values.length == labels.length);

  final List<int> values;
  final List<String> labels;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxValue = math.max(1, values.fold<int>(0, math.max));
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < values.length; i++)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: height,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: AppMotion.normal,
                          curve: AppMotion.curve,
                          width: 14,
                          // Zero values still show a thin stub.
                          height: 4 + (height - 4) * values[i] / maxValue,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: values[i] == 0
                                ? scheme.surfaceContainerHighest
                                : (i == values.length - 1
                                      ? scheme.primary
                                      : scheme.primary.withValues(alpha: 0.55)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      labels[i],
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
