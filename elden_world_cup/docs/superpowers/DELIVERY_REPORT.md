# Elden Album — Delivery Report

This file tracks what is implemented vs. what depends on assets/decisions from
the project owner.

## Status: v1 implemented end-to-end ✅

- **25 tests passing** (`flutter test`), **`flutter analyze` clean** (no issues).
- **App builds**: `flutter build apk --debug` succeeds.
- All 15 plan tasks complete. Album → bottom sheet → map flow works, progress
  persists locally, reveal animation and map spoiler lock/unlock implemented.

## Placeholders in use (work now, swap later)
- **Boss art:** all 14 bosses render `assets/images/malenia.webp` as a
  placeholder. Replace per boss by dropping the file in `assets/images/` and
  updating `art` in `assets/bosses.json`. (Every `Image.asset` has a graceful
  fallback, so missing files never crash.)
- **Base map image:** `assets/images/map/base_map.webp` is a low-res (600×563)
  placeholder. It works, but: (1) low resolution → blurry when zoomed in the
  fullscreen InteractiveViewer; (2) it has printed item markers that compete
  with our own pins; (3) labels are in French. Replace later with a clean,
  high-res (2000px+) map without printed markers.
- **Loot icons:** none provided; the loot carousel shows the 💎 emoji as a
  fallback. Add icons in `assets/images/loot/` and set `loot[].icon` paths.
- **Map coordinates:** every boss has a *placeholder* `mapCoord (x,y)` — pins
  are positioned, but not at the real in-game location yet.

## Content I authored (please review for accuracy)
The `assets/bosses.json` was filled with **14 real, recognizable bosses** across
7 regions (Limgrave, Liurnia, Caelid, Altus, Cumes dos Gigantes, Haligtree,
Leyndell). Names, regions, epithets and strong-vs/weak-to are reasonably
faithful, but **please review**:
- **Lore** is short and paraphrased — expand/correct to taste.
- **Loot item names** may not be the exact in-game item names.
- **strong-vs / weak-to** are approximations of the resistance/weakness system.
- **Map coordinates** are placeholders (see above).

## What I need from you (to reach 100%)

### Assets
- [ ] **Boss art (portrait ~3:4)** per boss → `assets/images/`, set `art` in
      `assets/bosses.json`.
- [ ] **Clean high-res base map** → replace `assets/images/map/base_map.webp`.
- [ ] **Loot icons** (optional) → `assets/images/loot/`, set `loot[].icon`.

### Content curation (`assets/bosses.json`)
- [ ] Review/correct lore, loot names, and strong-vs/weak-to.
- [ ] Set real **mapCoord (x,y)** per boss using the dev coordinate picker
      (`lib/dev/coord_picker_screen.dart` — set `home: const CoordPickerScreen()`
      in `main.dart` temporarily, tap the map, copy the printed snippet).
- [ ] Add the remaining bosses to grow from 14 toward the full roster.

### Decisions / legal
- [ ] Confirm licensing approach for boss art, map image, and lore (fan project
      vs. original art). See the design spec's risk note.

### Environment
- [ ] `flutter run` could not be executed here (no device/emulator connected).
      Run it once on a device/emulator to confirm the live flow. The debug APK
      builds successfully, so this is a confirmation step, not a fix.

## How to run
```bash
flutter pub get
flutter run            # with a device/emulator connected
flutter test           # 25 tests
flutter analyze        # clean
```
