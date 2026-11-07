import '../../courses/domain/course.dart';
import '../domain/lesson_stage.dart';
import '../domain/remote_models.dart';

/// Wire format -> domain mappers for the five-stage backend contract.
/// Parsing is strict about required identifiers and tolerant about optional
/// fields; a malformed payload throws and is reported as an unexpected
/// response by `ApiResponse.unwrap`. DTOs never reach the UI.

Map<String, Object?> _map(Object? v) =>
    v is Map ? v.cast<String, Object?>() : throw const FormatException('map');

List<Object?> _list(Object? v) =>
    v is List ? v.cast<Object?>() : throw const FormatException('list');

String _str(Object? v) =>
    v is String && v.isNotEmpty ? v : throw const FormatException('string');

String? _optStr(Object? v) => v is String && v.isNotEmpty ? v : null;

double? _optNum(Object? v) => v is num ? v.toDouble() : null;

int _int(Object? v) =>
    v is num ? v.toInt() : throw const FormatException('int');

LessonStage? stageKindFrom(Object? raw) {
  final name = raw is String ? raw.toLowerCase() : null;
  return LessonStage.values.asNameMap()[name];
}

CourseLevel? levelFromCode(Object? raw) =>
    raw is String ? CourseLevel.values.asNameMap()[raw.toLowerCase()] : null;

RemoteCourse? courseFromCatalogList(Object? json) {
  for (final item in _list(json)) {
    final m = _map(item);
    if (m['sourceLanguageCode'] == 'tr' && m['targetLanguageCode'] == 'ar') {
      return RemoteCourse(id: _str(m['id']), title: _optStr(m['title']) ?? '');
    }
  }
  return null;
}

List<RemoteLevel> levelsFrom(Object? json) {
  final levels = <RemoteLevel>[];
  for (final item in _list(_map(json)['levels'])) {
    final m = _map(item);
    final level = levelFromCode(m['code']);
    if (level == null) continue; // unknown CEFR code: skip, never guess
    levels.add(
      RemoteLevel(
        id: _str(m['id']),
        level: level,
        order: _int(m['order']),
        capacity: m['capacity'] is num ? _int(m['capacity']) : 20,
      ),
    );
  }
  levels.sort((a, b) => a.order.compareTo(b.order));
  return levels;
}

List<RemoteSlot> slotsFrom(Object? json) {
  final slots = [
    for (final item in _list(json))
      RemoteSlot(
        position: _int(_map(item)['position']),
        lessonId: _optStr(_map(item)['lessonId']),
        versionId: _optStr(_map(item)['publishedVersionId']),
        title: _optStr(_map(item)['title']),
      ),
  ];
  slots.sort((a, b) => a.position.compareTo(b.position));
  return slots;
}

RemoteLesson lessonFrom(Object? json) {
  final m = _map(json);
  final stages = [
    for (final s in _list(m['stages']))
      () {
        final sm = _map(s);
        final texts = <String, String>{};
        final rawTexts = sm['texts'];
        if (rawTexts is List) {
          for (final t in rawTexts) {
            final tm = _map(t);
            final locale = _optStr(tm['locale']);
            final text = tm['text'];
            if (locale != null && text is String) texts[locale] = text;
          }
        }
        return RemoteStage(
          id: _str(sm['id']),
          kind: stageKindFrom(sm['stageType']),
          order: _int(sm['order']),
          isRequired: sm['isRequired'] != false,
          weight: _optNum(sm['weight']),
          estimatedSeconds: sm['estimatedDurationSeconds'] is num
              ? _int(sm['estimatedDurationSeconds'])
              : null,
          assessmentId: _optStr(sm['assessmentId']),
          texts: texts,
        );
      }(),
  ]..sort((a, b) => a.order.compareTo(b.order));
  return RemoteLesson(
    id: _str(m['id']),
    courseId: _str(m['courseId']),
    versionId: _str(m['versionId']),
    title: _optStr(m['title']) ?? '',
    passingScore: _optNum(m['passingScore']) ?? 60,
    stages: stages,
  );
}

RemoteStageStatus _statusFrom(Object? raw) {
  final s = raw is String ? raw.toLowerCase().replaceAll('_', '') : '';
  return switch (s) {
    'available' => RemoteStageStatus.available,
    'inprogress' => RemoteStageStatus.inProgress,
    'completed' => RemoteStageStatus.completed,
    // Unknown states are treated as locked (the safe reading).
    _ => RemoteStageStatus.locked,
  };
}

CurriculumProgress progressFrom(Object? json) {
  final m = _map(json);
  final stages = <RemoteStageProgress>[];
  for (final s in _list(m['stages'])) {
    final sm = _map(s);
    final kind = stageKindFrom(sm['kind']);
    if (kind == null) continue;
    stages.add(
      RemoteStageProgress(
        id: _str(sm['id']),
        kind: kind,
        order: _int(sm['order']),
        status: _statusFrom(sm['status']),
        score: _optNum(sm['score']),
        attempts: sm['attempts'] is num ? _int(sm['attempts']) : 0,
      ),
    );
  }
  stages.sort((a, b) => a.order.compareTo(b.order));
  return CurriculumProgress(
    versionId: _str(m['versionId']),
    stages: stages,
    finalScore: _optNum(m['finalScore']),
    passingScore: _optNum(m['passingScore']) ?? 60,
    passed: m['passed'] == true,
    nextLessonId: _optStr(m['nextLessonId']),
  );
}

