import 'package:mayr_result/mayr_result.dart';
import 'package:test/test.dart';

void main() {
  group('MayrResult', () {
    group('Ok', () {
      test('creates a successful result', () {
        final result = Ok<int, String>(42);
        expect(result.isOk, isTrue);
        expect(result.isErr, isFalse);
        expect(result.value, equals(42));
      });

      test('throws StateError when accessing error on Ok', () {
        final result = Ok<int, String>(42);
        expect(() => result.error, throwsStateError);
      });

      test('toString returns correct format', () {
        final result = Ok<int, String>(42);
        expect(result.toString(), equals('Ok(42)'));
      });

      test('equality works correctly', () {
        final result1 = Ok<int, String>(42);
        final result2 = Ok<int, String>(42);
        final result3 = Ok<int, String>(43);

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });

      test('hashCode is consistent', () {
        final result1 = Ok<int, String>(42);
        final result2 = Ok<int, String>(42);

        expect(result1.hashCode, equals(result2.hashCode));
      });
    });

    group('Err', () {
      test('creates a failed result', () {
        final result = Err<int, String>('error message');
        expect(result.isOk, isFalse);
        expect(result.isErr, isTrue);
        expect(result.error, equals('error message'));
      });

      test('throws StateError when accessing value on Err', () {
        final result = Err<int, String>('error');
        expect(() => result.value, throwsStateError);
      });

      test('toString returns correct format', () {
        final result = Err<int, String>('error message');
        expect(result.toString(), equals('Err(error message)'));
      });

      test('equality works correctly', () {
        final result1 = Err<int, String>('error');
        final result2 = Err<int, String>('error');
        final result3 = Err<int, String>('different error');

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });

      test('hashCode is consistent', () {
        final result1 = Err<int, String>('error');
        final result2 = Err<int, String>('error');

        expect(result1.hashCode, equals(result2.hashCode));
      });
    });

    group('when', () {
      test('calls ok callback for Ok result', () {
        final result = Ok<int, String>(42);
        var okCalled = false;
        var errCalled = false;

        result.when(
          ok: (value) {
            okCalled = true;
            expect(value, equals(42));
            return value * 2;
          },
          err: (error) {
            errCalled = true;
            return 0;
          },
        );

        expect(okCalled, isTrue);
        expect(errCalled, isFalse);
      });

      test('calls err callback for Err result', () {
        final result = Err<int, String>('error');
        var okCalled = false;
        var errCalled = false;

        result.when(
          ok: (value) {
            okCalled = true;
            return value;
          },
          err: (error) {
            errCalled = true;
            expect(error, equals('error'));
            return 0;
          },
        );

        expect(okCalled, isFalse);
        expect(errCalled, isTrue);
      });

      test('returns value from callback', () {
        final okResult = Ok<int, String>(42);
        final okValue = okResult.when(
          ok: (value) => value * 2,
          err: (error) => 0,
        );
        expect(okValue, equals(84));

        final errResult = Err<int, String>('error');
        final errValue = errResult.when(
          ok: (value) => value,
          err: (error) => -1,
        );
        expect(errValue, equals(-1));
      });
    });

    group('onOk', () {
      test('calls callback for Ok result', () {
        final result = Ok<int, String>(42);
        var called = false;

        result.onOk((value) {
          called = true;
          expect(value, equals(42));
        });

        expect(called, isTrue);
      });

      test('does not call callback for Err result', () {
        final result = Err<int, String>('error');
        var called = false;

        result.onOk((value) {
          called = true;
        });

        expect(called, isFalse);
      });
    });

    group('onErr', () {
      test('calls callback for Err result', () {
        final result = Err<int, String>('error');
        var called = false;

        result.onErr((error) {
          called = true;
          expect(error, equals('error'));
        });

        expect(called, isTrue);
      });

      test('does not call callback for Ok result', () {
        final result = Ok<int, String>(42);
        var called = false;

        result.onErr((error) {
          called = true;
        });

        expect(called, isFalse);
      });
    });

    group('then', () {
      test('transforms Ok value', () {
        final result = Ok<int, String>(42);
        final transformed = result.then((value) => value * 2);

        expect(transformed.isOk, isTrue);
        expect(transformed.value, equals(84));
      });

      test('preserves Err unchanged', () {
        final result = Err<int, String>('error');
        final transformed = result.then((value) => value * 2);

        expect(transformed.isErr, isTrue);
        expect(transformed.error, equals('error'));
      });

      test('can change type', () {
        final result = Ok<int, String>(42);
        final transformed = result.then((value) => value.toString());

        expect(transformed.isOk, isTrue);
        expect(transformed.value, equals('42'));
      });
    });

    group('catchError', () {
      test('transforms Err value', () {
        final result = Err<int, String>('error');
        final caught = result.catchError((error) => 'Error: $error');

        expect(caught.isErr, isTrue);
        expect(caught.error, equals('Error: error'));
      });

      test('preserves Ok unchanged', () {
        final result = Ok<int, String>(42);
        final caught = result.catchError((error) => 'Error: $error');

        expect(caught.isOk, isTrue);
        expect(caught.value, equals(42));
      });

      test('can change error type', () {
        final result = Err<int, String>('error');
        final caught = result.catchError((error) => error.length);

        expect(caught.isErr, isTrue);
        expect(caught.error, equals(5));
      });
    });

    group('Real-world examples', () {
      MayrResult<int, String> divide(int a, int b) {
        if (b == 0) return Err('Cannot divide by zero');
        return Ok(a ~/ b);
      }

      MayrResult<int, String> parseNumber(String s) {
        final n = int.tryParse(s);
        return n != null ? Ok(n) : Err('Not a number: $s');
      }

      test('divide function works correctly', () {
        final result1 = divide(10, 2);
        expect(result1.isOk, isTrue);
        expect(result1.value, equals(5));

        final result2 = divide(10, 0);
        expect(result2.isErr, isTrue);
        expect(result2.error, equals('Cannot divide by zero'));
      });

      test('parseNumber function works correctly', () {
        final result1 = parseNumber('42');
        expect(result1.isOk, isTrue);
        expect(result1.value, equals(42));

        final result2 = parseNumber('not a number');
        expect(result2.isErr, isTrue);
        expect(result2.error, equals('Not a number: not a number'));
      });

      test('chaining operations with then', () {
        final result = divide(10, 2).then((n) => n * 2);

        expect(result.isOk, isTrue);
        expect(result.value, equals(10)); // (10 / 2) * 2 = 10
      });

      test('handling with when', () {
        final result = divide(10, 2);
        final message = result.when(
          ok: (value) => 'Result: $value',
          err: (error) => 'Error: $error',
        );

        expect(message, equals('Result: 5'));
      });
    });

    group('Type inference', () {
      test('works with explicit types', () {
        final result = Ok<int, String>(42);
        expect(result.value, equals(42));
      });

      test('works with inferred types', () {
        MayrResult<int, String> result = Ok(42);
        expect(result.value, equals(42));
      });
    });

    group('Null safety', () {
      test('can wrap nullable values', () {
        final result = Ok<int?, String>(null);
        expect(result.isOk, isTrue);
        expect(result.value, isNull);
      });

      test('can wrap nullable errors', () {
        final result = Err<int, String?>(null);
        expect(result.isErr, isTrue);
        expect(result.error, isNull);
      });
    });
  });
}
