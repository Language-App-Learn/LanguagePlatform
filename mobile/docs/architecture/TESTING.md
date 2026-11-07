# Testing

```
cd mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug      # Android; iOS needs macOS and Xcode
```

## Layout

- `test/core/`: storage (guarded store, corruption, versions, restart), design system, foundation, architecture (failure model, ApiClient fake, validators, multilingual content, navigation resilience).
- `test/features/`: domain logic, scheduler and review queue, learning flows, auth and profile, persistence flows (cold start, restart, reset, flashcards), RTL smoke test (14 screens x 3 languages x light/dark at 360x640).
- `test/helpers/`: `pumpApp` (overrides language, theme, route), `launchApp` (real wiring over a given store, used to simulate restarts), `useScreen`, fixed clock and preference fixtures.
- `test/fakes/`: `ControllableStore` (delayed or failing writes), `FakeApiClient` (scripted responses).

## Conventions

- Deterministic: inject `clockProvider`; no real time, network, or shared global state.
- Simulate a restart by launching a new `ProviderScope` over the same `KeyValueStore`.
- Assert user-visible behaviour through keys (`ValueKey('<group>:<id>')`) rather than layout.
- Isolated LTR text (`isolateLtr`) wraps percentages and levels; match with `'80%'.isolateLtr`.
