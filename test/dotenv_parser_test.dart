import 'package:philiprehberger_env/philiprehberger_env.dart';
import 'package:test/test.dart';

void main() {
  group('DotenvParser', () {
    test('parses simple key=value', () {
      final result = DotenvParser.parse('KEY=value');
      expect(result['KEY'], equals('value'));
    });

    test('handles double-quoted values', () {
      final result = DotenvParser.parse('KEY="hello world"');
      expect(result['KEY'], equals('hello world'));
    });

    test('handles single-quoted values', () {
      final result = DotenvParser.parse("KEY='hello world'");
      expect(result['KEY'], equals('hello world'));
    });

    test('ignores comments', () {
      final result = DotenvParser.parse('# comment\nKEY=value');
      expect(result.length, equals(1));
      expect(result['KEY'], equals('value'));
    });

    test('ignores empty lines', () {
      final result = DotenvParser.parse('\n\nKEY=value\n\n');
      expect(result.length, equals(1));
    });

    test('expands variables', () {
      final result = DotenvParser.parse('HOST=localhost\nURL=http://\${HOST}:8080');
      expect(result['URL'], equals('http://localhost:8080'));
    });

    test('handles multiple entries', () {
      final result = DotenvParser.parse('A=1\nB=2\nC=3');
      expect(result.length, equals(3));
    });

    test('trims whitespace around key and value', () {
      final result = DotenvParser.parse('  KEY  =  value  ');
      expect(result['KEY'], equals('value'));
    });

    group('default variable fallback', () {
      test('uses variable value when variable exists', () {
        final result = DotenvParser.parse('HOST=server\nURL=\${HOST:-localhost}');
        expect(result['URL'], equals('server'));
      });

      test('uses default when variable is missing', () {
        final result = DotenvParser.parse('URL=\${MISSING:-localhost}');
        expect(result['URL'], equals('localhost'));
      });

      test('uses default when variable is empty', () {
        final result = DotenvParser.parse('HOST=\nURL=\${HOST:-localhost}');
        expect(result['URL'], equals('localhost'));
      });

      test('default can contain spaces', () {
        final result = DotenvParser.parse('MSG=\${GREETING:-hello world}');
        expect(result['MSG'], equals('hello world'));
      });
    });
  });
}
