# Global blur toggle for pending cards

## Problem

Pending (not-yet-defeated) boss art is blurred, which makes it hard for users
who don't memorize boss names to tell which card is which. We want a top-of-
screen toggle that turns the blur off so the art is identifiable, while still
signaling "not collected yet".

## Goal

A toggle button at the top of the album that switches blur on/off for pending
art **everywhere** it appears — album cards, the search list thumbnails, and
the boss details hero. The choice persists across sessions.

When blur is OFF, each call-site keeps its other pending effects and only
drops the blur layer:

| Call-site                         | Blur ON (today)                          | Blur OFF              |
|-----------------------------------|------------------------------------------|-----------------------|
| `sticker_slot.dart` (album)       | grayscale + blur(6) + darken(0.45)       | grayscale + darken(0.45) |
| `boss_hero.dart` (boss details)   | blur(9) + darken(0.5) (no grayscale)     | darken(0.5) (no grayscale) |
| `search_view.dart` (search thumb) | grayscale only (already no blur)         | grayscale (unchanged) |

Default is blur ON.

## Architecture

The preference crosses three screens that live on different routes, so it
cannot live in a per-screen bloc. It is a **global `SettingsBloc`** provided
once above the `Navigator` (wrapping `MaterialApp`), mirroring how
`MobileFrame` sits at the top. Album, search (pushed route), and boss (pushed
route) all read the same bloc via `BlocBuilder` / `context.watch`.

State management stays on `flutter_bloc` + `get_it` — no other mechanism.

### Domain / data (mirrors the progress feature)

- `Settings` entity — `{ bool blurPending }`, default `true`.
- `SettingsRepository` (domain interface) + `SettingsRepositoryImpl` (data),
  backed by `shared_preferences`, key `blurPending`.
- `LoadSettingsUsecase`, `SetBlurPendingUsecase`.
- All registered in `service_locator` (repository as lazy singleton, usecases
  as factories), matching the existing pattern.

### `SettingsBloc`

- `part 'settings_event.dart'` + `part 'settings_state.dart'`.
- `SettingsState extends Equatable { bool blurPending }`.
- Events:
  - `SettingsStarted` → loads via `LoadSettingsUsecase`, emits the saved value.
  - `SettingsBlurToggled` → flips `blurPending`, persists via
    `SetBlurPendingUsecase`, emits the new value.
- Provided at the top via `BlocProvider(create: (_) => SettingsBloc(...)..add(SettingsStarted()))`
  wrapping `MaterialApp` in `main.dart`.

## `PendingArt` shared widget

New file `lib/shared/widgets/pending_art.dart`. Removes today's triplicated
blur code. Because each call-site composes effects differently, `PendingArt`
does not impose one uniform look — it builds the art with the requested
effects and lets `blurPending` decide whether the **blur layer** is included.

API:

```dart
PendingArt(
  art: boss.art,           // asset path passed through to Image.asset
  blurSigma: 6,            // per call-site (album 6, boss 9)
  grayscale: true,         // album/search true, boss false
  darken: 0.45,            // album 0.45, boss 0.5, search 0 (none)
  alignment: const Alignment(0, -0.6),
)
```

Internally reads `context.watch<SettingsBloc>().state.blurPending`:
- blur ON  → applies grayscale (if set) + blur(blurSigma) + darken (if > 0).
- blur OFF → same, minus the blur layer.

Effect order matches the current `_pendingArt()` stacking (grayscale outermost,
then blur, then darken over the colored image).

Call-sites updated to use it:
- `sticker_slot.dart` `_pendingArt()` (and the reveal cross-fade's bottom layer).
- `boss_hero.dart` `_art()` pending branch.
- `search_view.dart` `_bossTile` pending thumb (grayscale-only; blur layer
  never present, so the toggle is a no-op there — included for consistency).

## Blur toggle button

`_BlurToggleButton` — same circular style as `_SearchButton`, placed to its
left inside the album's existing top-right `SafeArea`. Reads
`context.watch<SettingsBloc>().state.blurPending` for its icon
(`Icons.blur_on` ↔ `Icons.blur_off`); on tap dispatches
`SettingsBlurToggled`.

## Testing (TDD)

- `SettingsRepositoryImpl`: save then load round-trips the bool; load with no
  stored value returns default `true`. Uses `SharedPreferences.setMockInitialValues`.
- `SettingsBloc` (`bloc_test` + `mocktail`, like `album_bloc_test`):
  - `SettingsStarted` emits the loaded value.
  - `SettingsBlurToggled` flips the value and calls `SetBlurPendingUsecase`.
- `PendingArt`: with `blurPending: true` the tree contains an `ImageFiltered`;
  with `false` it contains none but still contains the expected `ColorFiltered`
  layers. Re-renders when the bloc state changes.
- `_BlurToggleButton`: tapping dispatches `SettingsBlurToggled` (verify via a
  bloc provided in the test).

## Out of scope

- No change to boss_hero's grayscale behavior (it stays non-grayscale in both
  modes; only the blur layer is toggled).
- No per-screen override — the toggle is one global preference.
- Search thumbnails already render without blur; the toggle does not visibly
  change them.
