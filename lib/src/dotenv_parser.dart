/// Parses `.env` file content into a key-value map.
///
/// Supports:
/// - `KEY=value` pairs
/// - Optional shell-style `export KEY=value` prefix
/// - Single and double quoted values (escape sequences decoded in double quotes)
/// - Multi-line values inside double quotes (e.g. embedded RSA keys)
/// - `#` comments
/// - Empty lines
/// - Variable expansion with `${VAR}` and `${VAR:-default}` fallback
class DotenvParser {
  DotenvParser._();

  /// Parse a `.env` file content string into a map.
  static Map<String, String> parse(String content) {
    final result = <String, String>{};
    final rawLines = content.split('\n');
    final logicalLines = _joinMultiLineQuoted(rawLines);

    for (var line in logicalLines) {
      // Only trim leading whitespace for the key-detection path. We trim the
      // full line for empty/comment checks but preserve value internals.
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      final equalsIndex = trimmed.indexOf('=');
      if (equalsIndex < 0) continue;

      var key = trimmed.substring(0, equalsIndex).trim();
      var value = trimmed.substring(equalsIndex + 1);

      if (key.startsWith('export ')) {
        key = key.substring('export '.length).trim();
      }
      if (key.isEmpty) continue;

      // Trim only when value is not quoted; quoted values preserve internal whitespace.
      final stripped = value.trimLeft();
      final isDoubleQuoted = stripped.startsWith('"') && stripped.endsWith('"') && stripped.length >= 2;
      final isSingleQuoted = stripped.startsWith("'") && stripped.endsWith("'") && stripped.length >= 2;

      if (isDoubleQuoted) {
        value = _decodeDoubleQuoted(stripped.substring(1, stripped.length - 1));
      } else if (isSingleQuoted) {
        value = stripped.substring(1, stripped.length - 1);
      } else {
        value = value.trim();
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

  /// Joins consecutive raw lines that are part of the same logical assignment
  /// when a value is opened with `"` but not yet closed on the same line.
  ///
  /// Single-quoted multi-line values are intentionally not supported — single
  /// quotes stay literal. Use `\n` escapes inside double quotes if a single-
  /// line representation is preferred.
  static List<String> _joinMultiLineQuoted(List<String> rawLines) {
    final out = <String>[];
    var i = 0;
    while (i < rawLines.length) {
      final line = rawLines[i];
      final equalsIndex = line.indexOf('=');
      if (equalsIndex < 0) {
        out.add(line);
        i++;
        continue;
      }

      // Find the start of the value (skip leading whitespace after `=`).
      var valueStart = equalsIndex + 1;
      while (valueStart < line.length && (line[valueStart] == ' ' || line[valueStart] == '\t')) {
        valueStart++;
      }

      if (valueStart < line.length && line[valueStart] == '"' && !_hasClosingDoubleQuote(line, valueStart + 1)) {
        final buffer = StringBuffer(line);
        i++;
        while (i < rawLines.length) {
          buffer.write('\n');
          buffer.write(rawLines[i]);
          if (_hasClosingDoubleQuote(rawLines[i], 0)) {
            i++;
            break;
          }
          i++;
        }
        out.add(buffer.toString());
      } else {
        out.add(line);
        i++;
      }
    }
    return out;
  }

  /// Returns true when [line] contains an unescaped `"` at or after [start].
  static bool _hasClosingDoubleQuote(String line, int start) {
    for (var i = start; i < line.length; i++) {
      if (line[i] == r'\') {
        i++; // skip escaped char
        continue;
      }
      if (line[i] == '"') return true;
    }
    return false;
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