RemoteAttempt attemptFrom(Object? json) {
  final m = _map(json);
  final questions = [
    for (final q in _list(m['questions']))
      RemoteQuestion(
        id: _str(_map(q)['id']),
        kind: _str(_map(q)['kind']),
        prompt: _optStr(_map(q)['prompt']) ?? '',
        maximumScore: _optNum(_map(q)['maximumScore']) ?? 1,
        options: [
          if (_map(q)['options'] is List)
            for (final o in _list(_map(q)['options']))
              RemoteOption(
                id: _str(_map(o)['id']),
                text: _optStr(_map(o)['text']) ?? '',
              ),
        ],
      ),
  ];
  return RemoteAttempt(
    id: _str(m['id']),
    assessmentId: _str(m['assessmentId']),
    attemptNumber: m['attemptNumber'] is num ? _int(m['attemptNumber']) : 1,
    deadlineUtc: m['deadlineUtc'] is String
        ? DateTime.tryParse(m['deadlineUtc']! as String)?.toUtc()
        : null,
    questions: questions,
  );
}

RemoteAssessmentResult assessmentResultFrom(Object? json) {
  final m = _map(json);
  return RemoteAssessmentResult(
    attemptId: _str(m['attemptId']),
    score: _optNum(m['score']) ?? 0,
    maximumScore: _optNum(m['maximumScore']) ?? 0,
    percentage: _optNum(m['percentage']) ?? 0,
    passingScore: _optNum(m['passingScore']) ?? 60,
    passed: m['passed'] == true,
  );
}

Map<String, Object?> answerToJson(RemoteAnswer a) => {
  'questionId': a.questionId,
  if (a.optionId != null) 'optionId': a.optionId,
  if (a.value != null) 'value': a.value,
  if (a.text != null) 'text': a.text,
  if (a.orderedOptionIds != null) 'orderedOptionIds': a.orderedOptionIds,
};

/// `{items,nextOffset}` page of lesson progress -> passed lesson ids and the
/// next offset (`null` at the end).
({Set<String> passed, int? nextOffset}) lessonProgressPageFrom(Object? json) {
  final m = _map(json);
  final passed = <String>{};
  for (final item in _list(m['items'])) {
    final im = _map(item);
    if (im['isPassed'] == true) passed.add(_str(im['lessonId']));
  }
  return (
    passed: passed,
    nextOffset: m['nextOffset'] is num ? _int(m['nextOffset']) : null,
  );
}

/// Reading text: `{lines:[{id,page,order,text}],hasOriginalPdf}`. Lines are
/// ordered by page then order; text is kept byte-for-byte (diacritics).
ReadingMaterial readingMaterialFrom(Object? json) {
  final m = _map(json);
  final lines = <ReadingLine>[
    if (m['lines'] is List)
      for (final item in _list(m['lines']))
        ReadingLine(
          id: _str(_map(item)['id']),
          page: _map(item)['page'] is num ? _int(_map(item)['page']) : 1,
          order: _int(_map(item)['order']),
          text: _map(item)['text'] is String
              ? _map(item)['text']! as String
              : throw const FormatException('line text'),
        ),
  ]..sort((a, b) => a.page != b.page ? a.page - b.page : a.order - b.order);
  return ReadingMaterial(
    lines: lines,
    hasOriginalPdf: m['hasOriginalPdf'] == true,
  );
}

/// `{audioUrl,teacherVideo:{url,title}}`. Only absolute HTTPS URLs without
/// credentials are accepted; anything else is treated as absent (the server
/// validates too, but a client must not trust a downloaded value blindly).
StageMedia stageMediaFrom(Object? json) {
  final m = _map(json);
  // `status`: available | unavailable | unconfigured (authored but blocked by
  // the server host policy). Anything but "available" - including a missing
  // status - means: show no media, never a blocked link.
  final status = _optStr(m['status'])?.toLowerCase();
  if (status != null && status != 'available') {
    return StageMedia(status: status);
  }
  final video = m['teacherVideo'];
  final videoMap = video is Map ? video.cast<String, Object?>() : null;
  return StageMedia(
    audioUrl: safeMediaUri(m['audioUrl']),
    videoUrl: safeMediaUri(videoMap?['url']),
    videoTitle: _optStr(videoMap?['title']),
    status: status ?? 'available',
  );
}

Uri? safeMediaUri(Object? raw) {
  if (raw is! String || raw.isEmpty) return null;
  final uri = Uri.tryParse(raw);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return null;
  }
  return uri;
}
