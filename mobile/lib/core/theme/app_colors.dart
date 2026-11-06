import 'package:flutter/material.dart';

/// Marka paleti. Marka kimliği kesinleşince yalnızca burası güncellenir.
abstract final class AppColors {
  /// İndigo: güven ve odak (birincil).
  static const Color seed = Color(0xFF4455D6);

  /// Sıcak amber: hedef/vurgu.
  static const Color accent = Color(0xFFF2A516);
}

/// ColorScheme'de karşılığı olmayan anlamsal renkler (başarı, uyarı, vurgu).
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.accent,
    required this.accentContainer,
    required this.onAccentContainer,
  });

  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color accent;
  final Color accentContainer;
  final Color onAccentContainer;

  static const light = AppSemanticColors(
    success: Color(0xFF1F9D6B),
    successContainer: Color(0xFFD7F5E8),
    onSuccessContainer: Color(0xFF0B3D29),
    accent: AppColors.accent,
    accentContainer: Color(0xFFFFEFC8),
    onAccentContainer: Color(0xFF4A3000),
  );

  static const dark = AppSemanticColors(
    success: Color(0xFF55D6A0),
    successContainer: Color(0xFF12402E),
    onSuccessContainer: Color(0xFFBDF2DA),
    accent: Color(0xFFFFC857),
    accentContainer: Color(0xFF4A3600),
    onAccentContainer: Color(0xFFFFE3A6),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? accent,
    Color? accentContainer,
    Color? onAccentContainer,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      accent: accent ?? this.accent,
      accentContainer: accentContainer ?? this.accentContainer,
      onAccentContainer: onAccentContainer ?? this.onAccentContainer,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentContainer: Color.lerp(accentContainer, other.accentContainer, t)!,
      onAccentContainer: Color.lerp(
        onAccentContainer,
        other.onAccentContainer,
        t,
      )!,
    );
  }
}

extension AppSemanticColorsContext on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>()!;
}
