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
