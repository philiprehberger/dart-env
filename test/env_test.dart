import 'dart:io';

import 'package:philiprehberger_env/philiprehberger_env.dart';
import 'package:test/test.dart';

void main() {
  group('Env', () {
    final env = Env.fromString('HOST=localhost\nPORT=8080\nDEBUG=true\nTAGS=a,b,c');

    test('getString returns value', () {
      expect(env.getString('HOST'), equals('localhost'));
    });

    test('getString returns default for missing key', () {
      expect(env.getString('MISSING', defaultValue: 'n/a'), equals('n/a'));
    });

    test('getString throws for missing key without default', () {
      expect(() => env.getString('MISSING'), throwsA(isA<EnvMissingKeyException>()));
    });

    test('getInt parses integer', () {
      expect(env.getInt('PORT'), equals(8080));
    });

    test('getInt returns default for missing key', () {
      expect(env.getInt('MISSING', defaultValue: 3000), equals(3000));
    });

    test('getBool parses true', () {
      expect(env.getBool('DEBUG'), isTrue);
    });

    test('getBool returns default for missing key', () {
      expect(env.getBool('MISSING', defaultValue: false), isFalse);
    });

    test('getList splits on comma', () {
      expect(env.getList('TAGS'), equals(['a', 'b', 'c']));
    });

    test('has returns true for existing key', () {
      expect(env.has('HOST'), isTrue);
    });

    test('has returns false for missing key', () {
      expect(env.has('MISSING'), isFalse);
    });

    test('toMap returns all values', () {
      final map = env.toMap();
      expect(map.length, equals(4));
    });

    group('getDouble', () {
      test('parses valid double', () {
        final env = Env({'RATE': '3.14'});
        expect(env.getDouble('RATE'), equals(3.14));
      });

      test('parses integer as double', () {
        final env = Env({'COUNT': '42'});
        expect(env.getDouble('COUNT'), equals(42.0));
      });

      test('returns default when key missing', () {
        final env = Env({});
        expect(env.getDouble('RATE', defaultValue: 1.0), equals(1.0));
      });

      test('throws EnvMissingKeyException when key missing and no default', () {
        final env = Env({});
        expect(() => env.getDouble('RATE'), throwsA(isA<EnvMissingKeyException>()));
      });

      test('throws EnvParseException for non-numeric value', () {
        final env = Env({'RATE': 'abc'});
        expect(() => env.getDouble('RATE'), throwsA(isA<EnvParseException>()));
      });
    });

    group('getUri', () {
      test('parses valid URI', () {
        final env = Env({'URL': 'https://example.com/path'});
        final uri = env.getUri('URL');
        expect(uri.scheme, equals('https'));
        expect(uri.host, equals('example.com'));
      });

      test('returns default when key missing', () {
        final fallback = Uri.parse('http://localhost');
        final env = Env({});
        expect(env.getUri('URL', defaultValue: fallback), equals(fallback));
      });

      test('throws EnvMissingKeyException when key missing and no default', () {
        final env = Env({});
        expect(() => env.getUri('URL'), throwsA(isA<EnvMissingKeyException>()));
      });
    });

    group('merge', () {
      test('combines keys from both instances', () {
        final a = Env({'A': '1'});
        final b = Env({'B': '2'});
        final merged = a.merge(b);
        expect(merged.getString('A'), equals('1'));
        expect(merged.getString('B'), equals('2'));
      });

      test('later values override earlier ones', () {
        final a = Env({'KEY': 'old'});
        final b = Env({'KEY': 'new'});
        final merged = a.merge(b);
        expect(merged.getString('KEY'), equals('new'));
      });

      test('original instances are unchanged', () {
        final a = Env({'A': '1'});
        final b = Env({'B': '2'});
        a.merge(b);
        expect(a.has('B'), isFalse);
        expect(b.has('A'), isFalse);
      });
    });

    group('keys', () {
      test('returns all keys', () {
        final env = Env({'A': '1', 'B': '2', 'C': '3'});
        expect(env.keys, containsAll(['A', 'B', 'C']));
        expect(env.keys.length, equals(3));
      });

      test('empty env returns empty iterable', () {
        final env = Env({});
        expect(env.keys, isEmpty);
      });
    });

    group('fromMap', () {
      test('creates env from map', () {
        final env = Env.fromMap({'KEY': 'value'});
        expect(env.getString('KEY'), equals('value'));
      });
    });

    group('fromPlatform', () {
      test('loads process environment variables', () {
        final env = Env.fromPlatform();
        // PATH is available on all platforms
        expect(env.has('PATH'), isTrue);
        expect(env.getString('PATH'), isNotEmpty);
      });

      test('returns typed values from platform env', () {
        final env = Env.fromPlatform();
        final keys = env.keys;
        expect(keys, isNotEmpty);
      });
    });

    group('fromFile', () {
      test('loads values from a file on disk', () {
        final file = File('${Directory.systemTemp.path}/dart-env-test-${DateTime.now().microsecondsSinceEpoch}.env');
        file.writeAsStringSync('A=1\nB=two\n');
        addTearDown(() {
          if (file.existsSync()) file.deleteSync();
        });

        final env = Env.fromFile(file.path);
        expect(env.getInt('A'), equals(1));
        expect(env.getString('B'), equals('two'));
      });

      test('throws FileSystemException for missing file', () {
        expect(
          () => Env.fromFile('${Directory.systemTemp.path}/does-not-exist-${DateTime.now().microsecondsSinceEpoch}.env'),
          throwsA(isA<FileSystemException>()),
        );
      });
    });

    group('operator []', () {
      test('returns value for existing key', () {
        final env = Env({'KEY': 'value'});
        expect(env['KEY'], equals('value'));
      });

      test('returns null for missing key', () {
        final env = Env({'KEY': 'value'});
        expect(env['MISSING'], isNull);
      });
    });

    group('getDateTime', () {
      test('parses ISO 8601 timestamp', () {
        final env = Env({'TS': '2026-05-13T22:30:00Z'});
        expect(env.getDateTime('TS').toUtc(), equals(DateTime.utc(2026, 5, 13, 22, 30)));
      });

      test('returns default when key missing', () {
        final fallback = DateTime.utc(2026, 1, 1);
        final env = Env({});
        expect(env.getDateTime('TS', defaultValue: fallback), equals(fallback));
      });

      test('throws EnvMissingKeyException when key missing and no default', () {
        final env = Env({});
        expect(() => env.getDateTime('TS'), throwsA(isA<EnvMissingKeyException>()));
      });

      test('throws EnvParseException for unparseable value', () {
        final env = Env({'TS': 'not-a-date'});
        expect(() => env.getDateTime('TS'), throwsA(isA<EnvParseException>()));
      });
    });

    group('getDuration', () {
      test('parses ms suffix', () {
        expect(Env({'T': '500ms'}).getDuration('T'), equals(const Duration(milliseconds: 500)));
      });

      test('parses s suffix', () {
        expect(Env({'T': '30s'}).getDuration('T'), equals(const Duration(seconds: 30)));
      });

      test('parses m suffix', () {
        expect(Env({'T': '5m'}).getDuration('T'), equals(const Duration(minutes: 5)));
      });

      test('parses h suffix', () {
        expect(Env({'T': '2h'}).getDuration('T'), equals(const Duration(hours: 2)));
      });

      test('parses d suffix', () {
        expect(Env({'T': '7d'}).getDuration('T'), equals(const Duration(days: 7)));
      });

      test('bare integer is interpreted as milliseconds', () {
        expect(Env({'T': '250'}).getDuration('T'), equals(const Duration(milliseconds: 250)));
      });

      test('returns default when key missing', () {
        final env = Env({});
        expect(env.getDuration('T', defaultValue: const Duration(seconds: 1)), equals(const Duration(seconds: 1)));
      });

      test('throws EnvMissingKeyException when key missing and no default', () {
        final env = Env({});
        expect(() => env.getDuration('T'), throwsA(isA<EnvMissingKeyException>()));
      });

      test('throws EnvParseException for unrecognized format', () {
        final env = Env({'T': '10x'});
        expect(() => env.getDuration('T'), throwsA(isA<EnvParseException>()));
      });
    });

    group('require', () {
      test('does nothing when all keys present', () {
        final env = Env({'A': '1', 'B': '2'});
        expect(() => env.require(['A', 'B']), returnsNormally);
      });

      test('throws EnvMissingKeysException listing every missing key', () {
        final env = Env({'A': '1'});
        try {
          env.require(['A', 'B', 'C']);
          fail('expected EnvMissingKeysException');
        } on EnvMissingKeysException catch (e) {
          expect(e.keys, equals(['B', 'C']));
        }
      });

      test('empty list is a no-op', () {
        final env = Env({});
        expect(() => env.require(<String>[]), returnsNormally);
      });
    });

    group('toString', () {
      test('reports key count', () {
        final env = Env({'A': '1', 'B': '2'});
        expect(env.toString(), equals('Env(2 keys)'));
      });

      test('does not leak any value', () {
        final env = Env({'API_KEY': 'super-secret-token'});
        expect(env.toString(), isNot(contains('super-secret-token')));
      });
    });
  });
}
