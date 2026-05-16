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

    group('export prefix', () {
      test('strips leading export from key', () {
        final result = DotenvParser.parse('export KEY=value');
        expect(result['KEY'], equals('value'));
        expect(result.containsKey('export KEY'), isFalse);
      });

      test('mixes export and non-export lines', () {
        final result = DotenvParser.parse('export A=1\nB=2');
        expect(result, equals({'A': '1', 'B': '2'}));
      });
    });

    group('escape sequences in double-quoted values', () {
      test('decodes \\n as newline', () {
        final result = DotenvParser.parse('KEY="line one\\nline two"');
        expect(result['KEY'], equals('line one\nline two'));
      });

      test('decodes \\t as tab', () {
        final result = DotenvParser.parse('KEY="a\\tb"');
        expect(result['KEY'], equals('a\tb'));
      });

      test('decodes \\\\ as backslash', () {
        final result = DotenvParser.parse(r'KEY="a\\b"');
        expect(result['KEY'], equals(r'a\b'));
      });

      test('decodes \\" as quote', () {
        final result = DotenvParser.parse('KEY="say \\"hi\\""');
        expect(result['KEY'], equals('say "hi"'));
      });

      test('single-quoted values stay literal', () {
        final result = DotenvParser.parse(r"KEY='line\nbreak'");
        expect(result['KEY'], equals(r'line\nbreak'));
      });
    });

    group('multi-line double-quoted values', () {
      test('joins value spanning multiple lines', () {
        final content = 'KEY="line one\nline two\nline three"';
        final result = DotenvParser.parse(content);
        expect(result['KEY'], equals('line one\nline two\nline three'));
      });

      test('preserves RSA-key style content', () {
        final content = 'PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEA\n-----END RSA PRIVATE KEY-----"\nOTHER=ok';
        final result = DotenvParser.parse(content);
        expect(result['PRIVATE_KEY'], contains('BEGIN RSA PRIVATE KEY'));
        expect(result['PRIVATE_KEY'], contains('MIIEowIBAAKCAQEA'));
        expect(result['PRIVATE_KEY'], contains('END RSA PRIVATE KEY'));
        expect(result['OTHER'], equals('ok'));
      });

      test('escape sequences still decode inside multi-line value', () {
        final content = 'KEY="part one\nwith \\t tab"';
        final result = DotenvParser.parse(content);
        expect(result['KEY'], equals('part one\nwith \t tab'));
      });

      test('single-line double-quoted value still works after refactor', () {
        final result = DotenvParser.parse('A=1\nKEY="hello"\nB=2');
        expect(result['KEY'], equals('hello'));
        expect(result['A'], equals('1'));
        expect(result['B'], equals('2'));
      });
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
