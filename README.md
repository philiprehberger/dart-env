# philiprehberger_env

[![Tests](https://github.com/philiprehberger/dart-env/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/dart-env/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/philiprehberger_env.svg)](https://pub.dev/packages/philiprehberger_env)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/dart-env)](https://github.com/philiprehberger/dart-env/commits/main)

Dotenv file parser with typed getters and multi-environment support

## Requirements

- Dart >= 3.6

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  philiprehberger_env: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Usage

```dart
import 'package:philiprehberger_env/philiprehberger_env.dart';

final env = Env.fromString('PORT=8080\nDEBUG=true');
print(env.getInt('PORT'));   // 8080
print(env.getBool('DEBUG')); // true
```

### Parsing .env Files

```dart
final content = '''
# Database config
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DEBUG=true
TAGS=web,api,auth
''';

final env = Env.fromString(content);
print(env.getString('DB_HOST')); // localhost
```

### Typed Getters

```dart
final env = Env.fromString('PORT=8080\nDEBUG=true\nTAGS=a,b,c');

env.getString('PORT');                          // "8080"
env.getInt('PORT');                             // 8080
env.getBool('DEBUG');                           // true
env.getList('TAGS');                            // ["a", "b", "c"]
env.getString('MISSING', defaultValue: 'n/a'); // "n/a"
env.has('PORT');                                // true
```

### Variable Expansion

```dart
final env = Env.fromString('HOST=localhost\nURL=http://\${HOST}:8080');
print(env.getString('URL')); // http://localhost:8080
```

### Quoted Values

```dart
final env = Env.fromString('MSG="hello world"\nPATH=\'/usr/bin\'');
print(env.getString('MSG'));  // hello world
print(env.getString('PATH')); // /usr/bin
```

## API

| Method | Description |
|--------|-------------|
| `Env(Map<String, String> values)` | Create an Env from a pre-parsed map |
| `Env.fromString(String content)` | Parse a `.env` file content string |
| `getString(String key, {String? defaultValue})` | Get a string value |
| `getInt(String key, {int? defaultValue})` | Get an integer value |
| `getBool(String key, {bool? defaultValue})` | Get a boolean (`true`/`1`/`yes`/`on`) |
| `getList(String key, {String separator, List<String>? defaultValue})` | Get a list by splitting on separator |
| `has(String key)` | Check if a key exists |
| `toMap()` | Get all values as a map |
| `DotenvParser.parse(String content)` | Parse `.env` content into a `Map<String, String>` |

## Development

```bash
dart pub get
dart analyze --fatal-infos
dart test
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/dart-env)

🐛 [Report issues](https://github.com/philiprehberger/dart-env/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/dart-env/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
