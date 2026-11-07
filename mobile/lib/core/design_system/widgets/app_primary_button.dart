import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// Ana eylem butonu; yükleme durumunda kendini devre dışı bırakır.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    if (isLoading) {
      return FilledButton(
        onPressed: null,
        child: const SizedBox(
          width: AppSizes.iconSm,
          height: AppSizes.iconSm,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }
    if (icon == null) {
      return FilledButton(onPressed: effectiveOnPressed, child: Text(label));
    }
    return FilledButton.icon(
      onPressed: effectiveOnPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
