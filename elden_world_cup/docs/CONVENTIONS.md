# Elden Album — Conventions

Conventions for this app, adapted from the patterns used in the team's
production Flutter app (`jus-pra-voce-app`), scaled down for a small,
single-module, offline app. The goal: stay consistent with how the team writes
Flutter, without importing monorepo/enterprise overhead we don't need.

> Source of truth for the full versions: `jus-pra-voce-app/docs/` (CLEAN_ARCHITECTURE,
> CODING_STANDARDS, TEST_WRITING, GOLDEN_TESTS, FAROL_DESIGN_SYSTEM).

## Architecture

We already follow a layered structure. Keep it:

- **`domain/`** — pure Dart, no Flutter framework deps in the core logic.
  - `models/` — immutable entities (`Boss`, `Region`, `DamageType`, …).
  - `progress.dart` — value object + pure transitions.
- **`data/`** — data access. `boss_repository.dart` (parse asset), `progress_store.dart` (persistence).
- **`presentation/`** — UI: screens + widgets, grouped by feature (`album/`, `boss/`, `map/`).
- **`state/`** — `AlbumController` (`ChangeNotifier`) is our state holder.

**Adopted from their Clean Architecture (scaled down):**
- Repository pattern (single source of truth, easy to mock). ✅ done
- Separation of layers with the dependency rule (UI → state → data → domain). ✅ done
- Adapter rule: any external dependency (SDK/plugin) is wrapped, and that wrapper
  is the only file importing it. (We currently only use `shared_preferences`,
  isolated in `progress_store.dart` — keep new deps similarly isolated.)

**Deliberately skipped (overkill for this app):**
- Melos monorepo / workspace packages.
- `get_it` service locator + `PresenterWire`/`Presenter` composition root —
  `provider` + a single `ChangeNotifier` is enough at this size. Revisit if the
  app grows multiple independent features.
- Use-case classes per operation — our logic is small; methods on the controller
  + the `Progress` value object cover it. Introduce use cases if logic grows.
- GraphQL structure — we're fully offline.

## Coding Standards (adopted)

- **File-level constants use a `k` prefix**: `const kSlotAspectRatio = 3 / 4;`.
- **File names match the primary class** (snake_case file, PascalCase class).
- **~200 line file limit.** Split widgets into their own files under `widgets/`.
  Avoid private `_Widget` classes embedded in another file — give them a file.
- **A widget either takes all data via props OR reads state via the controller** —
  don't mix. Our leaf widgets (`StickerSlot`, `CombatSection`, …) are prop-driven;
  `AlbumScreen`/`BossSheet` read the controller.
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
