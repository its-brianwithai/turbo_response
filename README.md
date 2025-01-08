# TurboResponse

A type-safe response that can be either successful or failed, with proper error handling and pattern matching. Works seamlessly with both pure Dart and Flutter projects.

## Features

- 🎯 Type-safe success and failure states
- 🔄 Pattern matching with `when` and `maybeWhen`
- 🛠️ Transformation methods like `mapSuccess`, `mapFail`, and `andThen`
- ⚡ Async operation support
- 🎁 Utility methods like `unwrap`, `unwrapOr`, and `ensure`
- 🔗 Static utility methods `traverse` and `sequence`
- 🎨 Platform agnostic - zero Flutter dependencies required

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

// Pattern match on the response
final message = response.when(
  success: (response) => 'Got result: ${response.result}',
  fail: (response) => 'Failed with: ${response.error}',
);
```

### Async Operations

```dart
// Transform a value asynchronously
final lengthResponse = await stringResponse.mapSuccess(
  (value) async => await computeLength(value),
);

// Chain async operations
final result = await response
  .andThen((value) async => await validateValue(value))
  .andThen((value) async => await saveValue(value));
```

### Utility Methods

```dart
// Get the value or throw
try {
  final value = response.unwrap();
  print('Got value: $value');
} catch (e) {
  print('Failed: $e');
}

// Get the value or a default
final value = response.unwrapOr('default');

// Validate a success value
final validated = response.ensure(
  (value) => value > 0,
  error: 'Value must be positive',
);
```

### Static Utilities

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

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  turbo_response: ^0.2.4
```

Works out of the box with both Dart and Flutter projects - no additional setup required!

## Additional information

For more examples and detailed API documentation, visit the [API reference](https://pub.dev/documentation/turbo_response/latest/).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
