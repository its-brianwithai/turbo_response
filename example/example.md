# TurboResponse Examples

This document provides examples of how to use the `turbo_response` package in various scenarios.

## Basic Usage

```dart
import 'package:turbo_response/turbo_response.dart';

void main() {
  // Create a success response
  final success = TurboResponse.success(
    result: 42,
    title: 'Computation',
    message: 'Successfully computed the value',
  );

  // Create a fail response
  final fail = TurboResponse.fail(
    error: Exception('Invalid input'),
    title: 'Validation Error',
    message: 'The input value was not in the correct format',
  );

  // Create empty responses
  final emptySuccess = TurboResponse.emptySuccess();
  final emptyFail = TurboResponse.emptyFail();
}
```

## Pattern Matching

```dart
void handleResponse(TurboResponse<int> response) {
  // Using when
  final message = response.when(
    success: (s) => 'Got value: ${s.result}',
    fail: (f) => 'Error: ${f.error}',
  );

  // Using maybeWhen
  final successMessage = response.maybeWhen(
    success: (s) => 'Success: ${s.result}',
  );

  // Using convenience methods
  final result = response.whenSuccess((s) => s.result);
  final error = response.whenFail((f) => f.error);
}
```

## Async Operations

```dart
Future<TurboResponse<int>> computeValue() async {
  try {
    final value = await performComputation();
    return TurboResponse.success(result: value);
  } catch (e) {
    return TurboResponse.fail(error: e);
  }
}

Future<void> processResponse() async {
  final response = await computeValue();

  // Chain operations
  final result = await response
    .andThen((value) => validateValue(value))
    .andThen((value) => processValue(value));

  // Transform success value
  final stringResponse = await response.mapSuccess((value) => value.toString());

  // Transform error
  final wrappedResponse = await response.mapFail((error) => 'Wrapped: $error');

  // Recover from failure
  final recovered = await response.recover((error) => computeDefaultValue());
}
```

## Collection Support

```dart
Future<void> processItems(List<String> items) async {
  // Process multiple items
  final result = await TurboResponseX.traverse(
    items,
    (item) => processItem(item),
  );

  // Combine multiple responses
  final responses = [
    TurboResponse.success(result: 1),
    TurboResponse.success(result: 2),
    TurboResponse.success(result: 3),
  ];
  final combined = TurboResponseX.sequence(responses);
}
```

## Error Handling

```dart
void handleErrors(TurboResponse<int> response) {
  // Using unwrap
  try {
    final value = response.unwrap();
    print('Got value: $value');
  } catch (e) {
    print('Failed: $e');
  }

  // Using unwrapOr
  final value = response.unwrapOr(0);

  // Using unwrapOrCompute
  final computed = response.unwrapOrCompute(() => computeDefault());

  // Throw error if present
  response.throwFail();
}
```

## Type Conversion and Validation

```dart
void typeOperations(TurboResponse<int> response) {
  // Cast to different type
  final stringResponse = response.cast<String>();

  // Type-safe access
  if (final success = response.asSuccess) {
    print('Got result: ${success.result}');
  }

  if (final fail = response.asFail) {
    print('Got error: ${fail.error}');
  }

  // Validation
  final validated = response.ensure(
    (value) => value > 0,
    error: 'Value must be positive',
  );
}
```

## State Updates

```dart
void updateState(TurboResponse<String> response) {
  // Update success state
  if (final success = response.asSuccess) {
    final updated = success.copyWith(
      result: 'new value',
      title: 'Updated',
      message: 'Value was updated',
    );
  }

  // Update fail state
  if (final fail = response.asFail) {
    final updated = fail.copyWith(
      error: 'new error',
      title: 'Updated Error',
      message: 'Error was updated',
    );
  }

  // Clear optional fields
  if (final success = response.asSuccess) {
    final cleared = success.copyWith(
      clearTitle: true,
      clearMessage: true,
    );
  }
}
``` 