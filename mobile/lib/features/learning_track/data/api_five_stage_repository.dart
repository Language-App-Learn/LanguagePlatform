import 'dart:typed_data';

import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../domain/five_stage_repository.dart';
import '../domain/remote_models.dart';
import 'five_stage_dto.dart';

/// [FiveStageRepository] over the confirmed backend routes
/// (`FLUTTER_BACKEND_CONTRACT.md`, `FIVE_STAGE_LESSON_CONTRACT.md`).
/// Only routes documented there are used.
class ApiFiveStageRepository implements FiveStageRepository {
  ApiFiveStageRepository(this._api);

  final ApiClient _api;

  static const _maxPages = 50;

  @override
  Future<RemoteCourse?> findTrackCourse({String? locale}) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.get,
        '/api/v1/catalog/courses',
        query: {
          'source': 'tr',
          'target': 'ar',
          'limit': '20',
          'locale': ?locale,
        },
      ),
    );
    return response.unwrap(courseFromCatalogList);
  }

  @override
  Future<List<RemoteLevel>> getLevels(String courseId) async {
    final response = await _api.send(
      ApiRequest(HttpMethod.get, '/api/v1/courses/$courseId/curriculum/levels'),
    );
    return response.unwrap(levelsFrom);
  }

  @override
  Future<List<RemoteSlot>> getSlots(String courseId, String levelId) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.get,
        '/api/v1/courses/$courseId/curriculum/levels/$levelId/slots',
      ),
    );
    return response.unwrap(slotsFrom);
  }

  @override
  Future<RemoteLesson> getLesson(String courseId, String lessonId) async {
    final response = await _api.send(
      ApiRequest(HttpMethod.get, '/api/v1/courses/$courseId/lessons/$lessonId'),
    );
    return response.unwrap(lessonFrom);
  }

  @override
  Future<Set<String>> getPassedLessonIds(String courseId) async {
    final passed = <String>{};
    int? offset = 0;
    for (var page = 0; offset != null && page < _maxPages; page++) {
      final response = await _api.send(
        ApiRequest(
          HttpMethod.get,
          '/api/v1/me/courses/$courseId/lessons/progress',
          query: {'completedOnly': 'true', 'offset': '$offset', 'limit': '100'},
          requiresAuth: true,
        ),
      );
      final result = response.unwrap(lessonProgressPageFrom);
      passed.addAll(result.passed);
      offset = result.nextOffset;
    }
    return passed;
  }

  @override
  Future<void> enroll(String courseId) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.put,
        '/api/v1/me/courses/$courseId/enrollment',
        requiresAuth: true,
      ),
    );
    response.ensureSuccess();
  }

  @override
  Future<void> startLesson(String courseId, String lessonId) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.put,
        '/api/v1/me/courses/$courseId/lessons/$lessonId/start',
        requiresAuth: true,
      ),
    );
    response.ensureSuccess();
  }

  @override
  Future<CurriculumProgress> getProgress(
    String courseId,
    String lessonId,
  ) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.get,
        '/api/v1/me/courses/$courseId/lessons/$lessonId/curriculum-progress',
        requiresAuth: true,
      ),
    );
    return response.unwrap(progressFrom);
  }

  String _assessmentBase(
    String courseId,
    String lessonId,
    String assessmentId,
  ) =>
      '/api/v1/me/courses/$courseId/lessons/$lessonId/assessments/$assessmentId';

  @override
  Future<RemoteAttempt> startAttempt({
    required String courseId,
    required String lessonId,
    required String assessmentId,
    required String idempotencyKey,
  }) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.post,
        '${_assessmentBase(courseId, lessonId, assessmentId)}/attempts',
        body: {'idempotencyKey': idempotencyKey},
        requiresAuth: true,
      ),
    );
    return response.unwrap(attemptFrom);
  }

  @override
  Future<RemoteAssessmentResult> submitAttempt({
    required String courseId,
    required String lessonId,
    required String assessmentId,
    required String attemptId,
    required List<RemoteAnswer> answers,
  }) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.post,
        '${_assessmentBase(courseId, lessonId, assessmentId)}/attempts/$attemptId/submit',
        body: {'answers': answers.map(answerToJson).toList()},
        requiresAuth: true,
      ),
    );
    return response.unwrap(assessmentResultFrom);
  }

  @override
  Future<ReadingMaterial?> getReadingMaterial(
    String courseId,
    String lessonId,
  ) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.get,
        '/api/v1/me/courses/$courseId/lessons/$lessonId/reading-material',
        requiresAuth: true,
      ),
    );
    if (response.statusCode == 404) return null;
    return response.unwrap(readingMaterialFrom);
  }

  @override
  Future<Uint8List> downloadReadingPdf(
    String courseId,
    String lessonId, {
    CancelToken? cancelToken,
  }) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.get,
        '/api/v1/me/courses/$courseId/lessons/$lessonId/reading-material/original',
        requiresAuth: true,
        expectedMime: 'application/pdf',
        cancelToken: cancelToken,
      ),
    );
    response.ensureSuccess();
    final bytes = response.bytes;
    // "%PDF-" magic: a mislabeled body is never handed to a viewer.
    if (bytes == null ||
        bytes.length < 5 ||
        String.fromCharCodes(bytes.sublist(0, 5)) != '%PDF-') {
      throw const UnexpectedResponseFailure();
    }
    return bytes;
  }

  @override
  Future<StageMedia?> getStageMedia(
    String courseId,
    String lessonId,
    String stageId,
  ) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.get,
        '/api/v1/me/courses/$courseId/lessons/$lessonId/stages/$stageId/media',
        requiresAuth: true,
      ),
    );
    if (response.statusCode == 404) return null;
    return response.unwrap(stageMediaFrom);
  }

  @override
  Future<RemoteAssessmentResult?> getAttemptResult(String attemptId) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.get,
        '/api/v1/me/assessment-attempts/$attemptId/result',
        requiresAuth: true,
      ),
    );
    if (response.statusCode == 404) return null; // evaluation pending
    return response.unwrap(assessmentResultFrom);
  }
}
