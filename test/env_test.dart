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
  });
}
