import 'dart:async';

import 'turbo_exception.dart';

/// A type-safe response that can be either successful or failed.
///
/// The [TurboResponse] class provides a robust way to handle operation results
/// with proper type safety. It can be in one of two states:
///
/// 1. [Success]: Represents a successful operation with a result value
/// 2. [Fail]: Represents a failed operation with an error
///
/// Example:
/// ```dart
/// // Creating a success response
/// final success = TurboResponse.success(
///   result: 'Hello',
///   title: 'Greeting',
///   message: 'Welcome message',
/// );
///
/// // Creating a fail response
/// final fail = TurboResponse.fail(
///   error: Exception('Something went wrong'),
///   title: 'Error',
///   message: 'Operation failed',
/// );
///
/// // Pattern matching on the response
/// final message = response.when(
///   success: (s) => 'Got result: ${s.result}',
///   fail: (f) => 'Failed with: ${f.error}',
/// );
///
/// // Chaining operations
/// final result = await response
///   .mapSuccess((value) => value.length)
///   .andThen((length) => computeNext(length));
/// ```
sealed class TurboResponse<T> {
  /// Creates a successful response with a result value.
  ///
  /// The [result] parameter is required and represents the successful value.
  /// Optional [title] and [message] parameters can provide additional context.
  ///
  /// Example:
  /// ```dart
  /// final response = TurboResponse.success(
  ///   result: 42,
  ///   title: 'Computation',
  ///   message: 'Successfully computed the value',
  /// );
  /// ```
  const factory TurboResponse.success({
    required T result,
    String? title,
    String? message,
  }) = Success;

  /// Creates a failed response with an error.
  ///
  /// The [error] parameter is required and represents what went wrong.
  /// Optional [stackTrace], [title], and [message] parameters can provide additional context.
  ///
  /// Example:
  /// ```dart
  /// final response = TurboResponse.fail(
  ///   error: Exception('Invalid input'),
  ///   title: 'Validation Error',
  ///   message: 'The input value was not in the correct format',
  /// );
  /// ```
  const factory TurboResponse.fail({
    required Object error,
    StackTrace? stackTrace,
    String? title,
    String? message,
  }) = Fail;

  /// Creates a failed response with a default error.
  ///
  /// This is a convenience constructor that creates a fail state with a default error.
  /// Useful when you just want to indicate failure without specific error details.
  ///
  /// Example:
  /// ```dart
  /// final response = TurboResponse.failed();
  /// ```
  const factory TurboResponse.emptyFail() = Fail<T>.empty;

  /// Creates a successful response with a default result value.
  ///
  /// This is a convenience constructor that creates a success state with a default result.
  /// Useful when you just want to indicate success without specific result details.
  ///
  /// Example:
  /// ```dart
  /// final response = TurboResponse.emptySuccess();
  /// ```
  const factory TurboResponse.emptySuccess() = Success<T>.empty;

  /// Creates and throws a [TurboException] with the provided error details.
  ///
  /// This is a convenience method that creates a fail state and immediately throws it.
  /// Useful when you want to throw an exception instead of returning a response.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   if (!isValid) {
  ///     TurboResponse.throwFail(
  ///       error: 'Invalid state',
  ///       title: 'Validation Error',
  ///       message: 'The state is not valid',
  ///     );
  ///   }
  /// } on TurboException catch (e) {
  ///   print('Caught error: ${e.error}');
  /// }
  /// ```
  static Never throwFail({
    Object? error,
    StackTrace? stackTrace,
    String? title,
    String? message,
  }) =>
      throw TurboException(
        error: error,
        stackTrace: stackTrace,
        title: title,
        message: message,
      );

  const TurboResponse._();

  /// The result value if this is a success state, null otherwise.
  T get result => switch (this) {
        Success<T>(result: final value) => value,
        Fail<T>() => throw TurboException(
            error: error,
            title: title,
            message: message,
            stackTrace: (this as Fail<T>).stackTrace,
          ),
      };

  /// The title of the response if available.
  String? get title => switch (this) {
        Success(title: final t) => t,
        Fail(title: final t) => t,
      };

  /// The message providing additional context about the response.
  String? get message => switch (this) {
        Success(message: final m) => m,
        Fail(message: final m) => m,
      };

  /// The error if this is a fail state, null otherwise.
  Object? get error => switch (this) {
        Success() => null,
        Fail(error: final e) => e,
      };

