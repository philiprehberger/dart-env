/// Parses `.env` file content into a key-value map.
///
/// Supports:
/// - `KEY=value` pairs
/// - Optional shell-style `export KEY=value` prefix
/// - Single and double quoted values (escape sequences decoded in double quotes)
/// - `#` comments
/// - Empty lines
/// - Variable expansion with `${VAR}` and `${VAR:-default}` fallback
class DotenvParser {
  DotenvParser._();

  /// Parse a `.env` file content string into a map.
  static Map<String, String> parse(String content) {
    final result = <String, String>{};
    final lines = content.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final equalsIndex = line.indexOf('=');
      if (equalsIndex < 0) continue;

      var key = line.substring(0, equalsIndex).trim();
      var value = line.substring(equalsIndex + 1).trim();

      if (key.startsWith('export ')) {
        key = key.substring('export '.length).trim();
      }
      if (key.isEmpty) continue;

      // Quoted values: strip quotes; decode escape sequences inside double quotes.
      final isDoubleQuoted = value.startsWith('"') && value.endsWith('"') && value.length >= 2;
      final isSingleQuoted = value.startsWith("'") && value.endsWith("'") && value.length >= 2;

      if (isDoubleQuoted) {
        value = _decodeDoubleQuoted(value.substring(1, value.length - 1));
      } else if (isSingleQuoted) {
        value = value.substring(1, value.length - 1);
      } else {
        // Inline comment (only for unquoted values).
        final commentIndex = value.indexOf(' #');
        if (commentIndex >= 0) {
          value = value.substring(0, commentIndex).trim();
        }
      }

      result[key] = value;
    }

    // Variable expansion
    final expanded = <String, String>{};
    for (final entry in result.entries) {
      expanded[entry.key] = _expand(entry.value, result);
    }

    return expanded;
  }

  static String _decodeDoubleQuoted(String value) {
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final char = value[i];
      if (char == r'\' && i + 1 < value.length) {
        final next = value[i + 1];
        switch (next) {
          case 'n':
            buffer.write('\n');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case r'\':
            buffer.write(r'\');
            break;
          case '"':
            buffer.write('"');
            break;
          default:
            buffer.write(char);
            buffer.write(next);
        }
        i++;
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  static String _expand(String value, Map<String, String> vars) {
    return value.replaceAllMapped(RegExp(r'\$\{(\w+)(?::-(.*?))?\}'), (match) {
      final varName = match.group(1)!;
      final defaultValue = match.group(2);
      final resolved = vars[varName];
      if (resolved != null && resolved.isNotEmpty) return resolved;
      if (defaultValue != null) return defaultValue;
      return '';
    });
  }
}
