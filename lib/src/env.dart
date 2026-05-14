import 'dotenv_parser.dart';
import 'env_io.dart';

/// A loaded environment with typed value access.
///
/// ```dart
/// final env = Env.fromString('PORT=8080\nDEBUG=true');
/// final port = env.getInt('PORT', defaultValue: 3000);
/// ```
class Env {
  final Map<String, String> _values;

  /// Create an Env from a pre-parsed map.
  Env(Map<String, String> values) : _values = Map.unmodifiable(values);

  /// Parse a `.env` file content string.
  factory Env.fromString(String content) {
    return Env(DotenvParser.parse(content));
  }

  /// Get a string value.
  String getString(String key, {String? defaultValue}) {
    final value = _values[key];
    if (value != null) return value;
    if (defaultValue != null) return defaultValue;
    throw EnvMissingKeyException(key);
  }

  /// Get an integer value.
  int getInt(String key, {int? defaultValue}) {
    final value = _values[key];
    if (value != null) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      throw EnvParseException(key, value, 'int');
    }
    if (defaultValue != null) return defaultValue;
    throw EnvMissingKeyException(key);
  }

  /// Get a boolean value.
  ///
  /// Truthy: `true`, `1`, `yes`, `on`
  /// Falsy: `false`, `0`, `no`, `off`
  bool getBool(String key, {bool? defaultValue}) {
    final value = _values[key]?.toLowerCase();
    if (value != null) {
      if ({'true', '1', 'yes', 'on'}.contains(value)) return true;
      if ({'false', '0', 'no', 'off'}.contains(value)) return false;
      throw EnvParseException(key, value, 'bool');
    }
    if (defaultValue != null) return defaultValue;
    throw EnvMissingKeyException(key);
  }

  /// Get a list by splitting a value on [separator].
  List<String> getList(String key, {String separator = ',', List<String>? defaultValue}) {
    final value = _values[key];
    if (value != null) {
      return value.split(separator).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    if (defaultValue != null) return defaultValue;
    throw EnvMissingKeyException(key);
  }

  /// Check if a key exists.
  bool has(String key) => _values.containsKey(key);

  /// Returns the value for [key] parsed as a double.
  ///
  /// Throws [EnvMissingKeyException] if [key] is not found and no
  /// [defaultValue] is provided.
  /// Throws [EnvParseException] if the value cannot be parsed as a double.
  double getDouble(String key, {double? defaultValue}) {
    final raw = _values[key];
    if (raw == null) {
      if (defaultValue != null) return defaultValue;
      throw EnvMissingKeyException(key);
    }
    final parsed = double.tryParse(raw);
    if (parsed == null) {
      throw EnvParseException(key, raw, 'double');
    }
    return parsed;
  }

  /// Returns the value for [key] parsed as a [Uri].
  ///
  /// Throws [EnvMissingKeyException] if [key] is not found and no
  /// [defaultValue] is provided.
  /// Throws [EnvParseException] if the value cannot be parsed as a URI.
  Uri getUri(String key, {Uri? defaultValue}) {
    final raw = _values[key];
    if (raw == null) {
      if (defaultValue != null) return defaultValue;
      throw EnvMissingKeyException(key);
    }
    final parsed = Uri.tryParse(raw);
    if (parsed == null) {
      throw EnvParseException(key, raw, 'Uri');
    }
    return parsed;
  }

  /// Returns a new [Env] combining this instance with [other].
  ///
  /// Values from [other] override values from this instance when keys overlap.
  Env merge(Env other) {
    return Env({...toMap(), ...other.toMap()});
  }

  /// Returns the value for [key] parsed as an enum value from [values].
  ///
  /// Matching is case-insensitive against the enum name.
  ///
  /// ```dart
  /// enum LogLevel { debug, info, warn, error }
  /// final level = env.getEnum('LOG_LEVEL', LogLevel.values);
  /// ```
  ///
  /// Throws [EnvMissingKeyException] if [key] is not found and no
  /// [defaultValue] is provided.
  /// Throws [EnvParseException] if the value does not match any enum name.
  T getEnum<T extends Enum>(String key, List<T> values, {T? defaultValue}) {
    final raw = _values[key];
    if (raw == null) {
      if (defaultValue != null) return defaultValue;
      throw EnvMissingKeyException(key);
    }
    final lower = raw.toLowerCase();
    for (final value in values) {
      if (value.name.toLowerCase() == lower) return value;
    }
    throw EnvParseException(key, raw, 'enum');
  }

  /// Returns all available keys.
  Iterable<String> get keys => _values.keys;

  /// Get all values as a map.
  Map<String, String> toMap() => Map.from(_values);

  /// Create an Env from a map.
  ///
  /// This is a named alternative to the default constructor for readability.
  factory Env.fromMap(Map<String, String> values) => Env(values);

  /// Create an Env from the current process environment.
  ///
  /// Loads all variables from [Platform.environment] (dart:io).
  factory Env.fromPlatform() => envFromPlatform();

  /// Read a `.env` file from [path] and parse it into an [Env].
  ///
  /// Uses synchronous file IO from `dart:io`. Throws a `FileSystemException`
  /// if the file does not exist or is not readable.
  factory Env.fromFile(String path) => envFromFile(path);

  /// Raw nullable access to a key's underlying value.
  ///
  /// Returns `null` if [key] is not set. Use the typed getters
  /// (`getString`, `getInt`, ...) when a value is expected.
  String? operator [](String key) => _values[key];

  /// Returns the value for [key] parsed as a [DateTime].
  ///
  /// Accepts any format parseable by [DateTime.tryParse] (ISO 8601 /
  /// RFC 3339 timestamps).
  ///
  /// Throws [EnvMissingKeyException] if [key] is not found and no
  /// [defaultValue] is provided.
  /// Throws [EnvParseException] if the value cannot be parsed.
  DateTime getDateTime(String key, {DateTime? defaultValue}) {
    final raw = _values[key];
    if (raw == null) {
      if (defaultValue != null) return defaultValue;
      throw EnvMissingKeyException(key);
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      throw EnvParseException(key, raw, 'DateTime');
    }
    return parsed;
  }

  /// Returns the value for [key] parsed as a [Duration].
  ///
  /// Accepts suffixed values: `ms`, `s`, `m`, `h`, `d` (e.g. `30s`, `2h`).
  /// A bare integer with no suffix is interpreted as milliseconds.
  ///
  /// Throws [EnvMissingKeyException] if [key] is not found and no
  /// [defaultValue] is provided.
  /// Throws [EnvParseException] if the value cannot be parsed.
  Duration getDuration(String key, {Duration? defaultValue}) {
    final raw = _values[key];
    if (raw == null) {
      if (defaultValue != null) return defaultValue;
      throw EnvMissingKeyException(key);
    }
    final match = RegExp(r'^(\d+)(ms|s|m|h|d)?$').firstMatch(raw.trim());
    if (match == null) {
      throw EnvParseException(key, raw, 'Duration');
    }
    final amount = int.parse(match.group(1)!);
    switch (match.group(2)) {
      case 'ms':
      case null:
        return Duration(milliseconds: amount);
      case 's':
        return Duration(seconds: amount);
      case 'm':
        return Duration(minutes: amount);
      case 'h':
        return Duration(hours: amount);
      case 'd':
        return Duration(days: amount);
    }
    throw EnvParseException(key, raw, 'Duration');
  }

  /// Validates that every key in [keys] is present.
  ///
  /// Throws [EnvMissingKeysException] listing all missing keys at once.
  /// Useful at application startup so configuration problems surface
  /// immediately rather than one at a time.
  void require(Iterable<String> keys) {
    final missing = keys.where((k) => !_values.containsKey(k)).toList();
    if (missing.isNotEmpty) {
      throw EnvMissingKeysException(missing);
    }
  }

  @override
  String toString() => 'Env(${_values.length} keys)';
}

/// Thrown when a required key is missing.
class EnvMissingKeyException implements Exception {
  /// The missing key.
  final String key;

  /// Create exception.
  EnvMissingKeyException(this.key);

  @override
  String toString() => 'EnvMissingKeyException: Key "$key" not found';
}

/// Thrown by [Env.require] when one or more required keys are missing.
class EnvMissingKeysException implements Exception {
  /// The list of missing keys.
  final List<String> keys;

  /// Create exception.
  EnvMissingKeysException(this.keys);

  @override
  String toString() =>
      'EnvMissingKeysException: Missing required keys: ${keys.join(', ')}';
}

/// Thrown when a value cannot be parsed to the expected type.
class EnvParseException implements Exception {
  /// The key.
  final String key;

  /// The raw value.
  final String value;

  /// The expected type.
  final String expectedType;

  /// Create exception.
  EnvParseException(this.key, this.value, this.expectedType);

  @override
  String toString() => 'EnvParseException: Cannot parse "$value" as $expectedType for key "$key"';
}