  /// Throws the error if this is a fail state, otherwise returns void.
  ///
  /// This is useful in situations where you need to throw an error, like in Firestore transactions.
  /// The error will be wrapped in a [TurboException] that includes the title and message.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   response.tryThrowFail();
  /// } on TurboException catch (e) {
  ///   print('Title: ${e.title}');
  ///   print('Message: ${e.message}');
  ///   print('Error: ${e.error}');
  /// }
  ///
  /// // Commonly used in transactions:
  /// await transaction.get(doc).then((snapshot) {
  ///   return validateSnapshot(snapshot)
  ///     ..tryThrowFail(); // Throws and aborts transaction if validation fails
  /// });
  /// ```
  void tryThrowFail() => switch (this) {
        Fail(
          error: final e,
          stackTrace: final st,
          title: final t,
          message: final m,
        ) =>
          throw TurboException(
            error: e,
            stackTrace: st,
            title: t,
            message: m,
          ),
        _ => null,
      };

  @override
  String toString() => switch (this) {
        Success(result: final r, title: final t, message: final m) =>
          'Success(result: $r, title: $t, message: $m)',
        Fail(error: final e, title: final t, message: final m) =>
          'Fail(error: $e, title: $t, message: $m)',
      };

  /// Pattern matches on the response state and returns a value based on the state.
  ///
  /// This method allows you to handle both success and fail states in a type-safe way.
  /// The [success] function is called when the response is successful, and the [fail]
  /// function is called when the response has failed.
  ///
  /// Example:
  /// ```dart
  /// final message = response.when(
  ///   success: (successResponse) => 'Got result: ${successResponse.result}',
  ///   fail: (failResponse) => 'Failed with: ${failResponse.error}',
  /// );
  /// ```
  R when<R>({
    required R Function(Success<T> response) success,
    required R Function(Fail<T> response) fail,
  }) =>
      switch (this) {
        Success<T>() => success(this as Success<T>),
        Fail<T>() => fail(this as Fail<T>),
      };
}

/// Represents a successful response with a result value.
///
/// The [Success] class is one of two possible states of a [TurboResponse].
/// It contains a required [result] value of type [T], and optional [title]
/// and [message] fields for additional context.
///
/// Example:
/// ```dart
/// final success = Success(
///   result: 42,
///   title: 'Computation',
///   message: 'Successfully computed the value',
/// );
/// ```
///
/// See also:
/// * [TurboResponse], the sealed class that defines the response type
/// * [Fail], the alternative state representing a failure
final class Success<T> extends TurboResponse<T> {
  const Success({
    required this.result,
    this.title,
    this.message,
  }) : super._();

  /// Creates a success state with a default result value.
  const Success.empty()
      : result = const _DefaultSuccess() as T,
        title = null,
        message = null,
        super._();

  @override
  final T result;
  @override
  final String? title;
  @override
  final String? message;

