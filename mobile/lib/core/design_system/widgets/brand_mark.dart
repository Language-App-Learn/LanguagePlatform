import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../theme/app_tokens.dart';

/// LanguagePlatform marka işareti (geçici; logo kesinleşince değişir).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 88, this.showName = true});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.3),
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [scheme.primary, scheme.tertiary],
              ),
            ),
            child: Icon(
              Icons.translate,
              size: size * 0.5,
              color: scheme.onPrimary,
            ),
          ),
        ),
        if (showName) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppConfig.appName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ],
    );
  }
}
