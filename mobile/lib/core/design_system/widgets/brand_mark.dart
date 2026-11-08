import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import 'app_logo.dart';

/// LanguagePlatform brand mark used on auth and other screens: the logo mark
/// plus (optionally) the word mark. Same identity as the splash logo.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 88, this.showName = true});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoMark(size: size),
        if (showName) ...[
          const SizedBox(height: AppSpacing.md),
          LogoWordmark(fontSize: size * 0.3),
        ],
      ],
    );
  }
}