  /// Creates a copy of this Success with the given fields replaced with new values.
  Success<T> copyWith({
    T? result,
    String? title,
    String? message,
    bool clearTitle = false,
    bool clearMessage = false,
  }) {
    return Success<T>(
      result: result ?? this.result,
      title: clearTitle ? null : title ?? this.title,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> &&
        other.result == result &&
        other.title == title &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(result, title, message);
}

/// Default success value used when no specific result is provided.
class _DefaultSuccess {
  const _DefaultSuccess();

  @override
  String toString() => 'Operation succeeded';
}

/// Represents a failed response with an error.
///
/// The [Fail] class is one of two possible states of a [TurboResponse].
/// It contains a required [error] value, an optional [stackTrace] for debugging,
/// and optional [title] and [message] fields for additional context.
///
/// Example:
/// ```dart
/// final fail = Fail(
///   error: Exception('Invalid input'),
///   stackTrace: StackTrace.current,
///   title: 'Validation Error',
///   message: 'The input value was not in the correct format',
/// );
/// ```
///
/// See also:
/// * [TurboResponse], the sealed class that defines the response type
/// * [Success], the alternative state representing a success
final class Fail<T> extends TurboResponse<T> {
  const Fail({
    required this.error,
    this.stackTrace,
    this.title,
    this.message,
  }) : super._();

  /// Creates a fail state with a default error.
  const Fail.empty()
      : error = const _DefaultError(),
        stackTrace = null,
        title = null,
        message = null,
        super._();

  @override
  final Object error;
  final StackTrace? stackTrace;
  @override
  final String? title;
  @override
  final String? message;

  /// Creates a copy of this Fail with the given fields replaced with new values.
  Fail<T> copyWith({
    Object? error,
    StackTrace? stackTrace,
    String? title,
    String? message,
    bool clearStackTrace = false,
    bool clearTitle = false,
    bool clearMessage = false,
  }) {
    return Fail<T>(
      error: error ?? this.error,
      stackTrace: clearStackTrace ? null : stackTrace ?? this.stackTrace,
      title: clearTitle ? null : title ?? this.title,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fail<T> &&
        other.error == error &&
        other.stackTrace == stackTrace &&
        other.title == title &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(error, stackTrace, title, message);
}

/// Default error object used when no specific error is provided.
class _DefaultError {
  const _DefaultError();

  @override
  String toString() => 'Operation failed';
}

/// Extension methods for TurboResponse
extension TurboResponseX<T> on TurboResponse<T> {
  /// Whether this response represents a success state.
  bool get isSuccess => this is Success<T>;

  /// Whether this response represents a fail state.
  bool get isFail => this is Fail<T>;

  /// Handles this response by matching on its state and returning a value.
  ///
  /// Both success and failure handlers must be provided. This is similar to
  /// pattern matching in other languages.
  ///
  /// Example:
  /// ```dart
  /// final message = response.when(
  ///   success: (response) => 'Success: ${response.result}',
  ///   fail: (response) => 'Error: ${response.error}',
  /// );
  ///
  /// // Can also handle async operations
  /// final result = await response.when(
  ///   success: (response) async => await computeSuccess(response.result),
  ///   fail: (response) async => await handleError(response.error),
  /// );
  /// ```
  FutureOr<R> when<R>({
    required FutureOr<R> Function(Success<T> response) success,
    required FutureOr<R> Function(Fail<T> response) fail,
  }) async =>
      switch (this) {
        Success<T>() => await success(this as Success<T>),
        Fail<T>() => await fail(this as Fail<T>),
      };

  /// Handles this response by matching on its state and returning a value.
  ///
  /// Similar to [when], but handlers are optional. If a handler for the current
  /// state is not provided, it will throw a [StateError].
  ///
  /// Example:
  /// ```dart
  /// // Only handle success case
  /// final message = response.maybeWhen(
  ///   success: (response) => 'Success: ${response.result}',
  /// );
  ///
  /// // Only handle fail case
  /// final error = response.maybeWhen(
  ///   fail: (response) => 'Error: ${response.error}',
  /// );
  /// ```
  FutureOr<R> maybeWhen<R>({
    FutureOr<R> Function(Success<T> response)? success,
    FutureOr<R> Function(Fail<T> response)? fail,
  }) async =>
      switch (this) {
        Success<T>() => await success?.call(this as Success<T>) ??
            (throw StateError('No handler provided for Success state')),
        Fail<T>() => await fail?.call(this as Fail<T>) ??
            (throw StateError('No handler provided for Fail state')),
      };

  /// Handles a successful response, returning a value.
  /// Returns null if the response is a failure.
  ///
  /// This is a convenience method for when you only care about the success case.
  ///
  /// Example:
  /// ```dart
  /// final message = response.whenSuccess(
  ///   (response) => 'Success: ${response.result}',
  /// );
  /// ```
  FutureOr<R?> whenSuccess<R>(
          FutureOr<R> Function(Success<T> response) success) async =>
      isSuccess ? await success(this as Success<T>) : null;

  /// Handles a failed response, returning a value.
  /// Returns null if the response is a success.
  ///
  /// This is a convenience method for when you only care about the failure case.
  ///
  /// Example:
  /// ```dart
  /// final error = response.whenFail(
  ///   (response) => 'Error: ${response.error}',
  /// );
  /// ```
  FutureOr<R?> whenFail<R>(FutureOr<R> Function(Fail<T> response) fail) async =>
      isFail ? await fail(this as Fail<T>) : null;

  /// Transforms this response into a value by applying one of two functions.
  ///
  /// Similar to pattern matching but with a more functional style.
  ///
  /// Example:
  /// ```dart
  /// final length = response.fold(
  ///   onSuccess: (response) => response.result.length,
  ///   onFail: (response) => 0,
  /// );
  /// ```
  FutureOr<R> fold<R>({
    required FutureOr<R> Function(Success<T> response) onSuccess,
    required FutureOr<R> Function(Fail<T> response) onFail,
  }) =>
      when(success: onSuccess, fail: onFail);

  /// Maps the success value to a new value, preserving the response state.
  ///
  /// If this is a success response, applies [transform] to the result value
  /// and returns a new success response with the transformed value.
  /// If this is a fail response, returns a new fail response with the same error.
  ///
  /// Example:
  /// ```dart
  /// final lengthResponse = stringResponse.mapSuccess(
  ///   (value) => value.length,
  /// );
  /// ```
  FutureOr<TurboResponse<R>> mapSuccess<R>(
          FutureOr<R> Function(T value) transform) async =>
      switch (this) {
        Success<T>(result: final value, title: final t, message: final m) =>
          Success<R>(result: await transform(value), title: t, message: m),
        Fail<T>(
          error: final e,
          stackTrace: final st,
          title: final t,
          message: final m,
        ) =>
          Fail<R>(error: e, stackTrace: st, title: t, message: m),
      };

  /// Chains this response with another operation that returns a TurboResponse.
  ///
  /// If this is a success response, applies [transform] to the result value
  /// and returns the new response. If this is a fail response, returns a new
  /// fail response with the same error.
  ///
  /// Example:
  /// ```dart
  /// final nextResponse = response.andThen(
  ///   (value) => computeNext(value),
  /// );
  /// ```
  FutureOr<TurboResponse<R>> andThen<R>(
    FutureOr<TurboResponse<R>> Function(T value) transform,
  ) async =>
      switch (this) {
        Success<T>(result: final value) => await transform(value),
        Fail<T>(
          error: final e,
          stackTrace: final st,
          title: final t,
          message: final m,
        ) =>
          Fail<R>(error: e, stackTrace: st, title: t, message: m),
      };

  /// Transforms the failure value while preserving the success state.
  ///
  /// This is useful for transforming errors without affecting
  /// the success handling.
  ///
  /// Example:
  /// ```dart
  /// final wrappedResponse = response.mapFail(
  ///   (f) => WrappedError(f.error),
  /// );
  /// ```
  FutureOr<TurboResponse<T>> mapFail(
    FutureOr<Object> Function(Object) transform,
  ) async =>
      await when(
        success: (s) => TurboResponse.success(
          result: s.result,
          title: s.title,
          message: s.message,
        ),
        fail: (f) async => TurboResponse.fail(
          error: await transform(f.error),
          stackTrace: f.stackTrace,
          title: f.title,
          message: f.message,
        ),
      );

  /// Returns the success value or throws the error.
  ///
  /// This is useful when you want to force unwrap a success value
  /// and are willing to handle the potential error.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final value = response.unwrap();
  ///   print('Got value: $value');
  /// } catch (e) {
  ///   print('Failed: $e');
  /// }
  /// ```
  T unwrap() => switch (this) {
        Success(result: final r) => r,
        Fail(error: final e) => throw e,
      };

  /// Returns the success value or a default value.
  ///
  /// This is useful when you want to provide a fallback value
  /// for the failure case.
  ///
  /// Example:
  /// ```dart
  /// final value = response.unwrapOr('default');
  /// ```
  T unwrapOr(T defaultValue) => switch (this) {
        Success(result: final r) => r,
        Fail() => defaultValue,
      };

  /// Returns the success value or computes a default value.
  ///
  /// Similar to [unwrapOr], but the default value is computed only when needed.
  /// This is useful when the default value is expensive to compute.
  ///
  /// Example:
  /// ```dart
  /// final value = await response.unwrapOrCompute(
  ///   () => computeExpensiveDefault(),
  /// );
  /// ```
  FutureOr<T> unwrapOrCompute(FutureOr<T> Function() defaultValue) async =>
      switch (this) {
        Success(result: final r) => r,
        Fail() => await defaultValue(),
      };

  /// Recovers from a failure by transforming it into a success.
  ///
  /// This is useful when you want to provide a recovery mechanism
  /// for handling errors.
  ///
  /// Example:
  /// ```dart
  /// final recovered = await response.recover(
  ///   (error) => computeDefaultValue(error),
  /// );
  /// ```
  FutureOr<TurboResponse<T>> recover(
    FutureOr<T> Function(Object error) transform,
  ) async =>
      await when(
        success: (s) => TurboResponse.success(
          result: s.result,
          title: s.title,
          message: s.message,
        ),
        fail: (f) async => TurboResponse.success(
          result: await transform(f.error),
          title: f.title,
          message: f.message,
        ),
      );

  /// Safely casts this response to a different type.
  ///
  /// Returns a new TurboResponse with the cast type if successful,
  /// or a fail state if the cast fails.
  ///
  /// Example:
  /// ```dart
  /// final stringResponse = response.cast<String>();
  /// ```
  TurboResponse<R> cast<R>() {
    if (this is Success<T>) {
      final success = this as Success<T>;
      try {
        final castResult = success.result as R;
        return TurboResponse.success(
          result: castResult,
          title: success.title,
          message: success.message,
        );
      } catch (e, st) {
        return TurboResponse.fail(
          error: TypeError(),
          stackTrace: st,
          title: 'Type Cast Error',
          message: 'Could not cast ${T.toString()} to ${R.toString()}',
        );
      }
    } else {
      final fail = this as Fail<T>;
      return TurboResponse.fail(
        error: fail.error,
        stackTrace: fail.stackTrace,
        title: fail.title,
        message: fail.message,
      );
    }
  }

  /// Returns this response as a Success if it is one, otherwise null.
  ///
  /// This is useful for type-safe access to success state properties.
  ///
  /// Example:
  /// ```dart
  /// if (final success = response.asSuccess) {
  ///   print('Got result: ${success.result}');
  /// }
  /// ```
  Success<T>? get asSuccess => isSuccess ? this as Success<T> : null;

  /// Returns this response as a Fail if it is one, otherwise null.
  ///
  /// This is useful for type-safe access to fail state properties.
  ///
  /// Example:
  /// ```dart
  /// if (final fail = response.asFail) {
  ///   print('Got error: ${fail.error}');
  /// }
  /// ```
  Fail<T>? get asFail => isFail ? this as Fail<T> : null;

  /// Swaps the success and fail states of this response.
  ///
  /// In a success state, the result becomes the error of a new fail state.
  /// In a fail state, the error becomes the result of a new success state.
  ///
  /// Example:
  /// ```dart
  /// final inverted = response.swap();
  /// ```
  TurboResponse<T> swap() {
    if (this is Success<T>) {
      final success = this as Success<T>;
      return TurboResponse.fail(
        error: success.result ?? const _DefaultError(),
        title: success.title,
        message: success.message,
      );
    } else {
      final fail = this as Fail<T>;
      return TurboResponse.success(
        result:
            fail.error is T ? fail.error as T : const _DefaultSuccess() as T,
        title: fail.title,
        message: fail.message,
      );
    }
  }

  /// Ensures that a condition is met for a success state.
  ///
  /// If the condition fails, converts to a fail state.
  /// This is useful for adding validation checks to success values.
  ///
  /// Example:
  /// ```dart
  /// final validated = response.ensure(
  ///   (value) => value > 0,
  ///   error: 'Value must be positive',
  /// );
  /// ```
  TurboResponse<T> ensure(
    bool Function(T value) condition, {
    Object? error,
    String? title,
    String? message,
  }) {
    if (this is Success<T>) {
      final success = this as Success<T>;
      return condition(success.result)
          ? this
          : TurboResponse.fail(
              error: error ?? Exception('Validation failed'),
              title: title ?? 'Validation Error',
              message: message ??
                  'The success value did not meet the required condition',
            );
    }
    return this;
  }

  /// Traverses a list of items, applying an operation to each one.
  ///
  /// Returns a [TurboResponse] containing a list of results if all operations
  /// succeed, or the first failure encountered.
  ///
  /// Example:
  /// ```dart
  /// final result = await TurboResponseX.traverse(
  ///   items,
  ///   (item) => processItem(item),
  /// );
  /// ```
  static Future<TurboResponse<List<R>>> traverse<T, R>(
    List<T> items,
    Future<TurboResponse<R>> Function(T item) operation,
  ) async {
    final results = <R>[];
    for (final item in items) {
      final result = await operation(item);
      if (result case Fail(:final error, :final title, :final message)) {
        return TurboResponse.fail(
          error: error,
          title: title,
          message: message,
        );
      } else if (result case Success(:final result)) {
        results.add(result);
      }
    }
    return TurboResponse.success(result: results);
  }

  /// Combines a list of responses into a single response containing a list.
  ///
  /// If all responses are successful, returns a success response with a list
  /// of all results. If any response is a failure, returns the first failure
  /// encountered.
  ///
  /// Example:
  /// ```dart
  /// final responses = [response1, response2, response3];
  /// final combined = TurboResponseX.sequence(responses);
  /// ```
  static TurboResponse<List<T>> sequence<T>(
    List<TurboResponse<T>> responses,
  ) {
    final results = <T>[];
    for (final response in responses) {
      if (response case Fail(:final error, :final title, :final message)) {
        return TurboResponse.fail(
          error: error,
          title: title,
          message: message,
        );
      } else if (response case Success(:final result)) {
        results.add(result);
      }
    }
    return TurboResponse.success(result: results);
  }
}
