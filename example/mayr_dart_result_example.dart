import 'package:mayr_result/mayr_result.dart';

void main() {
  print('=== MayrResult Examples ===\n');

  // Example 1: Basic division
  print('Example 1: Safe division');
  final result1 = divide(10, 2);
  result1.when(
    ok: (value) => print('  10 / 2 = $value'),
    err: (error) => print('  Error: $error'),
  );

  final result2 = divide(10, 0);
  result2.when(
    ok: (value) => print('  10 / 0 = $value'),
    err: (error) => print('  Error: $error'),
  );

  // Example 2: Using isOk and isErr
  print('\nExample 2: Checking result state');
  final result3 = divide(20, 4);
  if (result3.isOk) {
    print('  Success! Result: ${result3.value}');
  }
  if (result3.isErr) {
    print('  Failed with error: ${result3.error}');
  }

  // Example 3: Using onOk and onErr
  print('\nExample 3: Conditional callbacks');
  divide(15, 3).onOk((value) => print('  Got value: $value'));
  divide(15, 0).onErr((error) => print('  Got error: $error'));

  // Example 4: Transforming values with then
  print('\nExample 4: Transforming results with then');
  final result4 = divide(100, 10).then((value) => value * 2);
  print('  (100 / 10) * 2 = ${result4.value}');

  // Example 5: Transforming errors with catchError
  print('\nExample 5: Transforming errors with catchError');
  final result5 = divide(10, 0).catchError((error) => 'Error occurred: $error');
  result5.when(
    ok: (value) => print('  Success: $value'),
    err: (error) => print('  $error'),
  );

  // Example 6: Chaining transformations
  print('\nExample 6: Chaining transformations');
  final result6 = divide(20, 4).then((n) => n * 2).then((n) => n + 10);
  result6.when(
    ok: (value) => print('  Result: $value'),
    err: (error) => print('  Error: $error'),
  );

  // Example 7: Using when for pattern matching
  print('\nExample 7: Pattern matching with when');
  final okResult = divide(50, 5);
  final message1 = okResult.when(
    ok: (v) => 'Success: $v',
    err: (e) => 'Failure: $e',
  );
  print('  $message1');

  final errResult = divide(50, 0);
  final message2 = errResult.when(
    ok: (v) => 'Success: $v',
    err: (e) => 'Failure: $e',
  );
  print('  $message2');

  // Example 8: Complex real-world example
  print('\nExample 8: Validation workflow');
  final workflow1 = validateAge('25');
  workflow1.when(
    ok: (age) => print('  ✓ Valid age: $age'),
    err: (error) => print('  ✗ $error'),
  );

  final workflow2 = validateAge('invalid');
  workflow2.when(
    ok: (age) => print('  ✓ Valid age: $age'),
    err: (error) => print('  ✗ $error'),
  );

  // Example 9: Converting types
  print('\nExample 9: Type conversion with then');
  final result9 = divide(42, 7).then((value) => 'Result is $value');
  print('  ${result9.value}');

  // Example 10: Error type conversion with catchError
  print('\nExample 10: Error type conversion with catchError');
  final result10 = divide(10, 0).catchError((error) => error.length);
  result10.when(
    ok: (value) => print('  Success: $value'),
    err: (errorLength) => print('  Error message length: $errorLength'),
  );
}

/// Safely divides two integers.
MayrResult<int, String> divide(int a, int b) {
  if (b == 0) return Err('Cannot divide by zero');
  return Ok(a ~/ b);
}

/// Validates and parses an age string.
MayrResult<int, String> validateAge(String ageStr) {
  final age = int.tryParse(ageStr);
  if (age == null) {
    return Err('Invalid age format: $ageStr');
  }
  if (age < 0) {
    return Err('Age cannot be negative');
  }
  if (age > 150) {
    return Err('Age seems unrealistic');
  }
  return Ok(age);
}
