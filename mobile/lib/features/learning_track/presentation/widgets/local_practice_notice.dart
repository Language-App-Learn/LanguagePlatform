import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/track_providers.dart';

/// Shown on screens that still run on local, on-device practice data while a
/// REAL account is active (vocabulary, review, activity). It keeps the two
/// worlds visibly apart: this data is not synced, not uploaded and never an
/// official result. Renders nothing in demo mode.
class LocalPracticeNotice extends ConsumerWidget {
  const LocalPracticeNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(contentModeProvider) != ContentMode.remote) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
      child: NoticeBanner(
        key: const ValueKey('local-practice-notice'),
        message: context.l10n.localPracticeNotice,
      ),
    );
  }
}
