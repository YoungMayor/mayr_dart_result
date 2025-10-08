/// A type that represents either success ([Ok]) or failure ([Err]).
///
/// The [MayrResult] type is a functional way to handle operations that can fail,
/// without throwing exceptions. It's inspired by Rust's `Result<T, E>` and
/// Kotlin's Result types.
///
/// Example:
/// ```dart
/// MayrResult<int, String> divide(int a, int b) {
///   if (b == 0) return Err('Cannot divide by zero');
///   return Ok(a ~/ b);
/// }
///
/// final result = divide(10, 2);
/// result.when(
///   ok: (value) => print('Result: $value'),
///   err: (error) => print('Error: $error'),
/// );
/// ```
sealed class MayrResult<T, E> {
  const MayrResult();

  /// Returns `true` if the result is [Ok].
  bool get isOk => this is Ok<T, E>;

  /// Returns `true` if the result is [Err].
  bool get isErr => this is Err<T, E>;

  /// Returns the success value.
  ///
  /// Throws a [StateError] if called on [Err].
  T get value {
    final self = this;
    if (self is Ok<T, E>) {
      return self._value;
    }
    throw StateError('Called value on Err');
  }

  /// Returns the error value.
  ///
  /// Throws a [StateError] if called on [Ok].
  E get error {
    final self = this;
    if (self is Err<T, E>) {
      return self._error;
    }
    throw StateError('Called error on Ok');
  }

  /// Pattern matches on the result.
  ///
  /// Calls [ok] with the success value if this is [Ok],
  /// or [err] with the error value if this is [Err].
  ///
  /// Example:
  /// ```dart
  /// result.when(
  ///   ok: (value) => print('Success: $value'),
  ///   err: (error) => print('Error: $error'),
  /// );
  /// ```
  R when<R>({
    required R Function(T value) ok,
    required R Function(E error) err,
  }) {
    final self = this;
    if (self is Ok<T, E>) {
      return ok(self._value);
    } else if (self is Err<T, E>) {
      return err(self._error);
    }
    throw StateError('Unreachable');
  }

  /// Calls [callback] with the success value if this is [Ok].
  ///
  /// Does nothing if this is [Err].
  ///
  /// Example:
  /// ```dart
  /// result.onOk((value) => print('Got value: $value'));
  /// ```
  void onOk(void Function(T value) callback) {
    final self = this;
    if (self is Ok<T, E>) {
      callback(self._value);
    }
  }

  /// Calls [callback] with the error value if this is [Err].
  ///
  /// Does nothing if this is [Ok].
  ///
  /// Example:
  /// ```dart
  /// result.onErr((error) => print('Got error: $error'));
  /// ```
  void onErr(void Function(E error) callback) {
    final self = this;
    if (self is Err<T, E>) {
      callback(self._error);
    }
  }

  /// Maps the success value using [transform].
  ///
  /// Returns a new [MayrResult] with the transformed value if this is [Ok].
  /// Returns the same [Err] if this is [Err].
  ///
  /// Example:
  /// ```dart
  /// final result = Ok<int, String>(5);
  /// final doubled = result.map((value) => value * 2); // Ok(10)
  /// ```
  MayrResult<R, E> map<R>(R Function(T value) transform) {
    final self = this;
    if (self is Ok<T, E>) {
      return Ok(transform(self._value));
    } else {
      return Err((self as Err<T, E>)._error);
    }
  }

  /// Maps the error value using [transform].
  ///
  /// Returns a new [MayrResult] with the transformed error if this is [Err].
  /// Returns the same [Ok] if this is [Ok].
  ///
  /// Example:
  /// ```dart
  /// final result = Err<int, String>('error');
  /// final mapped = result.mapErr((e) => 'Error: $e');
  /// ```
  MayrResult<T, F> mapErr<F>(F Function(E error) transform) {
    final self = this;
    if (self is Err<T, E>) {
      return Err(transform(self._error));
    } else {
      return Ok((self as Ok<T, E>)._value);
    }
  }

  /// Chains this result with another operation that returns a [MayrResult].
  ///
  /// This is useful for chaining operations that can fail.
  /// Also known as `andThen` or `bind` in functional programming.
  ///
  /// Example:
  /// ```dart
  /// MayrResult<int, String> parseNumber(String s) {
  ///   final n = int.tryParse(s);
  ///   return n != null ? Ok(n) : Err('Not a number');
  /// }
  ///
  /// MayrResult<int, String> double(int n) => Ok(n * 2);
  ///
  /// final result = parseNumber('5').flatMap(double); // Ok(10)
  /// ```
  MayrResult<R, E> flatMap<R>(MayrResult<R, E> Function(T value) transform) {
    final self = this;
    if (self is Ok<T, E>) {
      return transform(self._value);
    } else {
      return Err((self as Err<T, E>)._error);
    }
  }

  /// Combines success and error cases into a single value.
  ///
  /// Applies [onOk] to the success value or [onErr] to the error value.
  ///
  /// Example:
  /// ```dart
  /// final result = Ok<int, String>(5);
  /// final value = result.fold(
  ///   onOk: (v) => v * 2,
  ///   onErr: (e) => 0,
  /// ); // 10
  /// ```
  R fold<R>({
    required R Function(T value) onOk,
    required R Function(E error) onErr,
  }) {
    return when(ok: onOk, err: onErr);
  }

  /// Returns the success value or a default value if this is [Err].
  ///
  /// Example:
  /// ```dart
  /// final result = Err<int, String>('error');
  /// final value = result.unwrapOr(0); // 0
  /// ```
  T unwrapOr(T defaultValue) {
    final self = this;
    if (self is Ok<T, E>) {
      return self._value;
    } else {
      return defaultValue;
    }
  }

  /// Returns the success value or computes a default value if this is [Err].
  ///
  /// Example:
  /// ```dart
  /// final result = Err<int, String>('error');
  /// final value = result.unwrapOrElse((e) => e.length); // 5
  /// ```
  T unwrapOrElse(T Function(E error) defaultValue) {
    final self = this;
    if (self is Ok<T, E>) {
      return self._value;
    } else {
      return defaultValue((self as Err<T, E>)._error);
    }
  }

  @override
  String toString() {
    return when(ok: (value) => 'Ok($value)', err: (error) => 'Err($error)');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MayrResult<T, E>) return false;

    return when(
      ok: (value) => other is Ok<T, E> && other._value == value,
      err: (error) => other is Err<T, E> && other._error == error,
    );
  }

  @override
  int get hashCode => when(
    ok: (value) => Object.hash('Ok', value),
    err: (error) => Object.hash('Err', error),
  );
}

/// Represents a successful result containing a value.
///
/// Example:
/// ```dart
/// final result = Ok<int, String>(42);
/// print(result.value); // 42
/// ```
final class Ok<T, E> extends MayrResult<T, E> {
  final T _value;

  /// Creates a successful result with the given [value].
  const Ok(this._value);
}

/// Represents a failed result containing an error.
///
/// Example:
/// ```dart
/// final result = Err<int, String>('Something went wrong');
/// print(result.error); // 'Something went wrong'
/// ```
final class Err<T, E> extends MayrResult<T, E> {
  final E _error;

  /// Creates a failed result with the given [error].
  const Err(this._error);
}
