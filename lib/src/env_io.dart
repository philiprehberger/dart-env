import 'dart:io' show Platform;

import 'env.dart';

/// Creates an [Env] from the current process environment variables.
Env envFromPlatform() => Env(Platform.environment);
