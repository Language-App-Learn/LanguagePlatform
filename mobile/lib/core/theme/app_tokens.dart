import 'package:flutter/widgets.dart';

/// Merkezi tasarım token'ları. UI kodunda sabit sayı yerine bunlar kullanılır.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Ekran kenar boşluğu (RTL/LTR uyumlu).
  static const EdgeInsetsDirectional screen = EdgeInsetsDirectional.symmetric(
    horizontal: lg,
  );

  /// Sayfa içeriği: yatay kenar + dikey nefes alanı.
  static const EdgeInsetsDirectional page = EdgeInsetsDirectional.fromSTEB(
    lg,
    lg,
    lg,
    xxl,
  );
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
}

abstract final class AppSizes {
  /// Erişilebilir minimum dokunma alanı.
  static const double minTouchTarget = 48;
  static const double buttonHeight = 52;
  static const double maxContentWidth = 560;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconXl = 56;
  static const double progressBarHeight = 8;
  static const double courseCardWidth = 260;
}

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Curve curve = Curves.easeOutCubic;
}
