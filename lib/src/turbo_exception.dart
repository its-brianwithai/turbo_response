/// A custom exception class for TurboResponse that includes a title and message.
///
/// This exception is thrown by TurboResponse when unwrapping a fail state.
/// It provides additional context through [title] and [message] fields.
///
/// Example:
/// ```dart
/// try {
///   response.throwWhenFail();
/// } on TurboException catch (e) {
///   print('Title: ${e.title}');
///   print('Message: ${e.message}');
///   print('Error: ${e.error}');
/// }
/// ```
class TurboException implements Exception {
  /// Creates a new TurboException with the given error and optional title and message.
  const TurboException({
    this.error,
    this.title,
    this.message,
    this.stackTrace,
  });

  /// The underlying error that caused this exception.
  final Object? error;

  /// An optional title providing context about the error.
  final String? title;

  /// An optional message providing additional details about the error.
  final String? message;

  /// The stack trace associated with the error, if available.
  final StackTrace? stackTrace;

  /// Whether this exception has a title.
  bool get hasTitle => title != null;

  /// Whether this exception has a message.
  bool get hasMessage => message != null;

  /// Whether this exception has an error.
  bool get hasError => error != null;

  @override
  String toString() {
    final buffer = StringBuffer('TurboException');
    if (title != null) buffer.write('($title)');
    if (error != null) buffer.write(': $error');
    if (message != null) buffer.write('\n$message');
    if (stackTrace != null) buffer.write('\n$stackTrace');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TurboException &&
        other.error == error &&
        other.title == title &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(error, title, message);
}
