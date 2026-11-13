# Mobile App

## Purpose

Flutter client for Android and iOS. It authenticates a registered client, streams MML records, and stores offline playlists locally.

## Code map

- `lib/main.dart` initializes HTTP overrides, cache management, and `MMLApp`.
- `lib/views`, `lib/components`, and `lib/view_models` implement the UI and presentation state.
- `lib/services` owns backend, authentication, playback, and platform integrations.
- `lib/models` contains API/domain models; `lib/migrations` and `sqflite` support local offline data.
- `lib/manager`, `lib/util`, `lib/extensions`, `lib/l10n`, and `lib/gen` provide shared infrastructure, localization, and generated code.

## Local commands

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

Use Android or iOS device tooling for platform runs. The backend and a valid registration flow are prerequisites. Generated localization, JSON serialization, and asset files must be updated through their configured generators.

## Rules

- Keep HTTPS and client registration requirements intact; never add release behavior that accepts invalid certificates.
- Treat local database migrations and offline playlist formats as compatibility-sensitive.
- Keep API models aligned with `mml.identity`, `mml.media`, and `mml.messages` without importing server implementation code.
- Update `mml.project/docs` when setup, registration, playback, offline behavior, or customization changes.

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
