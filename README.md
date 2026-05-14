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
  philiprehberger_env: ^0.5.0
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
final env = Env.fromString('PORT=8080\nRATE=3.14\nDEBUG=true\nTAGS=a,b,c\nURL=https://example.com\nLOG_LEVEL=info');

env.getString('PORT');                          // "8080"
env.getInt('PORT');                             // 8080
env.getDouble('RATE');                         // 3.14
env.getBool('DEBUG');                           // true
env.getList('TAGS');                            // ["a", "b", "c"]
env.getUri('URL');                             // Uri(https://example.com)
env.getEnum('LOG_LEVEL', LogLevel.values);     // LogLevel.info
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

### Process Environment

```dart
import 'package:philiprehberger_env/philiprehberger_env.dart';

final env = Env.fromPlatform();
print(env.getString('HOME'));
print(env.getString('PATH'));
```

### Loading from a File

```dart
final env = Env.fromFile('.env');
print(env.getString('DB_HOST'));
```

### Date and Duration Values

```dart
final env = Env.fromString('DEPLOYED_AT=2026-05-13T22:30:00Z\nTIMEOUT=30s\nRETRY=500ms\nTTL=2h');
env.getDateTime('DEPLOYED_AT'); // DateTime(2026-05-13 22:30:00Z)
env.getDuration('TIMEOUT');     // Duration(seconds: 30)
env.getDuration('RETRY');       // Duration(milliseconds: 500)
env.getDuration('TTL');         // Duration(hours: 2)
```

Duration suffixes: `ms`, `s`, `m`, `h`, `d`. A bare integer is treated as milliseconds.

### Required Keys

Validate all required keys at startup so missing configuration fails fast:

```dart
final env = Env.fromPlatform();
env.require(['DB_HOST', 'DB_PORT', 'API_KEY']);
// throws EnvMissingKeysException listing every missing key
```

### Raw Access

```dart
final env = Env({'DEBUG': 'true'});
env['DEBUG'];   // "true"
env['MISSING']; // null
```

### Quoted Values

```dart
final env = Env.fromString('MSG="hello world"\nPATH=\'/usr/bin\'');
print(env.getString('MSG'));  // hello world
print(env.getString('PATH')); // /usr/bin
```

Double-quoted values decode escape sequences (`\n`, `\t`, `\r`, `\\`, `\"`). Single-quoted values stay literal.

### Shell-Style `export`

`export KEY=value` lines (so the same file can be sourced from bash) are parsed as `KEY=value`:

```dart
final env = Env.fromString('export PORT=8080');
env.getInt('PORT'); // 8080
```

## API

| Method | Description |
|--------|-------------|
| `Env(Map<String, String> values)` | Create an Env from a pre-parsed map |
| `Env.fromMap(Map<String, String> values)` | Named constructor — alias for Env() |
| `Env.fromString(String content)` | Parse a `.env` file content string |
| `Env.fromPlatform()` | Load all variables from the process environment |
| `Env.fromFile(String path)` | Load and parse a `.env` file from disk |
| `getString(String key, {String? defaultValue})` | Get a string value |
| `getInt(String key, {int? defaultValue})` | Get an integer value |
| `getBool(String key, {bool? defaultValue})` | Get a boolean (`true`/`1`/`yes`/`on`) |
| `getDouble(String key, {double? defaultValue})` | Get a double value |
| `getList(String key, {String separator, List<String>? defaultValue})` | Get a list by splitting on separator |
| `getUri(String key, {Uri? defaultValue})` | Get a parsed URI value |
| `getEnum<T>(String key, List<T> values, {T? defaultValue})` | Get an enum value (case-insensitive match) |
| `getDateTime(String key, {DateTime? defaultValue})` | Get an ISO 8601 / RFC 3339 timestamp |
| `getDuration(String key, {Duration? defaultValue})` | Get a duration with `ms`/`s`/`m`/`h`/`d` suffix (bare integer = ms) |
| `operator [](String key)` | Raw nullable value access |
| `has(String key)` | Check if a key exists |
| `require(Iterable<String> keys)` | Throw if any required key is missing (lists all missing) |
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
