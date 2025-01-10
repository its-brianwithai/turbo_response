import 'package:test/test.dart';
import 'package:turbo_response/turbo_response.dart';

void main() {
  group('DefaultResult', () {
    test('empty success result should equal true', () {
      final response = TurboResponse<dynamic>.successAsBool();
      expect(response.result == true, isTrue);
    });

    test('empty fail error should be TurboException', () {
      final response = TurboResponse<dynamic>.failAsBool();
      expect(response.error, isA<TurboException>());
      expect(response.error.toString(),
          equals('TurboException: Operation failed'));
    });

    test('empty success result should equal another empty success', () {
      final response1 = TurboResponse<dynamic>.successAsBool();
      final response2 = TurboResponse<dynamic>.successAsBool();
      expect(response1.result == response2.result, isTrue);
    });

    test('empty success result should not equal false', () {
      final response = TurboResponse<dynamic>.successAsBool();
      expect(response.result == false, isFalse);
    });

    test('empty success result should not equal other objects', () {
      final response = TurboResponse<dynamic>.successAsBool();
      expect(response.result == 'true', isFalse);
      expect(response.result == 1, isFalse);
      expect(response.result == null, isFalse);
    });

    test('empty success result toString should be descriptive', () {
      final response = TurboResponse<dynamic>.successAsBool();
      expect(response.result.toString(), equals('Operation succeeded'));
    });

    test('empty fail error should have descriptive message', () {
      final response = TurboResponse<dynamic>.failAsBool();
      expect(
          (response.error as TurboException).error, equals('Operation failed'));
    });
  });
}
