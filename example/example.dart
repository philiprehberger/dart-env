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
}
