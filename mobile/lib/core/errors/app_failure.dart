import 'dart:async';
import 'dart:io';

import 'app_exceptions.dart';

/// Typed, UI-safe description of what went wrong.
///
/// Infrastructure errors (sockets, HTTP codes, parsing errors) are mapped to
/// one of these in the data layer / [failureOf]; widgets only ever look at
/// the kind, never at raw exceptions or server messages.
sealed class AppFailure implements Exception {
  const AppFailure();

  /// Whether showing a "Try again" action makes sense.
  bool get isRecoverable => true;
}

final class NetworkUnavailableFailure extends AppFailure {
  const NetworkUnavailableFailure();
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure();
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure();

  @override
  bool get isRecoverable => false; // needs sign-in, not a retry
}

final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure();

  @override
  bool get isRecoverable => false;
}

/// The server rejected the input. Field-level errors are intentionally not
/// modelled yet: the backend's validation error format is undecided.
final class ValidationFailure extends AppFailure {
  const ValidationFailure();

  @override
  bool get isRecoverable => false;
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure();

  @override
  bool get isRecoverable => false;
}

final class ServerFailure extends AppFailure {
  const ServerFailure();
}

/// The response did not have the expected shape.
final class UnexpectedResponseFailure extends AppFailure {
  const UnexpectedResponseFailure();
}

/// A feature that needs a not-yet-connected backend integration.
final class ServiceUnavailableFailure extends AppFailure {
  const ServiceUnavailableFailure();

  @override
  bool get isRecoverable => false;
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure();
}

/// Maps any thrown object to an [AppFailure]. Never returns raw errors.
AppFailure failureOf(Object? error) {
  return switch (error) {
    AppFailure() => error,
    NotFoundException() => const NotFoundFailure(),
    ServiceUnavailableException() => const ServiceUnavailableFailure(),
    TimeoutException() => const TimeoutFailure(),
    SocketException() => const NetworkUnavailableFailure(),
    FormatException() || TypeError() => const UnexpectedResponseFailure(),
    _ => const UnknownFailure(),
  };
}
