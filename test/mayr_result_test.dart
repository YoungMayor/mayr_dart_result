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

    group('map', () {
      test('transforms Ok value', () {
        final result = Ok<int, String>(42);
        final mapped = result.map((value) => value * 2);

        expect(mapped.isOk, isTrue);
        expect(mapped.value, equals(84));
      });

      test('preserves Err unchanged', () {
        final result = Err<int, String>('error');
        final mapped = result.map((value) => value * 2);

        expect(mapped.isErr, isTrue);
        expect(mapped.error, equals('error'));
      });

      test('can change type', () {
        final result = Ok<int, String>(42);
        final mapped = result.map((value) => value.toString());

        expect(mapped.isOk, isTrue);
        expect(mapped.value, equals('42'));
      });
    });

    group('mapErr', () {
      test('transforms Err value', () {
        final result = Err<int, String>('error');
        final mapped = result.mapErr((error) => 'Error: $error');

        expect(mapped.isErr, isTrue);
        expect(mapped.error, equals('Error: error'));
      });

      test('preserves Ok unchanged', () {
        final result = Ok<int, String>(42);
        final mapped = result.mapErr((error) => 'Error: $error');

        expect(mapped.isOk, isTrue);
        expect(mapped.value, equals(42));
      });

      test('can change error type', () {
        final result = Err<int, String>('error');
        final mapped = result.mapErr((error) => error.length);

        expect(mapped.isErr, isTrue);
        expect(mapped.error, equals(5));
      });
    });

    group('flatMap', () {
      test('chains Ok results', () {
        final result = Ok<int, String>(42);
        final chained = result.flatMap((value) => Ok<int, String>(value * 2));

        expect(chained.isOk, isTrue);
        expect(chained.value, equals(84));
      });

      test('short-circuits on Err', () {
        final result = Err<int, String>('error');
        final chained = result.flatMap((value) => Ok<int, String>(value * 2));

        expect(chained.isErr, isTrue);
        expect(chained.error, equals('error'));
      });

      test('chains to Err result', () {
        final result = Ok<int, String>(0);
        final chained = result.flatMap((value) {
          if (value == 0) return Err<int, String>('Cannot be zero');
          return Ok<int, String>(100 ~/ value);
        });

        expect(chained.isErr, isTrue);
        expect(chained.error, equals('Cannot be zero'));
      });

      test('can be chained multiple times', () {
        final result = Ok<int, String>(5)
            .flatMap((v) => Ok<int, String>(v * 2))
            .flatMap((v) => Ok<int, String>(v + 10))
            .flatMap((v) => Ok<int, String>(v * 3));

        expect(result.isOk, isTrue);
        expect(result.value, equals(60)); // (5 * 2 + 10) * 3 = 60
      });
    });

    group('fold', () {
      test('applies onOk for Ok result', () {
        final result = Ok<int, String>(42);
        final folded = result.fold(
          onOk: (value) => value * 2,
          onErr: (error) => 0,
        );

        expect(folded, equals(84));
      });

      test('applies onErr for Err result', () {
        final result = Err<int, String>('error');
        final folded = result.fold(
          onOk: (value) => value,
          onErr: (error) => error.length,
        );

        expect(folded, equals(5));
      });
    });

    group('unwrapOr', () {
      test('returns value for Ok result', () {
        final result = Ok<int, String>(42);
        expect(result.unwrapOr(0), equals(42));
      });

      test('returns default for Err result', () {
        final result = Err<int, String>('error');
        expect(result.unwrapOr(0), equals(0));
      });
    });

    group('unwrapOrElse', () {
      test('returns value for Ok result', () {
        final result = Ok<int, String>(42);
        expect(result.unwrapOrElse((error) => 0), equals(42));
      });

      test('computes default for Err result', () {
        final result = Err<int, String>('error');
        expect(result.unwrapOrElse((error) => error.length), equals(5));
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

      test('chaining operations', () {
        final result = parseNumber('10')
            .flatMap((n) => divide(100, n))
            .map((n) => n * 2);

        expect(result.isOk, isTrue);
        expect(result.value, equals(20)); // (100 / 10) * 2 = 20
      });

      test('error propagation in chains', () {
        final result = parseNumber('not a number')
            .flatMap((n) => divide(100, n))
            .map((n) => n * 2);

        expect(result.isErr, isTrue);
        expect(result.error, contains('Not a number'));
      });

      test('division by zero in chain', () {
        final result = parseNumber('0')
            .flatMap((n) => divide(100, n))
            .map((n) => n * 2);

        expect(result.isErr, isTrue);
        expect(result.error, equals('Cannot divide by zero'));
      });

      test('handling with when', () {
        final result = divide(10, 2);
        final message = result.when(
          ok: (value) => 'Result: $value',
          err: (error) => 'Error: $error',
        );

        expect(message, equals('Result: 5'));
      });

      test('handling with fold', () {
        final okResult = divide(10, 2);
        final value1 = okResult.fold(
          onOk: (v) => v,
          onErr: (e) => -1,
        );
        expect(value1, equals(5));

        final errResult = divide(10, 0);
        final value2 = errResult.fold(
          onOk: (v) => v,
          onErr: (e) => -1,
        );
        expect(value2, equals(-1));
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
