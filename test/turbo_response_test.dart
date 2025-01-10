import 'package:test/test.dart';
import 'package:turbo_response/turbo_response.dart';

Future<void> delay() => Future.delayed(const Duration(milliseconds: 1));

void main() {
  group('TurboResponse', () {
    test('Success state should have required result', () {
      final state = TurboResponse.success(
        result: 'test',
        title: 'Success',
        message: 'Test successful',
      );

      expect(state.result, equals('test'));
      expect(state.title, equals('Success'));
      expect(state.message, equals('Test successful'));
      expect(state.isSuccess, isTrue);
      expect(state.isFail, isFalse);
    });

    test('Fail state should have required error', () {
      final error = Exception('Test error');
      final state = TurboResponse<String>.fail(
        error: error,
        title: 'Error',
        message: 'Test failed',
      );

      expect(() => state.result, throwsA(isA<TurboException>()));
      expect(state.error, equals(error));
      expect(state.title, equals('Error'));
      expect(state.message, equals('Test failed'));
      expect(state.isSuccess, isFalse);
      expect(state.isFail, isTrue);
    });

    test('Fail state should work with type inference', () {
      // Type parameter inferred from context
      TurboResponse<int> response = TurboResponse.fail(
        error: 'Error',
        title: 'Error',
        message: 'Test failed',
      );
      expect(response.isFail, isTrue);
      expect(() => response.result, throwsA(isA<TurboException>()));

      // Type parameter inferred as dynamic when no context
      final dynamicResponse = TurboResponse.fail(
        error: 'Error',
        title: 'Error',
        message: 'Test failed',
      );
      expect(dynamicResponse.isFail, isTrue);
      expect(() => dynamicResponse.result, throwsA(isA<TurboException>()));
    });

    test('TurboException should have title and message getters', () {
      const exception = TurboException(
        error: 'error',
        title: 'Error Title',
        message: 'Error Message',
      );

      expect(exception.hasTitle, isTrue);
      expect(exception.hasMessage, isTrue);
      expect(exception.hasError, isTrue);

      const exceptionWithoutTitleAndMessage = TurboException(
        error: 'error',
      );

      expect(exceptionWithoutTitleAndMessage.hasTitle, isFalse);
      expect(exceptionWithoutTitleAndMessage.hasMessage, isFalse);
      expect(exceptionWithoutTitleAndMessage.hasError, isTrue);

      const exceptionWithoutError = TurboException(
        title: 'Error Title',
        message: 'Error Message',
      );

      expect(exceptionWithoutError.hasTitle, isTrue);
      expect(exceptionWithoutError.hasMessage, isTrue);
      expect(exceptionWithoutError.hasError, isFalse);
      expect(
          exceptionWithoutError.toString(), equals('TurboException(Error Title)\nError Message'));
    });

    test('when should handle all states correctly', () {
      TurboResponse<String> successState = const TurboResponse<String>.success(
        result: 'success',
        title: 'Success',
      );

      final result = successState.when(
        success: (s) => 'Success: ${s.result}',
        fail: (f) => 'Fail: ${f.error}',
      );

      expect(result, equals('Success: success'));
    });

    group('maybeWhen', () {
      test('should handle success state with success handler', () async {
        TurboResponse<String> state = const TurboResponse<String>.success(
          result: 'success',
          title: 'Success',
        );

        final result = await state.maybeWhen(
          success: (s) => 'Success: ${s.result}',
        );

        expect(result, equals('Success: success'));
      });

      test('should handle fail state with fail handler', () async {
        TurboResponse<String> state = const TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
        );

        final result = await state.maybeWhen(
          fail: (f) => 'Fail: ${f.error}',
        );

        expect(result, equals('Fail: error'));
      });

      test('should throw when no handler matches', () async {
        TurboResponse<String> state = const TurboResponse<String>.success(
          result: 'success',
          title: 'Success',
        );

        expect(
          () async => await state.maybeWhen(
            fail: (f) => 'Fail: ${f.error}',
          ),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('whenSuccess', () {
      test('should handle success state', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        final result = await state.whenSuccess((s) => 'Success: ${s.result}');
        expect(result, equals('Success: test'));
      });

      test('should return null for fail state', () async {
        final state = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
        );

        final result = await state.whenSuccess((s) => 'Success: ${s.result}');
        expect(result, isNull);
      });
    });

    group('whenFail', () {
      test('should handle fail state', () async {
        final state = TurboResponse<String>.fail(
          error: 'test error',
          title: 'Error',
        );

        final result = await state.whenFail((f) => 'Error: ${f.error}');
        expect(result, equals('Error: test error'));
      });

      test('should return null for success state', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        final result = await state.whenFail((f) => 'Error: ${f.error}');
        expect(result, isNull);
      });
    });

    group('fold', () {
      test('should handle success state', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        final value = await state.fold(
          onSuccess: (s) => 42,
          onFail: (f) => 0,
        );

        expect(value, equals(42));
      });

      test('should handle fail state', () async {
        final state = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
        );

        final value = await state.fold(
          onSuccess: (s) => 42,
          onFail: (f) => 0,
        );

        expect(value, equals(0));
      });
    });

    group('mapSuccess', () {
      test('should transform success value', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        final intResponse = await state.mapSuccess((s) => 42);
        expect(intResponse.result, equals(42));
        expect(intResponse.title, equals('Success'));
      });

      test('should preserve fail state', () async {
        final error = Exception('test error');
        final state = TurboResponse<String>.fail(
          error: error,
          title: 'Error',
        );

        final intResponse = await state.mapSuccess((s) => 42);
        expect(intResponse.error, equals(error));
        expect(intResponse.title, equals('Error'));
      });
    });

    group('mapFail', () {
      test('should transform error value', () async {
        final state = TurboResponse<String>.fail(
          error: 'test error',
          title: 'Error',
        );

        final wrappedResponse = await state.mapFail((e) => 'Wrapped: $e');
        expect(wrappedResponse.error, equals('Wrapped: test error'));
        expect(wrappedResponse.title, equals('Error'));
      });

      test('should preserve success state', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        final wrappedResponse = await state.mapFail((e) => 'Wrapped: $e');
        expect(wrappedResponse.result, equals('test'));
        expect(wrappedResponse.title, equals('Success'));
      });
    });

    group('unwrap', () {
      test('should return success value', () {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        expect(state.unwrap(), equals('test'));
      });

      test('should throw on fail state', () {
        final error = Exception('test error');
        final state = TurboResponse<String>.fail(
          error: error,
          title: 'Error',
        );

        expect(() => state.unwrap(), throwsA(equals(error)));
      });
    });

    group('unwrapOr', () {
      test('should return success value', () {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        expect(state.unwrapOr('default'), equals('test'));
      });

      test('should return default value on fail state', () {
        final state = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
        );

        expect(state.unwrapOr('default'), equals('default'));
      });
    });

    group('unwrapOrCompute', () {
      test('should return success value', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        var defaultCalled = false;
        final value = await state.unwrapOrCompute(() {
          defaultCalled = true;
          return 'default';
        });

        expect(value, equals('test'));
        expect(defaultCalled, isFalse);
      });

      test('should compute default value on fail state', () async {
        final state = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
        );

        var defaultCalled = false;
        final value = await state.unwrapOrCompute(() {
          defaultCalled = true;
          return 'default';
        });

        expect(value, equals('default'));
        expect(defaultCalled, isTrue);
      });
    });

    group('throwWhenFail', () {
      test('should throw TurboException with all properties', () {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;
        final state = TurboResponse<String>.fail(
          error: error,
          stackTrace: stackTrace,
          title: 'Error Title',
          message: 'Test message',
        );

        expect(
          () => state.throwWhenFail(),
          throwsA(
            isA<TurboException>()
                .having((e) => e.error, 'error', error)
                .having((e) => e.stackTrace, 'stackTrace', stackTrace)
                .having((e) => e.title, 'title', 'Error Title')
                .having((e) => e.message, 'message', 'Test message'),
          ),
        );
      });

      test('should throw TurboException with minimal properties', () {
        final error = Exception('Test error');
        final state = TurboResponse<String>.fail(
          error: error,
        );

        expect(
          () => state.throwWhenFail(),
          throwsA(
            isA<TurboException>()
                .having((e) => e.error, 'error', error)
                .having((e) => e.stackTrace, 'stackTrace', isNull)
                .having((e) => e.title, 'title', isNull)
                .having((e) => e.message, 'message', isNull),
          ),
        );
      });

      test('should not throw for success state', () {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        expect(() => state.throwWhenFail(), returnsNormally);
      });

      test('TurboException should have correct string representation', () {
        const exception = TurboException(
          error: 'Test error',
          title: 'Error Title',
          message: 'Test message',
        );

        expect(
          exception.toString(),
          equals('TurboException(Error Title): Test error\nTest message'),
        );
      });

      test('TurboException should handle missing optional properties', () {
        const exception = TurboException(
          error: 'Test error',
        );

        expect(
          exception.toString(),
          equals('TurboException: Test error'),
        );
      });

      test('TurboException should implement equality correctly', () {
        const exception1 = TurboException(
          error: 'Test error',
          title: 'Error Title',
          message: 'Test message',
        );

        const exception2 = TurboException(
          error: 'Test error',
          title: 'Error Title',
          message: 'Test message',
        );

        const exception3 = TurboException(
          error: 'Different error',
          title: 'Error Title',
          message: 'Test message',
        );

        expect(exception1, equals(exception2));
        expect(exception1.hashCode, equals(exception2.hashCode));
        expect(exception1, isNot(equals(exception3)));
      });
    });

    group('recover', () {
      test('should transform fail into success', () async {
        final state = TurboResponse<String>.fail(
          error: 'test error',
          title: 'Error',
          message: 'Failed',
        );

        final recovered = await state.recover((error) => 'recovered');

        expect(recovered.isSuccess, isTrue);
        expect(recovered.result, equals('recovered'));
        expect(recovered.title, equals('Error'));
        expect(recovered.message, equals('Failed'));
      });

      test('should preserve success state', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
          message: 'Succeeded',
        );

        final recovered = await state.recover((error) => 'recovered');

        expect(recovered.isSuccess, isTrue);
        expect(recovered.result, equals('test'));
        expect(recovered.title, equals('Success'));
        expect(recovered.message, equals('Succeeded'));
      });
    });

    group('andThen', () {
      test('should chain successful operations', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'First',
        );

        final result = await state.andThen((value) async {
          await delay();
          return TurboResponse<int>.success(
            result: value.length,
            title: 'Second',
          );
        });

        expect(result.result, equals(4));
        expect(result.title, equals('Second'));
      });

      test('should preserve fail state', () async {
        final error = Exception('test error');
        final state = TurboResponse<String>.fail(
          error: error,
          title: 'Error',
          message: 'Failed',
        );

        var operationCalled = false;
        final result = await state.andThen((_) {
          operationCalled = true;
          return const TurboResponse<String>.success(result: '42');
        });

        expect(result.isFail, isTrue);
        expect(result.error, equals(error));
        expect(result.title, equals('Error'));
        expect(result.message, equals('Failed'));
        expect(operationCalled, isFalse);
      });
    });

    group('toString', () {
      test('should format success state', () {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
          message: 'Succeeded',
        );

        expect(
          state.toString(),
          equals('Success(result: test, title: Success, message: Succeeded)'),
        );
      });

      test('should format fail state', () {
        final state = TurboResponse<String>.fail(
          error: 'test error',
          title: 'Error',
          message: 'Failed',
        );

        expect(
          state.toString(),
          equals('Fail(error: test error, title: Error, message: Failed)'),
        );
      });
    });

    group('async operations', () {
      test('should handle async when', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        final result = await state.when(
          success: (s) async {
            await delay();
            return 'Success: ${s.result}';
          },
          fail: (f) async {
            await delay();
            return 'Fail: ${f.error}';
          },
        );

        expect(result, equals('Success: test'));
      });

      test('should handle async mapSuccess', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        final response = await state.mapSuccess((value) async {
          await delay();
          return value.length;
        });

        expect(response.result, equals(4));
        expect(response.title, equals('Success'));
      });

      test('should handle async mapFail', () async {
        final state = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
        );

        final response = await state.mapFail((error) async {
          await delay();
          return 'Async: $error';
        });

        expect(response.error, equals('Async: error'));
        expect(response.title, equals('Error'));
      });

      test('should handle async recover', () async {
        final state = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
        );

        final response = await state.recover((error) async {
          await delay();
          return 'recovered';
        });

        expect(response.result, equals('recovered'));
      });

      test('should handle async andThen', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        final response = await state.andThen((value) async {
          await delay();
          return TurboResponse<int>.success(
            result: value.length,
            title: 'Async',
          );
        });

        expect(response.result, equals(4));
        expect(response.title, equals('Async'));
      });

      test('should handle mixed sync/async operations', () async {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        final lengthResponse = await state.mapSuccess((s) => s.length);
        final doubledResponse = await lengthResponse.andThen((n) async {
          await delay();
          return TurboResponse<int>.success(result: n * 2);
        });
        final response = await doubledResponse.mapSuccess((n) => n + 1);

        expect(response.result, equals(9)); // (4 * 2) + 1
      });

      test('should handle async unwrapOrCompute', () async {
        final state = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
        );

        var computeCalled = false;
        final result = await state.unwrapOrCompute(() async {
          computeCalled = true;
          await delay();
          return 'computed';
        });

        expect(result, equals('computed'));
        expect(computeCalled, isTrue);
      });
    });

    group('collection support', () {
      test('traverse should handle successful operations', () async {
        final items = ['a', 'b', 'c'];
        final result = await TurboResponseX.traverse(
          items,
          (item) async => TurboResponse<String>.success(result: item.toUpperCase()),
        );

        expect(result.isSuccess, isTrue);
        expect(result.result, equals(['A', 'B', 'C']));
      });

      test('traverse should handle failures', () async {
        final items = ['a', 'b', 'c'];
        final result = await TurboResponseX.traverse(
          items,
          (item) async => item == 'b'
              ? const TurboResponse<String>.fail(error: 'Failed on b')
              : TurboResponse<String>.success(result: item.toUpperCase()),
        );

        expect(result.isFail, isTrue);
        expect(result.error, equals('Failed on b'));
      });

      test('sequence should combine successful responses', () {
        final responses = [
          const TurboResponse<int>.success(result: 1),
          const TurboResponse<int>.success(result: 2),
          const TurboResponse<int>.success(result: 3),
        ];

        final result = TurboResponseX.sequence(responses);

        expect(result.isSuccess, isTrue);
        expect(result.result, equals([1, 2, 3]));
      });

      test('sequence should handle failures', () {
        final responses = [
          const TurboResponse<int>.success(result: 1),
          const TurboResponse<int>.fail(error: 'Failed'),
          const TurboResponse<int>.success(result: 3),
        ];

        final result = TurboResponseX.sequence(responses);

        expect(result.isFail, isTrue);
        expect(result.error, equals('Failed'));
      });
    });

    group('equality', () {
      test('success states should be equal with same values', () {
        final success1 = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
          message: 'Test message',
        );
        final success2 = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
          message: 'Test message',
        );

        expect(success1, equals(success2));
        expect(success1.hashCode, equals(success2.hashCode));
      });

      test('fail states should be equal with same values', () {
        const fail1 = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
          message: 'Test message',
        );
        const fail2 = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
          message: 'Test message',
        );

        expect(fail1, equals(fail2));
        expect(fail1.hashCode, equals(fail2.hashCode));
      });
    });

    group('empty constructors', () {
      test('successAsBool should create success with default result', () {
        final state = TurboResponse.successAsBool();
        expect(state.isSuccess, isTrue);
        expect(state.result.toString(), equals('Operation succeeded'));
        expect(state.title, isNull);
        expect(state.message, isNull);
      });

      test('failAsBool should create fail with default error', () {
        final state = TurboResponse.failAsBool();
        expect(state.isFail, isTrue);
        expect(state.error, isA<TurboException>());
        expect(state.error.toString(), equals('TurboException: Operation failed'));
        expect(state.title, isNull);
        expect(state.message, isNull);
      });

      test('empty states should be equal', () {
        final success1 = TurboResponse.successAsBool();
        final success2 = TurboResponse.successAsBool();
        final fail1 = TurboResponse.failAsBool();
        final fail2 = TurboResponse.failAsBool();

        expect(success1, equals(success2));
        expect(fail1, equals(fail2));
        expect(success1.hashCode, equals(success2.hashCode));
        expect(fail1.hashCode, equals(fail2.hashCode));
      });

      test('Empty success state should support title and message', () {
        final state = TurboResponse.successAsBool(
          title: 'Success',
          message: 'Operation completed',
        );

        expect(state.isSuccess, isTrue);
        expect(state.title, equals('Success'));
        expect(state.message, equals('Operation completed'));
        expect(state.result, isA<Object>());
      });

      test('Empty fail state should support title and message', () {
        final state = TurboResponse.failAsBool(
          title: 'Error',
          message: 'Operation failed',
        );

        expect(state.isFail, isTrue);
        expect(state.title, equals('Error'));
        expect(state.message, equals('Operation failed'));
        expect(state.error, isA<Object>());
        expect(() => state.result, throwsA(isA<TurboException>()));
      });
    });

    group('copyWith', () {
      test('success copyWith should update fields', () {
        final success = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
          message: 'Test message',
        );

        final updated = (success as Success<String>).copyWith(
          result: 'updated',
          title: 'Updated',
          message: 'Updated message',
        );

        expect(updated.result, equals('updated'));
        expect(updated.title, equals('Updated'));
        expect(updated.message, equals('Updated message'));
      });

      test('success copyWith should clear optional fields', () {
        final success = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
          message: 'Test message',
        );

        final updated = (success as Success<String>).copyWith(
          clearTitle: true,
          clearMessage: true,
        );

        expect(updated.result, equals('test'));
        expect(updated.title, isNull);
        expect(updated.message, isNull);
      });

      test('fail copyWith should update fields', () {
        const fail = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
          message: 'Test message',
        );

        final updated = (fail as Fail<String>).copyWith(
          error: 'updated error',
          title: 'Updated',
          message: 'Updated message',
        );

        expect(updated.error, equals('updated error'));
        expect(updated.title, equals('Updated'));
        expect(updated.message, equals('Updated message'));
      });

      test('fail copyWith should clear optional fields', () {
        final fail = TurboResponse<String>.fail(
          error: 'error',
          stackTrace: StackTrace.current,
          title: 'Error',
          message: 'Test message',
        );

        final updated = (fail as Fail<String>).copyWith(
          clearStackTrace: true,
          clearTitle: true,
          clearMessage: true,
        );

        expect(updated.error, equals('error'));
        expect(updated.stackTrace, isNull);
        expect(updated.title, isNull);
        expect(updated.message, isNull);
      });
    });

    group('type conversion', () {
      test('cast should handle successful type conversion', () {
        final state = TurboResponse<int>.success(
          result: 42,
          title: 'Success',
        );

        final stringState = state.cast<String>();
        expect(stringState.isFail, isTrue);
        expect(stringState.error, isA<TypeError>());
      });

      test('cast should preserve fail state', () {
        final state = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
        );

        final stringResponse = state.cast<String>();
        expect(stringResponse.isFail, isTrue);
        expect(stringResponse.error, equals('error'));
      });

      test('asSuccess should return success state', () {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
        );

        final success = state.asSuccess;
        expect(success, isNotNull);
        expect(success?.result, equals('test'));
      });

      test('asFail should return fail state', () {
        final state = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
        );

        final fail = state.asFail;
        expect(fail, isNotNull);
        expect(fail?.error, equals('error'));
      });
    });

    group('utility methods', () {
      test('swap should convert success to fail', () {
        final state = TurboResponse<String>.success(
          result: 'test',
          title: 'Success',
          message: 'Test message',
        );

        final swapped = state.swap();
        expect(swapped.isFail, isTrue);
        expect(swapped.error, equals('test'));
        expect(swapped.title, equals('Success'));
        expect(swapped.message, equals('Test message'));
      });

      test('swap should convert fail to success', () {
        final state = TurboResponse<String>.fail(
          error: 'error',
          title: 'Error',
          message: 'Test message',
        );

        final swapped = state.swap();
        expect(swapped.isSuccess, isTrue);
        expect(swapped.result, equals('error'));
        expect(swapped.title, equals('Error'));
        expect(swapped.message, equals('Test message'));
      });

      test('ensure should validate success state', () {
        final state = TurboResponse<int>.success(
          result: 42,
          title: 'Success',
        );

        final validated = state.ensure((value) => value > 0);
        expect(validated.isSuccess, isTrue);
        expect(validated.result, equals(42));
      });

      test('ensure should convert to fail on validation failure', () {
        final state = TurboResponse<int>.success(
          result: -42,
          title: 'Success',
        );

        final validated = state.ensure(
          (value) => value > 0,
          error: 'Value must be positive',
        );
        expect(validated.isFail, isTrue);
        expect(validated.error.toString(), equals('Value must be positive'));
      });

      test('ensure should preserve fail state', () {
        final state = TurboResponse<int>.fail(
          error: 'error',
          title: 'Error',
        );

        final validated = state.ensure((value) => value > 0);
        expect(validated.isFail, isTrue);
        expect(validated.error, equals('error'));
      });
    });
  });
}
