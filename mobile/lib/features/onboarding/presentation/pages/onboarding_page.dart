import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/onboarding_state.dart';
import '../widgets/onboarding_step_view.dart';
import '../widgets/page_dots.dart';

/// 4 adımlı tanıtım: ileri, geri, geç ve tamamla.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _stepCount = 4;
  bool get _isLast => _index == _stepCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: AppMotion.normal,
      curve: AppMotion.curve,
    );
  }

  void _finish() {
    ref.read(onboardingCompletedProvider.notifier).complete();
    context.go(AppRoutes.languageSetup);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = OnboardingStepData.all(l10n);
    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                  child: TextButton(onPressed: _finish, child: Text(l10n.skip)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: steps.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, i) =>
                      OnboardingStepView(data: steps[i], index: i),
                ),
              ),
              Semantics(
                label: l10n.onboardingStepSemantics(_index + 1, _stepCount),
                child: PageDots(count: _stepCount, index: _index),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                child: Row(
                  children: [
                    // Geri butonu ilk adımda yer tutar; düzen kaymasın.
                    Expanded(
                      child: Visibility(
                        visible: _index > 0,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: OutlinedButton.icon(
                          onPressed: _index > 0
                              ? () => _goTo(_index - 1)
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          label: Text(l10n.back),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppPrimaryButton(
                        label: _isLast ? l10n.getStarted : l10n.next,
                        icon: _isLast ? Icons.check : Icons.arrow_forward,
                        onPressed: _isLast ? _finish : () => _goTo(_index + 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
