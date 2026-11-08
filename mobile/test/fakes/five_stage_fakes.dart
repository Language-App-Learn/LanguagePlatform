import 'dart:typed_data';

import 'package:language_platform/core/errors/app_failure.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/features/courses/domain/course.dart';
import 'package:language_platform/features/learning_track/domain/five_stage_repository.dart';
import 'package:language_platform/features/learning_track/domain/lesson_stage.dart';
import 'package:language_platform/features/learning_track/domain/remote_models.dart';

/// [ApiClient] driven by a handler; records every request.
class HandlerApiClient implements ApiClient {
  HandlerApiClient(this.handler);

  final Future<ApiResponse> Function(ApiRequest request) handler;
  final List<ApiRequest> requests = [];

  @override
  Future<ApiResponse> send(ApiRequest request) {
    requests.add(request);
    return handler(request);
  }
}

/// JSON examples taken from `FIVE_STAGE_LESSON_CONTRACT.md` and
/// `FLUTTER_BACKEND_CONTRACT.md` (shapes only; ids are synthetic).
abstract final class Json {
  static const courseId = '11111111-1111-1111-1111-111111111111';
  static const lessonId = '22222222-2222-2222-2222-222222222222';
  static const nextLessonId = '33333333-3333-3333-3333-333333333333';

  static List<Object?> catalogCourses() => [
    {
      'id': courseId,
      'learningPathId': 'p',
      'learningProgramId': 'g',
      'slug': 'modern-arabic',
      'title': 'Modern Arapça',
      'status': 'Published',
      'sourceLanguageCode': 'tr',
      'targetLanguageCode': 'ar',
      'description': null,
      'localizations': [],
      'levels': [],
    },
  ];

  static Map<String, Object?> levels() => {
    'courseId': courseId,
    'levels': [
      for (final (i, code) in ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].indexed)
        {'id': 'level-$code', 'code': code, 'order': i + 1, 'capacity': 20},
    ],
  };

  static List<Object?> slots({int published = 2}) => [
    for (var p = 1; p <= 20; p++)
      {
        'position': p,
        'lessonId': p <= published ? (p == 1 ? lessonId : nextLessonId) : null,
        'publishedVersionId': p <= published ? 'v$p' : null,
        'title': p <= published ? 'Ders $p başlığı' : null,
        'draftVersionId': null,
      },
  ];

  static Map<String, Object?> lessonDetail({String? assessmentId}) => {
    'id': lessonId,
    'courseId': courseId,
    'versionId': 'v1',
    'versionNumber': 1,
    'title': 'Tanışma',
    'targetLanguageCode': 'ar',
    'order': 1,
    'passingScore': 60,
    'localizations': [],
    'stages': [
      for (final (i, kind) in [
        'Reading',
        'Speaking',
        'Listening',
        'Writing',
        'Translation',
      ].indexed)
        {
          'id': 'stage-$i',
          'stageType': kind,
          'order': i + 1,
          'isRequired': true,
          'weight': 20,
          'minimumScore': null,
          'maximumAttempts': 3,
          'estimatedDurationSeconds': 600,
          'texts': i == 0
              ? [
                  {'locale': 'ar', 'text': 'مَرْحَبًا'},
                  {'locale': 'tr', 'text': 'Merhaba'},
                ]
              : [],
          'assessmentId': i == 0 ? assessmentId : null,
        },
    ],
  };

  static Map<String, Object?> progress({
    List<String> statuses = const [
      'available',
      'locked',
      'locked',
      'locked',
      'locked',
    ],
    List<num?> scores = const [null, null, null, null, null],
    num? finalScore,
    bool passed = false,
    String? next,
  }) => {
    'versionId': 'v1',
    'stages': [
      for (final (i, kind) in [
        'reading',
        'speaking',
        'listening',
        'writing',
        'translation',
      ].indexed)
        {
          'id': 'stage-$i',
          'kind': kind,
          'order': i + 1,
          'status': statuses[i],
          'score': scores[i],
          'attempts': scores[i] == null ? 0 : 1,
        },
    ],
    'finalScore': finalScore,
    'passingScore': 60,
    'passed': passed,
    'nextLessonId': next,
  };

  static Map<String, Object?> attempt() => {
    'id': 'attempt-1',
    'assessmentId': 'assess-1',
    'attemptNumber': 1,
    'startedAtUtc': '2026-11-06T10:00:00Z',
    'deadlineUtc': null,
    'questions': [
      {
        'id': 'q1',
        'kind': 'MultipleChoice',
        'prompt': 'Metindeki isim nedir؟',
        'maximumScore': 1,
        'options': [
          {'id': 'o1', 'text': 'أَحْمَدُ'},
          {'id': 'o2', 'text': 'سَارَةُ'},
        ],
      },
      {
        'id': 'q2',
        'kind': 'TrueFalse',
        'prompt': 'Kişi öğrencidir.',
        'maximumScore': 1,
        'options': [],
      },
    ],
  };

  static Map<String, Object?> assessmentResult({
    num score = 1,
    bool passed = false,
  }) => {
    'attemptId': 'attempt-1',
    'score': score,
    'maximumScore': 2,
    'percentage': score * 50,
    'passingScore': 60,
    'passed': passed,
    'completedAtUtc': '2026-11-06T10:05:00Z',
  };
}

