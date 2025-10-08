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

  // Example 4: Mapping values
  print('\nExample 4: Transforming results');
  final result4 = divide(100, 10).map((value) => value * 2);
  print('  (100 / 10) * 2 = ${result4.value}');

  // Example 5: Chaining operations with flatMap
  print('\nExample 5: Chaining operations');
  final chainResult = parseNumber(
    '50',
  ).flatMap((n) => divide(100, n)).map((n) => n * 10);
  chainResult.when(
    ok: (value) => print('  Chain result: $value'),
    err: (error) => print('  Chain error: $error'),
  );

  // Example 6: Error propagation
  print('\nExample 6: Error propagation in chains');
  final errorChain = parseNumber(
    'invalid',
  ).flatMap((n) => divide(100, n)).map((n) => n * 10);
  errorChain.when(
    ok: (value) => print('  Chain result: $value'),
    err: (error) => print('  Chain error: $error'),
  );

  // Example 7: Using fold
  print('\nExample 7: Folding results');
  final okResult = divide(50, 5);
  final value1 = okResult.fold(
    onOk: (v) => 'Success: $v',
    onErr: (e) => 'Failure: $e',
  );
  print('  $value1');

  final errResult = divide(50, 0);
  final value2 = errResult.fold(
    onOk: (v) => 'Success: $v',
    onErr: (e) => 'Failure: $e',
  );
  print('  $value2');

  // Example 8: Using unwrapOr and unwrapOrElse
  print('\nExample 8: Providing defaults');
  final result5 = divide(10, 0);
  print('  With default: ${result5.unwrapOr(-1)}');
  print('  With computed default: ${result5.unwrapOrElse((e) => 0)}');

  // Example 9: Complex real-world example
  print('\nExample 9: Complex workflow');
  final workflow = validateAge(
    '25',
  ).flatMap((age) => checkEligibility(age)).map((msg) => msg.toUpperCase());

  workflow.when(
    ok: (msg) => print('  ✓ $msg'),
    err: (error) => print('  ✗ $error'),
  );

  // Example 10: Error cases
  print('\nExample 10: Handling various errors');
  final workflows = [
    validateAge('15'),
    validateAge('invalid'),
    validateAge('25'),
  ];

  for (var i = 0; i < workflows.length; i++) {
    final result = workflows[i]
        .flatMap((age) => checkEligibility(age))
        .map((msg) => msg.toUpperCase());

    result.when(
      ok: (msg) => print('  Case ${i + 1}: ✓ $msg'),
      err: (error) => print('  Case ${i + 1}: ✗ $error'),
    );
  }
}

/// Safely divides two integers.
MayrResult<int, String> divide(int a, int b) {
  if (b == 0) return Err('Cannot divide by zero');
  return Ok(a ~/ b);
}

/// Parses a string into an integer.
MayrResult<int, String> parseNumber(String s) {
  final n = int.tryParse(s);
  return n != null ? Ok(n) : Err('Not a number: $s');
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

/// Checks if age is eligible for something (18+).
MayrResult<String, String> checkEligibility(int age) {
  if (age < 18) {
    return Err('Must be 18 or older (current age: $age)');
  }
  return Ok('Eligible! Age: $age');
}
