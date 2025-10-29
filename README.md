# ExamPro – Native-feel Mobile App

Store-ready Flutter app for exam practice (Android & iOS) with clean architecture, offline cache, DI, secure auth, accessibility, and production-ready UX.

## Run

- Flutter: 3.35.x, Dart 3.9.x
- Windows devs: Enable Developer Mode (needed for Flutter plugin symlinks)

Steps:
- Copy `assets/env/vc.env.example` to `assets/env/vc.env` and adjust values.
- `flutter pub get`
- `flutter run` (choose Android/iOS device)

## Config (vc.env)

- `API_BASE_URL` – backend base URL
- `ENVIRONMENT` – development|staging|production
- `ANALYTICS_ENABLED` – true|false
- `FEATURE_LEADERBOARD` – true|false
- `JWT_AUDIENCE`, `JWT_ISSUER` – token validation context

In CI, replace `assets/env/vc.env` per-flavor before build.

## Architecture

- Feature modules: `features/{onboarding,auth,dashboard,catalog,exam,admin}`
- State mgmt: Riverpod
- Networking: Dio (+ auth interceptor, JWT)
- Storage: SecureStorage (tokens) + Drift/SQLite (offline cache)
- Routing: go_router with soft transitions
- Theming: Light/Dark, WCAG-aware colors
- A11y: Dynamic type, semantics, focusable controls
- i18n: Flutter localizations wired; ready for locales
- Telemetry: pluggable analytics (console default)

## Key Commands

- Format: `flutter format .`
- Analyze: `flutter analyze`
- Tests: `flutter test --update-goldens`

## API Contract

See `docs/api_contract.md` for REST endpoints used by the app (Auth, Catalog, Exams, Attempts, Analytics). The app ships with API mocks you can swap in development.

Switch API to mock (local dev):
- In `lib/features/auth/data/auth_api.dart` and `lib/features/catalog/data/catalog_api.dart`, swap `...Impl(dio)` with `...Mock()`.

Security: Access + refresh JWTs stored via secure storage. Interceptor adds `Authorization: Bearer ...`. Refresh flow is stubbed; implement `/auth/refresh` on the backend and wire `TokenStore.tryRefresh()`.
