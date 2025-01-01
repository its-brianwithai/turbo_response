# TurboResponse

A type-safe response handling package for Dart and Flutter applications. TurboResponse provides a robust way to handle operation results with proper type safety and error handling.

## Features

- Type-safe response handling with sealed classes
- Comprehensive error handling with stack traces
- Pattern matching support with `when` and `maybeWhen`
- Convenient extension methods for common operations
- Collection support for handling multiple responses
- Utility methods for type casting and validation
- Immutable by design with `copyWith` support

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  turbo_response: ^0.1.0
```

## Usage

### Basic Usage

```dart
// Create a success response
final success = TurboResponse.success(
  result: 'Hello',
  title: 'Greeting',
  message: 'Welcome message',
);

// Create a fail response
final fail = TurboResponse.fail(
  error: Exception('Something went wrong'),
  title: 'Error',
  message: 'Operation failed',
);

// Create empty responses
final emptySuccess = TurboResponse.emptySuccess();
final emptyFail = TurboResponse.emptyFail();

// Access result (throws TurboException if fail state)
try {
  final value = response.result;
  print('Got value: $value');
} on TurboException catch (e) {
  if (e.hasError) print('Error: ${e.error}');
  if (e.hasTitle) print('Title: ${e.title}');
  if (e.hasMessage) print('Message: ${e.message}');
}
```

### Pattern Matching

```dart
// Using when
final message = response.when(
  success: (s) => 'Got result: ${s.result}',
  fail: (f) => 'Failed with: ${f.error}',
);

// Using maybeWhen
final successMessage = response.maybeWhen(
  success: (s) => 'Success: ${s.result}',
);

// Using convenience methods
final result = response.whenSuccess((s) => s.result);
final error = response.whenFail((f) => f.error);
```

### Transformations

```dart
// Transform success value
final lengthResponse = response.mapSuccess((value) => value.length);

// Transform error
final wrappedResponse = response.mapFail((error) => WrappedError(error));

// Chain operations
final result = await response
  .andThen((value) => validateValue(value))
  .andThen((value) => processValue(value));
```

### Collection Support

```dart
// Process a list of items
final result = await TurboResponseX.traverse(
  items,
  (item) => processItem(item),
);

// Combine multiple responses
final responses = [response1, response2, response3];
final combined = TurboResponseX.sequence(responses);
```

### Utility Methods

```dart
// Type casting
final stringResponse = response.cast<String>();

// Type-safe access
if (final success = response.asSuccess) {
  print('Got result: ${success.result}');
}

// Validation
final validated = response.ensure(
  (value) => value > 0,
  error: 'Value must be positive',
);

// Value extraction
final value = response.unwrapOr('default');
final computed = await response.unwrapOrCompute(() => computeDefault());

// Error handling
try {
  final value = response.unwrap();
  print('Got value: $value');
} catch (e) {
  print('Failed: $e');
}

// Recovery
final recovered = await response.recover(
  (error) => computeDefaultValue(error),
);
```

## Additional Information

For more information, please visit:
- [API Documentation](https://pub.dev/documentation/turbo_response/latest/)
- [GitHub Repository](https://github.com/your_username/turbo_response)
- [Issue Tracker](https://github.com/your_username/turbo_response/issues)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
