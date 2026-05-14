import 'package:philiprehberger_env/philiprehberger_env.dart';

void main() {
  final content = '''
# Database config
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DEBUG=true
TAGS=web,api,auth
BASE_URL=http://\${DB_HOST}:\${DB_PORT}
''';

  final env = Env.fromString(content);

  print(env.getString('DB_HOST'));              // localhost
  print(env.getInt('DB_PORT'));                 // 5432
  print(env.getBool('DEBUG'));                  // true
  print(env.getList('TAGS'));                   // [web, api, auth]
  print(env.getString('BASE_URL'));             // http://localhost:5432
  print(env.has('MISSING'));                    // false
  print(env.getString('MISSING', defaultValue: 'n/a')); // n/a

  // Date and duration values.
  final timings = Env.fromString('DEPLOYED_AT=2026-05-13T22:30:00Z\nTIMEOUT=30s\nTTL=2h');
  print(timings.getDateTime('DEPLOYED_AT')); // 2026-05-13 22:30:00.000Z
  print(timings.getDuration('TIMEOUT'));     // 0:00:30.000000
  print(timings.getDuration('TTL'));         // 2:00:00.000000

  // Raw access (returns null when missing).
  print(env['MISSING']);                        // null

  // Validate required keys at startup.
  env.require(['DB_HOST', 'DB_PORT']);          // ok — both present

  // toString hides values.
  print(env);                                    // Env(6 keys)
}
