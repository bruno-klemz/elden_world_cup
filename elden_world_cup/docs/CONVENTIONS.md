# Elden Album — Conventions

Conventions for this app, adapted from the patterns used in the team's
production Flutter app (`jus-pra-voce-app`), scaled down for a small,
single-module, offline app. The goal: stay consistent with how the team writes
Flutter, without importing monorepo/enterprise overhead we don't need.

> Source of truth for the full versions: `jus-pra-voce-app/docs/` (CLEAN_ARCHITECTURE,
> CODING_STANDARDS, TEST_WRITING, GOLDEN_TESTS, FAROL_DESIGN_SYSTEM).

## Architecture

Feature-based Clean Architecture, mirroring `jus-pra-voce-app`. Each feature is
`lib/<feature>/{data,domain,presenter}`:

- **`domain/`** — pure Dart, no Flutter deps.
  - `entity/` — immutable entities (`Boss`, `Region`, `DamageType`, `Progress`, …), using `Equatable`.
  - `repository/` — repository **interfaces** (contracts only).
  - `usecase/` — one class per operation (`abstract XUsecase` + `XUsecaseImpl`), depends on repositories.
- **`data/`** — `repository/` holds the concrete `*Impl` (the only place that imports the external dep, e.g. `shared_preferences`, `rootBundle`).
- **`presenter/<screen>/`** — `bloc/` (`*_bloc.dart` + `part` event/state), `*_screen.dart` (the **wire**: `BlocProvider` + `locator`), `*_view.dart` (pure UI consuming the bloc via `BlocBuilder`/`BlocConsumer`), `widgets/`.

Features: **album** (grid), **boss** (full-screen details), **map** (fullscreen, presenter-only). **theme** is a simple domain (`lib/theme/app_theme.dart`, shared UI, no layers). `lib/service_locator.dart` registers repositories (singletons) and use cases (factories) with `get_it`; **BLoCs are never registered** — created in the wire.

**Adopted (full fidelity to the team's pattern):**
- `flutter_bloc` for state (business logic in BLoCs, constructor-injected use cases).
- `get_it` service locator + wire/view composition root.
- Repository interface in `domain/` + impl in `data/` (dependency inversion).
- Use cases per operation.
- Adapter rule: external deps isolated in their repository impl.

**Deliberately skipped (monorepo overhead):**
- Melos / workspace packages.
- GraphQL structure — we're fully offline.

## Coding Standards (adopted)

- **File-level constants use a `k` prefix**: `const kSlotAspectRatio = 3 / 4;`.
- **File names match the primary class** (snake_case file, PascalCase class).
- **~200 line file limit.** Split widgets into their own files under `widgets/`.
  Avoid private `_Widget` classes embedded in another file — give them a file.
- **A widget either takes all data via props OR reads state via a BLoC** —
  don't mix. Leaf widgets (`StickerSlot`, `CombatSection`, `RegionSection`, …) are
  prop-driven; the `*_view.dart` files read the bloc via `BlocBuilder`/`BlocConsumer`.
- **No nested ternaries** — extract to a variable or `if`/`else`.
- **Cache repeated getters** as locals at the top of `build()`.
- **Check `mounted`** before `setState` from async callbacks.
- **Asset paths via constants**, not scattered string literals (see Assets below).
- **`spacing:` on `Column`/`Row`** instead of `SizedBox` separators where practical.

## Theming

Current approach (a static `AppColors` + `AppText`) is the right scale — no
`ThemeExtension` needed. Improvements worth making as the UI grows:

- **Add `AppSpacing` and `AppRadius`** constant classes alongside `AppColors`/`AppText`
  so spacing/radius are tokens, not magic numbers.
- **Use semantic names** (`gold`, `goldLight`, `background`) so a palette swap is
  global. (Already done.)
- **Treat typography as a contract**: define styles once in `AppText`; only
  `.copyWith(color:)` / `fontWeight` at call sites — never redefine fontSize/height.

## Testing (adopted)

- **Tests mirror source structure**: `test/<path>/<name>_test.dart`. ✅ done
- **Arrange / Act / Assert.**
- **Widget tests**: pump, find via `find.*`, assert. For long scrollable sheets,
  set `tester.view.physicalSize` larger and reset in `addTearDown` (see
  `boss_sheet_test.dart`).
- **`network_image_mock`** is the team's tool for image-loading tests — adopt if
  we add tests that depend on real image decoding. (We use `Image.asset` with
  `errorBuilder` fallbacks, so most tests don't need it.)
- **Golden tests** (`alchemist`): worth adopting later for the visual components
  (`StickerSlot`, `BossSheet`, `MapSection`) since this app is UI-heavy. Not yet
  set up — a good follow-up when the visuals stabilize.

## Assets

- Boss art + map under `assets/images/`; registered in `pubspec.yaml`.
- Every `Image.asset` MUST have an `errorBuilder` fallback (never crash on a
  missing asset — see the never-block-on-missing-assets discipline).
- Consider an `AssetPaths` constants class if asset references multiply.
