/// Parses `.env` file content into a key-value map.
///
/// Supports:
/// - `KEY=value` pairs
/// - Single and double quoted values
/// - `#` comments
/// - Empty lines
/// - Variable expansion with `${VAR}`
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

      final key = line.substring(0, equalsIndex).trim();
      var value = line.substring(equalsIndex + 1).trim();

      // Remove quotes
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }

      // Inline comment (only for unquoted values)
      if (!line.substring(equalsIndex + 1).trim().startsWith('"') &&
          !line.substring(equalsIndex + 1).trim().startsWith("'")) {
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

  static String _expand(String value, Map<String, String> vars) {
    return value.replaceAllMapped(RegExp(r'\$\{(\w+)\}'), (match) {
      final varName = match.group(1)!;
      return vars[varName] ?? '';
    });
  }
}