/// In-memory [FiveStageRepository] used by widget tests: scripted data,
/// recorded calls, optional failures.
class FakeFiveStageRepository implements FiveStageRepository {
  FakeFiveStageRepository({
    this.course = const RemoteCourse(id: Json.courseId, title: 'Modern Arapça'),
    this.publishedPerLevel = const {CourseLevel.a1: 2},
    this.assessmentId,
    CurriculumProgress? initialProgress,
  }) : progress = initialProgress;

  RemoteCourse? course;
  final Map<CourseLevel, int> publishedPerLevel;
  final String? assessmentId;
  CurriculumProgress? progress;
  Object? slotsError;
  Set<String> passed = {};

  /// Assessment ids of the non-reading stages (default: none).
  Map<LessonStage, String> stageAssessments = {};

  final List<String> calls = [];
  int progressCalls = 0;

  /// What `submitAttempt` returns.
  RemoteAssessmentResult result = const RemoteAssessmentResult(
    attemptId: 'attempt-1',
    score: 1,
    maximumScore: 2,
    percentage: 50,
    passingScore: 60,
    passed: false,
  );

  /// Called after `startLesson` so tests can flip progress.
  void Function()? onStart;

  @override
  Future<RemoteCourse?> findTrackCourse({String? locale}) async => course;

  @override
  Future<List<RemoteLevel>> getLevels(String courseId) async => [
    for (final (i, level) in CourseLevel.values.indexed)
      RemoteLevel(
        id: 'level-${level.code}',
        level: level,
        order: i + 1,
        capacity: 20,
      ),
  ];

  @override
  Future<List<RemoteSlot>> getSlots(String courseId, String levelId) async {
    if (slotsError != null) throw slotsError!;
    final level = CourseLevel.values.firstWhere(
      (l) => 'level-${l.code}' == levelId,
    );
    final count = publishedPerLevel[level] ?? 0;
    return [
      for (var p = 1; p <= 20; p++)
        RemoteSlot(
          position: p,
          lessonId: p <= count
              ? (p == 1 ? Json.lessonId : Json.nextLessonId)
              : null,
          title: p <= count ? 'Ders $p başlığı' : null,
        ),
    ];
  }

  @override
  Future<RemoteLesson> getLesson(String courseId, String lessonId) async {
    return RemoteLesson(
      id: lessonId,
      courseId: courseId,
      versionId: 'v1',
      title: 'Tanışma',
      passingScore: 60,
      stages: [
        for (final (i, kind) in LessonStage.values.indexed)
          RemoteStage(
            id: 'stage-$i',
            kind: kind,
            order: i + 1,
            isRequired: true,
            weight: 20,
            estimatedSeconds: 600,
            assessmentId: i == 0 ? assessmentId : stageAssessments[kind],
            texts: i == 0 ? {'ar': 'مَرْحَبًا', 'tr': 'Merhaba'} : const {},
          ),
      ],
    );
  }

  @override
  Future<Set<String>> getPassedLessonIds(String courseId) async => passed;

  @override
  Future<void> enroll(String courseId) async => calls.add('enroll');

  @override
  Future<void> startLesson(String courseId, String lessonId) async {
    calls.add('start');
    onStart?.call();
  }

