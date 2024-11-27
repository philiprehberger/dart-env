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
  philiprehberger_env: ^0.2.0
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
final env = Env.fromString('PORT=8080\nRATE=3.14\nDEBUG=true\nTAGS=a,b,c\nURL=https://example.com');

env.getString('PORT');                          // "8080"
env.getInt('PORT');                             // 8080
env.getDouble('RATE');                         // 3.14
env.getBool('DEBUG');                           // true
env.getList('TAGS');                            // ["a", "b", "c"]
env.getUri('URL');                             // Uri(https://example.com)
env.getString('MISSING', defaultValue: 'n/a'); // "n/a"
env.has('PORT');                                // true
env.keys;                                      // ('PORT', 'DEBUG', ...)
```

### Variable Expansion

```dart
final env = Env.fromString('HOST=localhost\nURL=http://\${HOST}:8080');
print(env.getString('URL')); // http://localhost:8080
```

### Default Variable Fallback

Use `${VAR:-default}` syntax to provide a fallback value when a variable is missing or empty:

```dart
final env = Env.fromString('URL=\${API_HOST:-localhost}:\${API_PORT:-3000}');
print(env.getString('URL')); // localhost:3000
```

### Merging Environments

Combine multiple Env instances with override semantics:

```dart
final defaults = Env({'PORT': '3000', 'HOST': 'localhost'});
final overrides = Env({'PORT': '8080'});
final env = defaults.merge(overrides);

print(env.getInt('PORT'));     // 8080 (overridden)
print(env.getString('HOST')); // localhost (from defaults)
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
| `getDouble(String key, {double? defaultValue})` | Get a double value |
| `getList(String key, {String separator, List<String>? defaultValue})` | Get a list by splitting on separator |
| `getUri(String key, {Uri? defaultValue})` | Get a parsed URI value |
| `has(String key)` | Check if a key exists |
| `keys` | Get all available keys |
| `merge(Env other)` | Combine with another Env (other wins on overlap) |
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
