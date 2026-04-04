import 'dotenv_parser.dart';

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

  /// Get all values as a map.
  Map<String, String> toMap() => Map.from(_values);
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
