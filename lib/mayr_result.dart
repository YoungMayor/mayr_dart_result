/// A lightweight functional-style Result type for Dart.
///
/// The [MayrResult] type represents either success ([Ok]) or failure ([Err]).
/// This provides a safe way to handle operations that may fail without
/// throwing exceptions.
///
/// Inspired by Rust's `Result<T, E>` and Kotlin's `Result`.
///
/// Example:
/// ```dart
/// import 'package:mayr_result/mayr_result.dart';
///
/// MayrResult<int, String> divide(int a, int b) {
///   if (b == 0) return Err('Cannot divide by zero');
///   return Ok(a ~/ b);
/// }
///
/// void main() {
///   final result = divide(10, 2);
///   result.when(
///     ok: (value) => print('Result: $value'),
///     err: (error) => print('Error: $error'),
///   );
/// }
/// ```
library;

export 'src/mayr_result_base.dart';
