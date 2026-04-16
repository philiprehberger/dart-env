# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-04-17

### Added
- `Env.fromPlatform()` factory to load variables from the process environment
- `Env.fromMap()` named constructor as a readable alias for the default constructor

## [0.3.0] - 2026-04-05

### Added
- `getEnum<T>()` for parsing environment values as enum variants with case-insensitive matching

## [0.2.0] - 2026-04-04

### Added
- `getDouble()` for parsing floating-point environment values
- `getUri()` for parsing URI environment values
- `merge()` for combining multiple Env instances with override semantics
- `keys` getter to retrieve all available environment variable names
- Default variable fallback syntax `${VAR:-default}` in dotenv parsing

## [0.1.0] - 2026-04-03

### Added
- Initial release
- Dotenv file parser with key=value pairs, quoted values, comments, and empty lines
- Variable expansion with `${VAR}` syntax
- Typed getters: `getString`, `getInt`, `getBool`, `getList`
- Default value support for all getters
- `EnvMissingKeyException` and `EnvParseException` for error handling