  @override
  Future<CurriculumProgress> getProgress(
    String courseId,
    String lessonId,
  ) async {
    progressCalls++;
    final p = progress;
    if (p == null) throw const NotFoundFailure();
    return p;
  }

  /// Questions served by `startAttempt` (default: one MC + one true/false).
  List<RemoteQuestion> questions = const [
    RemoteQuestion(
      id: 'q1',
      kind: 'MultipleChoice',
      prompt: 'Metindeki isim nedir?',
      maximumScore: 1,
      options: [
        RemoteOption(id: 'o1', text: 'أَحْمَدُ'),
        RemoteOption(id: 'o2', text: 'سَارَةُ'),
      ],
    ),
    RemoteQuestion(
      id: 'q2',
      kind: 'TrueFalse',
      prompt: 'Kişi öğrencidir.',
      maximumScore: 1,
    ),
  ];

  /// Idempotency keys received by `startAttempt`, in order.
  final List<String> startKeys = [];

  /// Failures thrown (one per call, FIFO) by `startAttempt` / `submitAttempt`.
  final List<Object> startErrors = [];
  final List<Object> submitErrors = [];

  /// Attempt id served by `startAttempt`.
  String attemptId = 'attempt-1';

  @override
  Future<RemoteAttempt> startAttempt({
    required String courseId,
    required String lessonId,
    required String assessmentId,
    required String idempotencyKey,
  }) async {
    calls.add('attempt');
    startKeys.add(idempotencyKey);
    if (startErrors.isNotEmpty) throw startErrors.removeAt(0);
    return RemoteAttempt(
      id: attemptId,
      assessmentId: 'assess-1',
      attemptNumber: 1,
      questions: questions,
    );
  }

  List<RemoteAnswer> submitted = [];

  @override
  Future<RemoteAssessmentResult> submitAttempt({
    required String courseId,
    required String lessonId,
    required String assessmentId,
    required String attemptId,
    required List<RemoteAnswer> answers,
  }) async {
    calls.add('submit');
    if (submitErrors.isNotEmpty) throw submitErrors.removeAt(0);
    submitted = answers;
    return result;
  }

  /// Reading material served by `getReadingMaterial` (null = 404).
  ReadingMaterial? reading;
  Object? readingError;
  Uint8List? pdfBytes;
  Object? pdfError;
  int pdfCalls = 0;
  StageMedia? media;

  /// Result served by `getAttemptResult`; null means "evaluation pending".
  RemoteAssessmentResult? attemptResult;
  int resultCalls = 0;

  @override
  Future<ReadingMaterial?> getReadingMaterial(
    String courseId,
    String lessonId,
  ) async {
    if (readingError != null) throw readingError!;
    return reading;
  }

  @override
  Future<Uint8List> downloadReadingPdf(
    String courseId,
    String lessonId, {
    CancelToken? cancelToken,
  }) async {
    pdfCalls++;
    if (pdfError != null) throw pdfError!;
    return pdfBytes ?? (throw const NotFoundFailure());
  }

  @override
  Future<StageMedia?> getStageMedia(
    String courseId,
    String lessonId,
    String stageId,
  ) async => media;

  @override
  Future<RemoteAssessmentResult?> getAttemptResult(String attemptId) async {
    resultCalls++;
    return attemptResult;
  }
}

CurriculumProgress progressOf({
  List<RemoteStageStatus>? statuses,
  List<double?>? scores,
  double? finalScore,
  bool passed = false,
  String? next,
}) {
  final st =
      statuses ??
      [
        RemoteStageStatus.available,
        RemoteStageStatus.locked,
        RemoteStageStatus.locked,
        RemoteStageStatus.locked,
        RemoteStageStatus.locked,
      ];
  return CurriculumProgress(
    versionId: 'v1',
    passingScore: 60,
    passed: passed,
    finalScore: finalScore,
    nextLessonId: next,
    stages: [
      for (final (i, kind) in LessonStage.values.indexed)
        RemoteStageProgress(
          id: 'stage-$i',
          kind: kind,
          order: i + 1,
          status: st[i],
          score: scores?[i],
          attempts: scores?[i] == null ? 0 : 1,
        ),
    ],
  );
}
