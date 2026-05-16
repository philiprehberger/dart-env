import 'dart:io' show File, Platform;

import 'env.dart';

/// Creates an [Env] from the current process environment variables.
Env envFromPlatform() => Env(Platform.environment);

/// Reads a `.env` file synchronously and parses it into an [Env].
Env envFromFile(String path) => Env.fromString(File(path).readAsStringSync());

/// Reads and merges multiple `.env` files in priority order.
///
/// Later paths override earlier ones.
Env envFromFiles(List<String> paths) {
  var env = Env(const {});
  for (final path in paths) {
    env = env.merge(envFromFile(path));
  }
  return env;
}
