import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              key: ValueKey('dot-$i'),
              duration: AppMotion.fast,
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 4),
              width: i == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: i == index ? scheme.primary : scheme.outlineVariant,
              ),
            ),
        ],
      ),
    );
  }
}
