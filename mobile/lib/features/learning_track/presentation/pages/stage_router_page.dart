import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/track_providers.dart';
import 'remote_lesson_pages.dart';
import 'stage_page.dart';

/// Picks the real-server or the local-demo experience of a stage. The two
/// never share ids, content or scores.
class StagePage extends ConsumerWidget {
  const StagePage({super.key, required this.lessonId, required this.stage});

  final String lessonId;
  final String stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(contentModeProvider) == ContentMode.remote
        ? RemoteStagePage(lessonId: lessonId, stage: stage)
        : DemoStagePage(lessonId: lessonId, stage: stage);
  }
}
