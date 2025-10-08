![License](https://img.shields.io/badge/license-MIT-blue.svg?label=Licence)
![Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)

![Pub Version](https://img.shields.io/pub/v/mayr_result?style=plastic&label=Version)
![Pub.dev Score](https://img.shields.io/pub/points/mayr_result?label=Score&style=plastic)
![Pub Likes](https://img.shields.io/pub/likes/mayr_result?label=Likes&style=plastic)
![Pub.dev Publisher](https://img.shields.io/pub/publisher/mayr_result?label=Publisher&style=plastic)
![Downloads](https://img.shields.io/pub/dm/mayr_result.svg?label=Downloads&style=plastic)

![Build Status](https://img.shields.io/github/actions/workflow/status/YoungMayor/mayr_dart_result/ci.yaml?label=Build)
![Issues](https://img.shields.io/github/issues/YoungMayor/mayr_dart_result.svg?label=Issues)
![Last Commit](https://img.shields.io/github/last-commit/YoungMayor/mayr_dart_result.svg?label=Latest%20Commit)
![Contributors](https://img.shields.io/github/contributors/YoungMayor/mayr_dart_result.svg?label=Contributors)


# Result 🧩

A lightweight functional-style `Result` type for Dart that represents success (`Ok`) or failure (`Err`) outcomes.

Instead of throwing exceptions, `Result` lets you write **clear, predictable, and composable** code.
Inspired by Rust’s `Result<T, E>` and Kotlin’s `Result`, it provides a safe way to handle operations that may fail.

---

## ✨ Features

- ✅ Simple, expressive success/failure handling
- ⚡️ No exceptions — results you can trust
- 🧠 Composable: map, flatMap, fold, and more
- 🧩 Works seamlessly with async/await

---

## 🚀 Quick Start

```dart
import 'package:result/result.dart';

MayrResult<int, String> divide(int a, int b) {
  if (b == 0) return Err('Cannot divide by zero');
  return Ok(a ~/ b);
}

void main() {
  final result = divide(10, 2);

  // Method 1
  result.when(
    ok: (value) => print('Result: $value'),
    err: (error) => throw error,
  );

  // Method 2
  if (result.isOk) {
    print(result.value);
  }

  if (result.isErr) {
    throw result.error;
  }

  // Method 3
  result.onOk((value) => print('Result: $value'));

  result.onErr((error) => throw error);
}
```

## 📢 Additional Information

### 🤝 Contributing
Contributions are highly welcome!
If you have ideas for new extensions, improvements, or fixes, feel free to fork the repository and submit a pull request.

Please make sure to:
- Follow the existing coding style.
- Write tests for new features.
- Update documentation if necessary.

> Let's build something amazing together!

---

### 🐛 Reporting Issues
If you encounter a bug, unexpected behaviour, or have feature requests:
- Open an issue on the repository.
- Provide a clear description and steps to reproduce (if it's a bug).
- Suggest improvements if you have any ideas.

> Your feedback helps make the package better for everyone!

---

### 📜 Licence
This package is licensed under the MIT License — which means you are free to use it for commercial and non-commercial projects, with proper attribution.

> See the [LICENSE](LICENSE) file for more details.

---

## 🌟 Support

If you find this package helpful, please consider giving it a ⭐️ on GitHub — it motivates and helps the project grow!

You can also support by:
- Sharing the package with your friends, colleagues, and tech communities.
- Using it in your projects and giving feedback.
- Contributing new ideas, features, or improvements.

> Every little bit of support counts! 🚀💙
