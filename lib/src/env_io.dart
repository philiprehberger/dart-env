import 'dart:io' show File, Platform;

import 'env.dart';

/// Creates an [Env] from the current process environment variables.
Env envFromPlatform() => Env(Platform.environment);

/// Reads a `.env` file synchronously and parses it into an [Env].
Env envFromFile(String path) => Env.fromString(File(path).readAsStringSync());
