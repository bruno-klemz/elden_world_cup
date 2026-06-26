# Elden Album Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an offline Flutter (iOS + Android) sticker-album of Elden Ring bosses: an album grid sectioned by region, a collapsing bottom sheet guide (map / combat / loot / lore), and an own offline interactive map with per-boss pins.

**Architecture:** Single offline app, no backend. Boss content lives in `assets/bosses.json` + images in `assets/images/`. User progress (defeated bosses, revealed maps) lives in `shared_preferences`. Three layers: `data/` (JSON parse + persistence), `domain/` (immutable models + progress logic), `presentation/` (screens + widgets). State is held by a single `ChangeNotifier` (`AlbumController`) exposed via `provider`, so widgets rebuild when progress changes.

**Tech Stack:** Flutter 3.38.x / Dart SDK ^3.10.1 · `shared_preferences` (persistence) · `provider` (state) · built-in `InteractiveViewer` (map zoom/pan) · `flutter_test` (tests).

## Global Constraints

- **Flutter 3.38.x, Dart SDK `^3.10.1`** (already pinned in `pubspec.yaml`).
- **100% offline.** No network calls, no backend, no external map. All content embedded in assets.
- **Never block on missing assets.** When a real asset is missing (boss art, base map image, loot icons, coordinates, lore), use a placeholder (the existing Malenia art `assets/images/malenia.webp`, or a generic asset) and record the gap in the delivery report (`docs/superpowers/DELIVERY_REPORT.md`). Structure data so swapping a placeholder for the final asset is just a file + JSON path change — never a code change.
- **Art format rule:** boss art is portrait (~3:4), `BoxFit.cover`. No distortion.
- **No lock icon on album slots.** Pending = blurred B&W art + name only. The reveal animation (light/glow) communicates unlocking.
- **Copy in PT-BR** for all user-facing strings (matches the brainstorm mockups).
- **Map is own/offline.** Never embed Fextralife or any external service.

---

## File Structure

**Models & domain (`lib/domain/`)**
- `models/damage_type.dart` — `DamageType` enum (label PT-BR, icon asset/emoji, color).
- `models/loot_item.dart` — `LootItem` (name, icon path).
- `models/map_coord.dart` — `MapCoord` (relative x, y in 0..1).
- `models/region.dart` — `Region` (id, name, order).
- `models/boss.dart` — `Boss` (all fields; immutable; `fromJson`).
- `models/album_data.dart` — `AlbumData` (regions + bosses, with helpers like `bossesByRegion`).
- `progress.dart` — `Progress` value object (defeated set, revealedMap set) + pure transition methods.

**Data (`lib/data/`)**
- `boss_repository.dart` — loads & parses `assets/bosses.json` → `AlbumData`.
- `progress_store.dart` — reads/writes `Progress` to `shared_preferences`.

**State (`lib/state/`)**
- `album_controller.dart` — `ChangeNotifier` holding `AlbumData` + `Progress`; exposes queries (counts, isDefeated, isMapRevealed) and commands (toggleDefeated, revealMap, hideMap).

**Presentation (`lib/presentation/`)**
- `album/album_screen.dart` — the album (CustomScrollView, header + region sections).
- `album/widgets/progress_header.dart` — overall progress bar.
- `album/widgets/region_section.dart` — region header + grid.
- `album/widgets/sticker_slot.dart` — single slot (defeated colored vs pending blurred).
- `boss/boss_sheet.dart` — the bottom sheet (CustomScrollView + SliverAppBar).
- `boss/widgets/boss_hero.dart` — collapsing hero art (blurred when pending).
- `boss/widgets/combat_section.dart` — Strong VS / Weak To columns.
- `boss/widgets/loot_section.dart` — horizontal loot carousel.
- `boss/widgets/map_section.dart` — map preview with spoiler lock/unlock.
- `boss/widgets/reveal_overlay.dart` — the light/glow reveal animation.
- `map/fullscreen_map.dart` — InteractiveViewer over the base map with pins.
- `theme/app_theme.dart` — colors, text styles (dark gold/parchment palette).

**Assets**
- `assets/bosses.json`
- `assets/images/` (boss art; `malenia.webp` is the seed placeholder)
- `assets/images/map/base_map.webp` (base map — placeholder until delivered)
- `assets/images/loot/` (loot icons — placeholders until delivered)

**Dev-only tool (`lib/dev/`)**
- `coord_picker_screen.dart` — tap the base map to print the relative (x,y). Not wired into the shipped app.

**Tests (`test/`)** mirror the `lib/` structure.

---

## Task 1: Project setup — dependencies, theme, asset registration

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/presentation/theme/app_theme.dart`
- Create: `assets/images/.gitkeep`, `assets/images/map/.gitkeep`, `assets/images/loot/.gitkeep`
- Create: `docs/superpowers/DELIVERY_REPORT.md`

**Interfaces:**
- Produces: `AppColors` (static `Color` consts: `background = #15100C`, `surface = #1A1410`, `gold = #D4AF37`, `goldLight = #F0D98A`, `border = #3A2F22`, `textMuted = #8A7A5C`, `textBody = #A89876`), `AppText` (static `TextStyle` getters: `title`, `regionLabel`, `sectionLabel`, `lore`, `slotName`). Used by every presentation file.

- [ ] **Step 1: Add dependencies**

Edit `pubspec.yaml` `dependencies:` to add `shared_preferences` and `provider`, and register assets:

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.3.0
  provider: ^6.1.2

flutter:
  uses-material-design: true
  assets:
    - assets/bosses.json
    - assets/images/
    - assets/images/map/
    - assets/images/loot/
```

- [ ] **Step 2: Install and verify**

Run: `flutter pub get`
Expected: "Got dependencies!" with no version-solving errors.

- [ ] **Step 3: Move the seed placeholder art into assets**

The brainstorm captured a placeholder Malenia art. Copy it in (it is the seed placeholder used everywhere until real art arrives):

Run: `mkdir -p assets/images/map assets/images/loot && cp .superpowers/brainstorm/*/content/malenia.webp assets/images/malenia.webp 2>/dev/null && touch assets/images/.gitkeep assets/images/map/.gitkeep assets/images/loot/.gitkeep && ls assets/images/`
Expected: lists `malenia.webp` and `.gitkeep`. (If the brainstorm file is gone, create `assets/images/malenia.webp` from any portrait image and note it in the delivery report.)

- [ ] **Step 4: Create the theme**

Create `lib/presentation/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF15100C);
  static const surface = Color(0xFF1A1410);
  static const surfaceAlt = Color(0xFF221A12);
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF0D98A);
  static const border = Color(0xFF3A2F22);
  static const textMuted = Color(0xFF8A7A5C);
  static const textBody = Color(0xFFA89876);
  static const strong = Color(0xFF7FB38A);
  static const weak = Color(0xFFCF8A6A);
}

class AppText {
  static const title = TextStyle(
      color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w800);
  static const regionLabel = TextStyle(
      color: Color(0xFFC9B78F), fontSize: 13, fontWeight: FontWeight.w700,
      letterSpacing: 1, height: 1);
  static const sectionLabel = TextStyle(
      color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800,
      letterSpacing: 1.2);
  static const lore = TextStyle(
      color: AppColors.textBody, fontSize: 13, height: 1.65);
  static const slotName = TextStyle(
      color: AppColors.goldLight, fontSize: 9, fontWeight: FontWeight.w800,
      letterSpacing: .3);
}
```

- [ ] **Step 5: Create the delivery report skeleton**

Create `docs/superpowers/DELIVERY_REPORT.md`:

```markdown
# Elden Album — Delivery Report

This file tracks what is implemented vs. what depends on assets/decisions from
the project owner. Updated as tasks complete.

## Placeholders in use (need real assets)
- **Boss art:** all bosses currently render `assets/images/malenia.webp` as a
  placeholder except where real art is provided. Replace per boss by dropping
  the file in `assets/images/` and updating `art` in `assets/bosses.json`.
- **Base map image:** `assets/images/map/base_map.webp` is a placeholder.
- **Loot icons:** `assets/images/loot/*` are placeholders (emoji fallback).

## What I need from you
(See the final section of this report — kept current as implementation proceeds.)
```

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/presentation/theme/app_theme.dart assets docs/superpowers/DELIVERY_REPORT.md
git commit -m "chore: add deps, theme, asset registration, delivery report"
```

---

## Task 2: Domain models

**Files:**
- Create: `lib/domain/models/damage_type.dart`
- Create: `lib/domain/models/loot_item.dart`
- Create: `lib/domain/models/map_coord.dart`
- Create: `lib/domain/models/region.dart`
- Create: `lib/domain/models/boss.dart`
- Create: `lib/domain/models/album_data.dart`
- Test: `test/domain/models/boss_test.dart`

**Interfaces:**
- Produces:
  - `enum DamageType { holy, poison, scarletRot, fire, bleed, frost, lightning, magic, physical }` with `String get label`, `String get emoji`, `Color get color`, and `static DamageType fromKey(String key)` (keys are snake_case: `scarlet_rot`).
  - `class LootItem { final String name; final String? icon; const LootItem(...); factory LootItem.fromJson(Map) }`
  - `class MapCoord { final double x, y; const MapCoord(...); factory MapCoord.fromJson(Map) }`
  - `class Region { final String id; final String name; final int order; const Region(...); factory Region.fromJson(Map) }`
  - `class Boss { final String id, name; final String? subtitle; final String region; final String art; final String locationName; final MapCoord mapCoord; final List<DamageType> strongVs, weakTo; final List<LootItem> loot; final String lore; const Boss(...); factory Boss.fromJson(Map) }`
  - `class AlbumData { final List<Region> regions; final List<Boss> bosses; const AlbumData(...); List<Boss> bossesIn(String regionId); Boss bossById(String id); }`

- [ ] **Step 1: Write the failing test**

Create `test/domain/models/boss_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/domain/models/boss.dart';
import 'package:elden_world_cup/domain/models/damage_type.dart';

void main() {
  test('Boss.fromJson parses all fields including snake_case damage keys', () {
    final json = {
      'id': 'malenia',
      'name': 'Malenia',
      'subtitle': 'Boss opcional',
      'region': 'haligtree',
      'art': 'images/malenia.webp',
      'locationName': 'Elphael, Braço da Haligtree',
      'mapCoord': {'x': 0.62, 'y': 0.44},
      'strongVs': ['holy', 'poison', 'scarlet_rot'],
      'weakTo': ['fire', 'bleed', 'frost'],
      'loot': [
        {'name': 'Mão de Malenia', 'icon': 'images/loot/hand.webp'}
      ],
      'lore': 'Filha de Marika...'
    };

    final boss = Boss.fromJson(json);

    expect(boss.id, 'malenia');
    expect(boss.subtitle, 'Boss opcional');
    expect(boss.mapCoord.x, 0.62);
    expect(boss.strongVs, contains(DamageType.scarletRot));
    expect(boss.weakTo, contains(DamageType.fire));
    expect(boss.loot.single.name, 'Mão de Malenia');
  });

  test('Boss.fromJson tolerates missing optional fields', () {
    final boss = Boss.fromJson({
      'id': 'x', 'name': 'X', 'region': 'r', 'art': 'a.webp',
      'locationName': 'loc', 'mapCoord': {'x': 0.0, 'y': 0.0},
      'lore': '',
    });
    expect(boss.subtitle, isNull);
    expect(boss.strongVs, isEmpty);
    expect(boss.loot, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/models/boss_test.dart`
Expected: FAIL — "Target of URI doesn't exist: '.../boss.dart'".

- [ ] **Step 3: Implement `damage_type.dart`**

Create `lib/domain/models/damage_type.dart`:

```dart
import 'package:flutter/material.dart';

enum DamageType {
  holy('Sagrado', '✨', Color(0xFF3A3420)),
  poison('Tóxico', '☠️', Color(0xFF26331F)),
  scarletRot('Podridão Escarlate', '🌸', Color(0xFF3A221F)),
  fire('Fogo', '🔥', Color(0xFF3A2418)),
  bleed('Hemorragia', '🩸', Color(0xFF3A1A1A)),
  frost('Congelamento', '❄️', Color(0xFF1F2C3A)),
  lightning('Raio', '⚡', Color(0xFF33301A)),
  magic('Mágico', '🔮', Color(0xFF231F3A)),
  physical('Físico', '🗡️', Color(0xFF2A2420));

  const DamageType(this.label, this.emoji, this.color);
  final String label;
  final String emoji;
  final Color color;

  static DamageType fromKey(String key) {
    switch (key) {
      case 'holy': return DamageType.holy;
      case 'poison': return DamageType.poison;
      case 'scarlet_rot': return DamageType.scarletRot;
      case 'fire': return DamageType.fire;
      case 'bleed': return DamageType.bleed;
      case 'frost': return DamageType.frost;
      case 'lightning': return DamageType.lightning;
      case 'magic': return DamageType.magic;
      case 'physical': return DamageType.physical;
      default: throw ArgumentError('Unknown damage type: $key');
    }
  }
}
```

- [ ] **Step 4: Implement the value models**

Create `lib/domain/models/loot_item.dart`:

```dart
class LootItem {
  final String name;
  final String? icon;
  const LootItem({required this.name, this.icon});

  factory LootItem.fromJson(Map<String, dynamic> json) =>
      LootItem(name: json['name'] as String, icon: json['icon'] as String?);
}
```

Create `lib/domain/models/map_coord.dart`:

```dart
class MapCoord {
  final double x;
  final double y;
  const MapCoord(this.x, this.y);

  factory MapCoord.fromJson(Map<String, dynamic> json) =>
      MapCoord((json['x'] as num).toDouble(), (json['y'] as num).toDouble());
}
```

Create `lib/domain/models/region.dart`:

```dart
class Region {
  final String id;
  final String name;
  final int order;
  const Region({required this.id, required this.name, required this.order});

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json['id'] as String,
        name: json['name'] as String,
        order: json['order'] as int,
      );
}
```

- [ ] **Step 5: Implement `boss.dart`**

Create `lib/domain/models/boss.dart`:

```dart
import 'damage_type.dart';
import 'loot_item.dart';
import 'map_coord.dart';

class Boss {
  final String id;
  final String name;
  final String? subtitle;
  final String region;
  final String art;
  final String locationName;
  final MapCoord mapCoord;
  final List<DamageType> strongVs;
  final List<DamageType> weakTo;
  final List<LootItem> loot;
  final String lore;

  const Boss({
    required this.id,
    required this.name,
    this.subtitle,
    required this.region,
    required this.art,
    required this.locationName,
    required this.mapCoord,
    this.strongVs = const [],
    this.weakTo = const [],
    this.loot = const [],
    required this.lore,
  });

  factory Boss.fromJson(Map<String, dynamic> json) {
    List<DamageType> dmg(String key) => ((json[key] as List?) ?? const [])
        .map((e) => DamageType.fromKey(e as String))
        .toList();
    return Boss(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String?,
      region: json['region'] as String,
      art: json['art'] as String,
      locationName: json['locationName'] as String,
      mapCoord: MapCoord.fromJson(json['mapCoord'] as Map<String, dynamic>),
      strongVs: dmg('strongVs'),
      weakTo: dmg('weakTo'),
      loot: ((json['loot'] as List?) ?? const [])
          .map((e) => LootItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      lore: json['lore'] as String,
    );
  }
}
```

- [ ] **Step 6: Implement `album_data.dart`**

Create `lib/domain/models/album_data.dart`:

```dart
import 'boss.dart';
import 'region.dart';

class AlbumData {
  final List<Region> regions;
  final List<Boss> bosses;
  const AlbumData({required this.regions, required this.bosses});

  List<Boss> bossesIn(String regionId) =>
      bosses.where((b) => b.region == regionId).toList();

  Boss bossById(String id) => bosses.firstWhere((b) => b.id == id);
}
```

- [ ] **Step 7: Run tests to verify they pass**

Run: `flutter test test/domain/models/boss_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 8: Commit**

```bash
git add lib/domain/models test/domain/models
git commit -m "feat: domain models (Boss, Region, DamageType, LootItem, MapCoord, AlbumData)"
```

---

## Task 3: Progress value object + transitions

**Files:**
- Create: `lib/domain/progress.dart`
- Test: `test/domain/progress_test.dart`

**Interfaces:**
- Consumes: nothing (pure Dart).
- Produces: `class Progress` with:
  - `final Set<String> defeated; final Set<String> revealedMap; const Progress({this.defeated = const {}, this.revealedMap = const {}});`
  - `bool isDefeated(String id)`
  - `bool isMapRevealed(String id)` — returns true if `id` in `revealedMap` **or** `id` in `defeated`.
  - `Progress toggleDefeated(String id)` — adds/removes from `defeated` (immutably, returns new Progress).
  - `Progress revealMap(String id)` / `Progress hideMap(String id)`.
  - `int defeatedCountIn(Iterable<String> bossIds)` — how many of the given ids are defeated.

- [ ] **Step 1: Write the failing test**

Create `test/domain/progress_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/domain/progress.dart';

void main() {
  test('toggleDefeated adds then removes immutably', () {
    const p0 = Progress();
    final p1 = p0.toggleDefeated('malenia');
    expect(p0.isDefeated('malenia'), isFalse); // original untouched
    expect(p1.isDefeated('malenia'), isTrue);
    final p2 = p1.toggleDefeated('malenia');
    expect(p2.isDefeated('malenia'), isFalse);
  });

  test('defeated boss is implicitly map-revealed', () {
    final p = const Progress().toggleDefeated('malenia');
    expect(p.isMapRevealed('malenia'), isTrue);
  });

  test('revealMap / hideMap toggle reveal for pending boss', () {
    final p = const Progress().revealMap('godrick');
    expect(p.isMapRevealed('godrick'), isTrue);
    expect(p.hideMap('godrick').isMapRevealed('godrick'), isFalse);
  });

  test('defeatedCountIn counts only matching defeated ids', () {
    final p = const Progress()
        .toggleDefeated('a')
        .toggleDefeated('c');
    expect(p.defeatedCountIn(['a', 'b', 'c']), 2);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/progress_test.dart`
Expected: FAIL — "Target of URI doesn't exist: '.../progress.dart'".

- [ ] **Step 3: Implement `progress.dart`**

Create `lib/domain/progress.dart`:

```dart
class Progress {
  final Set<String> defeated;
  final Set<String> revealedMap;

  const Progress({this.defeated = const {}, this.revealedMap = const {}});

  bool isDefeated(String id) => defeated.contains(id);

  bool isMapRevealed(String id) =>
      revealedMap.contains(id) || defeated.contains(id);

  Progress toggleDefeated(String id) {
    final next = Set<String>.from(defeated);
    next.contains(id) ? next.remove(id) : next.add(id);
    return Progress(defeated: next, revealedMap: revealedMap);
  }

  Progress revealMap(String id) =>
      Progress(defeated: defeated, revealedMap: {...revealedMap, id});

  Progress hideMap(String id) =>
      Progress(defeated: defeated, revealedMap: {...revealedMap}..remove(id));

  int defeatedCountIn(Iterable<String> bossIds) =>
      bossIds.where(defeated.contains).length;
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/domain/progress_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/domain/progress.dart test/domain/progress_test.dart
git commit -m "feat: Progress value object with immutable transitions"
```

---

## Task 4: Boss repository (load + parse JSON asset)

**Files:**
- Create: `lib/data/boss_repository.dart`
- Create: `assets/bosses.json`
- Test: `test/data/boss_repository_test.dart`

**Interfaces:**
- Consumes: `AlbumData`, `Boss`, `Region` (Task 2).
- Produces: `class BossRepository { Future<AlbumData> load(); }`. Default ctor reads via `rootBundle`; a test ctor `BossRepository.withLoader(Future<String> Function(String) loader)` allows injecting JSON. The asset path is `assets/bosses.json`.

- [ ] **Step 1: Create the seed `bosses.json`**

Create `assets/bosses.json`. Seed with ~12 bosses across a few regions. Real content is curated later; use the Malenia placeholder art path for every boss for now (per the never-block rule). Coordinates are rough placeholders.

```json
{
  "regions": [
    { "id": "limgrave", "name": "Limgrave", "order": 1 },
    { "id": "liurnia", "name": "Liurnia", "order": 2 },
    { "id": "caelid", "name": "Caelid", "order": 3 },
    { "id": "haligtree", "name": "Haligtree", "order": 9 }
  ],
  "bosses": [
    {
      "id": "margit", "name": "Margit", "subtitle": "O Caído Imundo",
      "region": "limgrave", "art": "images/malenia.webp",
      "locationName": "Stormveil, Limgrave",
      "mapCoord": { "x": 0.34, "y": 0.30 },
      "strongVs": ["holy"], "weakTo": ["bleed"],
      "loot": [{ "name": "Talismã de Margit" }],
      "lore": "Um espírito que protege a entrada do Castelo de Stormveil."
    },
    {
      "id": "godrick", "name": "Godrick", "subtitle": "O Enxertado",
      "region": "limgrave", "art": "images/malenia.webp",
      "locationName": "Castelo de Stormveil",
      "mapCoord": { "x": 0.30, "y": 0.22 },
      "strongVs": ["magic"], "weakTo": ["bleed", "frost"],
      "loot": [{ "name": "Grande Runa de Godrick" }, { "name": "Lembrança" }],
      "lore": "Descendente enfraquecido que enxerta membros de inimigos."
    },
    {
      "id": "agheel", "name": "Dragão Agheel", "subtitle": "Dragão Voador",
      "region": "limgrave", "art": "images/malenia.webp",
      "locationName": "Lago Agheel, Limgrave",
      "mapCoord": { "x": 0.40, "y": 0.34 },
      "strongVs": ["fire"], "weakTo": ["physical"],
      "loot": [{ "name": "Coração de Dragão" }],
      "lore": "Um dragão que cospe fogo sobre o lago de Limgrave."
    },
    {
      "id": "renna", "name": "Rennala", "subtitle": "Rainha da Lua Cheia",
      "region": "liurnia", "art": "images/malenia.webp",
      "locationName": "Academia Raya Lucaria",
      "mapCoord": { "x": 0.22, "y": 0.46 },
      "strongVs": ["magic"], "weakTo": ["physical"],
      "loot": [{ "name": "Grande Runa de Rennala" }, { "name": "Lembrança" }],
      "lore": "Diretora da Academia, outrora esposa de Radagon."
    },
    {
      "id": "royal_knight", "name": "Loretta", "subtitle": "Cavaleira Real",
      "region": "liurnia", "art": "images/malenia.webp",
      "locationName": "Liurnia dos Lagos",
      "mapCoord": { "x": 0.18, "y": 0.40 },
      "strongVs": ["holy"], "weakTo": ["bleed"],
      "loot": [{ "name": "Grande Flecha de Loretta" }],
      "lore": "Cavaleira leal à família Caria."
    },
    {
      "id": "magma_wyrm", "name": "Magma Wyrm", "subtitle": "Verme de Magma",
      "region": "liurnia", "art": "images/malenia.webp",
      "locationName": "Túnel Gael, Liurnia",
      "mapCoord": { "x": 0.12, "y": 0.52 },
      "strongVs": ["fire"], "weakTo": ["frost"],
      "loot": [{ "name": "Lâmina de Magma" }],
      "lore": "Uma serpente de magma escondida nos túneis."
    },
    {
      "id": "radahn", "name": "Radahn", "subtitle": "Flagelo das Estrelas",
      "region": "caelid", "art": "images/malenia.webp",
      "locationName": "Redmane, Caelid",
      "mapCoord": { "x": 0.72, "y": 0.40 },
      "strongVs": ["holy"], "weakTo": ["bleed"],
      "loot": [{ "name": "Grande Runa de Radahn" }, { "name": "Lembrança" }],
      "lore": "O maior general de Caelid, que segura as estrelas com gravidade."
    },
    {
      "id": "decaying_ekzykes", "name": "Ekzykes", "subtitle": "Dragão da Podridão",
      "region": "caelid", "art": "images/malenia.webp",
      "locationName": "Caelid",
      "mapCoord": { "x": 0.66, "y": 0.36 },
      "strongVs": ["scarlet_rot"], "weakTo": ["physical"],
      "loot": [{ "name": "Coração de Dragão" }],
      "lore": "Um dragão consumido pela Escarlate Podridão."
    },
    {
      "id": "nox_swordstress", "name": "Espadachim Nox", "subtitle": "Guardiã",
      "region": "caelid", "art": "images/malenia.webp",
      "locationName": "Sellia, Caelid",
      "mapCoord": { "x": 0.78, "y": 0.44 },
      "strongVs": ["magic"], "weakTo": ["bleed"],
      "loot": [{ "name": "Talismã" }],
      "lore": "Antiga guerreira da civilização eterna."
    },
    {
      "id": "malenia", "name": "Malenia", "subtitle": "Lâmina de Miquella",
      "region": "haligtree", "art": "images/malenia.webp",
      "locationName": "Elphael, Braço da Haligtree",
      "mapCoord": { "x": 0.62, "y": 0.44 },
      "strongVs": ["holy", "poison", "scarlet_rot"],
      "weakTo": ["fire", "bleed", "frost"],
      "loot": [
        { "name": "Grande Runa de Malenia" },
        { "name": "Lembrança da Deusa da Podridão" }
      ],
      "lore": "Filha de Marika, nasceu amaldiçoada pela Escarlate Podridão. Invicta, exceto contra o próprio irmão."
    },
    {
      "id": "loretta_haligtree", "name": "Loretta", "subtitle": "Cavaleira da Haligtree",
      "region": "haligtree", "art": "images/malenia.webp",
      "locationName": "Haligtree de Miquella",
      "mapCoord": { "x": 0.58, "y": 0.40 },
      "strongVs": ["holy"], "weakTo": ["bleed"],
      "loot": [{ "name": "Magia de Loretta" }],
      "lore": "A mesma Loretta, agora guardando a Haligtree."
    },
    {
      "id": "ulcerated_tree", "name": "Espírito da Árvore", "subtitle": "Ulcerado",
      "region": "haligtree", "art": "images/malenia.webp",
      "locationName": "Haligtree de Miquella",
      "mapCoord": { "x": 0.60, "y": 0.48 },
      "strongVs": ["holy"], "weakTo": ["fire"],
      "loot": [{ "name": "Runas" }],
      "lore": "Um espírito gigante em forma de serpente que protege a árvore."
    }
  ]
}
```

> Add to the delivery report: lore, subtitles, weaknesses and coordinates here are **placeholder/approximate** and need the owner's curation pass.

- [ ] **Step 2: Write the failing test**

Create `test/data/boss_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/data/boss_repository.dart';

void main() {
  test('load parses regions and bosses from injected JSON', () async {
    const json = '''
    {"regions":[{"id":"limgrave","name":"Limgrave","order":1}],
     "bosses":[{"id":"margit","name":"Margit","region":"limgrave",
       "art":"a.webp","locationName":"loc","mapCoord":{"x":0.1,"y":0.2},
       "lore":"l"}]}''';
    final repo = BossRepository.withLoader((_) async => json);

    final data = await repo.load();

    expect(data.regions.single.name, 'Limgrave');
    expect(data.bossesIn('limgrave').single.id, 'margit');
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/data/boss_repository_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 4: Implement `boss_repository.dart`**

Create `lib/data/boss_repository.dart`:

```dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../domain/models/album_data.dart';
import '../domain/models/boss.dart';
import '../domain/models/region.dart';

class BossRepository {
  final Future<String> Function(String path) _loader;

  BossRepository() : _loader = rootBundle.loadString;
  BossRepository.withLoader(this._loader);

  Future<AlbumData> load() async {
    final raw = await _loader('assets/bosses.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final regions = (map['regions'] as List)
        .map((e) => Region.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final bosses = (map['bosses'] as List)
        .map((e) => Boss.fromJson(e as Map<String, dynamic>))
        .toList();
    return AlbumData(regions: regions, bosses: bosses);
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/data/boss_repository_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/data/boss_repository.dart assets/bosses.json test/data/boss_repository_test.dart
git commit -m "feat: BossRepository + seed bosses.json (12 placeholder bosses)"
```

---

## Task 5: Progress store (shared_preferences persistence)

**Files:**
- Create: `lib/data/progress_store.dart`
- Test: `test/data/progress_store_test.dart`

**Interfaces:**
- Consumes: `Progress` (Task 3).
- Produces: `class ProgressStore { Future<Progress> load(); Future<void> save(Progress p); }`. Uses `SharedPreferences` keys `defeated` and `revealedMap` (both `List<String>`).

- [ ] **Step 1: Write the failing test**

Create `test/data/progress_store_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elden_world_cup/data/progress_store.dart';
import 'package:elden_world_cup/domain/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('save then load round-trips defeated and revealedMap', () async {
    final store = ProgressStore();
    final p = const Progress(defeated: {'malenia'}, revealedMap: {'godrick'});

    await store.save(p);
    final loaded = await store.load();

    expect(loaded.isDefeated('malenia'), isTrue);
    expect(loaded.isMapRevealed('godrick'), isTrue);
    expect(loaded.isDefeated('godrick'), isFalse);
  });

  test('load on empty prefs returns empty progress', () async {
    final loaded = await ProgressStore().load();
    expect(loaded.defeated, isEmpty);
    expect(loaded.revealedMap, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/progress_store_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Implement `progress_store.dart`**

Create `lib/data/progress_store.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/progress.dart';

class ProgressStore {
  static const _kDefeated = 'defeated';
  static const _kRevealed = 'revealedMap';

  Future<Progress> load() async {
    final prefs = await SharedPreferences.getInstance();
    return Progress(
      defeated: (prefs.getStringList(_kDefeated) ?? const []).toSet(),
      revealedMap: (prefs.getStringList(_kRevealed) ?? const []).toSet(),
    );
  }

  Future<void> save(Progress p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kDefeated, p.defeated.toList());
    await prefs.setStringList(_kRevealed, p.revealedMap.toList());
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/data/progress_store_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/data/progress_store.dart test/data/progress_store_test.dart
git commit -m "feat: ProgressStore persistence via shared_preferences"
```

---

## Task 6: AlbumController (state)

**Files:**
- Create: `lib/state/album_controller.dart`
- Test: `test/state/album_controller_test.dart`

**Interfaces:**
- Consumes: `AlbumData`, `BossRepository`, `ProgressStore`, `Progress`.
- Produces: `class AlbumController extends ChangeNotifier` with:
  - `AlbumController({required BossRepository repo, required ProgressStore store})`
  - `Future<void> init()` — loads data + progress, then `notifyListeners`.
  - `bool get isLoaded`
  - `AlbumData get data`
  - `List<Region> get regions`
  - `int get totalBosses`, `int get totalDefeated`
  - `int defeatedIn(String regionId)`, `int countIn(String regionId)`
  - `bool isDefeated(String id)`, `bool isMapRevealed(String id)`
  - `Future<void> toggleDefeated(String id)` — mutates, persists, notifies.
  - `Future<void> revealMap(String id)` / `Future<void> hideMap(String id)` — mutate, persist, notify.

- [ ] **Step 1: Write the failing test**

Create `test/state/album_controller_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elden_world_cup/data/boss_repository.dart';
import 'package:elden_world_cup/data/progress_store.dart';
import 'package:elden_world_cup/state/album_controller.dart';

const _json = '''
{"regions":[{"id":"limgrave","name":"Limgrave","order":1}],
 "bosses":[
   {"id":"margit","name":"Margit","region":"limgrave","art":"a.webp",
    "locationName":"loc","mapCoord":{"x":0.1,"y":0.2},"lore":"l"},
   {"id":"godrick","name":"Godrick","region":"limgrave","art":"a.webp",
    "locationName":"loc","mapCoord":{"x":0.1,"y":0.2},"lore":"l"}]}''';

AlbumController _make() => AlbumController(
      repo: BossRepository.withLoader((_) async => _json),
      store: ProgressStore(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('init loads data and starts empty', () async {
    final c = _make();
    await c.init();
    expect(c.isLoaded, isTrue);
    expect(c.totalBosses, 2);
    expect(c.totalDefeated, 0);
    expect(c.countIn('limgrave'), 2);
  });

  test('toggleDefeated updates counts and persists', () async {
    final c = _make();
    await c.init();
    await c.toggleDefeated('margit');
    expect(c.isDefeated('margit'), isTrue);
    expect(c.totalDefeated, 1);
    expect(c.defeatedIn('limgrave'), 1);

    // new controller reads persisted state
    final c2 = _make();
    await c2.init();
    expect(c2.isDefeated('margit'), isTrue);
  });

  test('defeated boss is map-revealed', () async {
    final c = _make();
    await c.init();
    await c.toggleDefeated('margit');
    expect(c.isMapRevealed('margit'), isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/state/album_controller_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Implement `album_controller.dart`**

Create `lib/state/album_controller.dart`:

```dart
import 'package:flutter/foundation.dart';
import '../data/boss_repository.dart';
import '../data/progress_store.dart';
import '../domain/models/album_data.dart';
import '../domain/models/region.dart';
import '../domain/progress.dart';

class AlbumController extends ChangeNotifier {
  AlbumController({required BossRepository repo, required ProgressStore store})
      : _repo = repo,
        _store = store;

  final BossRepository _repo;
  final ProgressStore _store;

  AlbumData? _data;
  Progress _progress = const Progress();

  bool get isLoaded => _data != null;
  AlbumData get data => _data!;
  List<Region> get regions => _data!.regions;

  int get totalBosses => _data!.bosses.length;
  int get totalDefeated => _progress.defeated.length;

  int countIn(String regionId) => _data!.bossesIn(regionId).length;
  int defeatedIn(String regionId) =>
      _progress.defeatedCountIn(_data!.bossesIn(regionId).map((b) => b.id));

  bool isDefeated(String id) => _progress.isDefeated(id);
  bool isMapRevealed(String id) => _progress.isMapRevealed(id);

  Future<void> init() async {
    _data = await _repo.load();
    _progress = await _store.load();
    notifyListeners();
  }

  Future<void> toggleDefeated(String id) =>
      _apply(_progress.toggleDefeated(id));
  Future<void> revealMap(String id) => _apply(_progress.revealMap(id));
  Future<void> hideMap(String id) => _apply(_progress.hideMap(id));

  Future<void> _apply(Progress next) async {
    _progress = next;
    notifyListeners();
    await _store.save(next);
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/state/album_controller_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/state/album_controller.dart test/state/album_controller_test.dart
git commit -m "feat: AlbumController state (load, counts, toggle, map reveal)"
```

---

## Task 7: StickerSlot widget

**Files:**
- Create: `lib/presentation/album/widgets/sticker_slot.dart`
- Test: `test/presentation/sticker_slot_test.dart`

**Interfaces:**
- Consumes: `Boss` (Task 2), `AppColors`/`AppText` (Task 1).
- Produces: `class StickerSlot extends StatelessWidget { const StickerSlot({required this.boss, required this.defeated, required this.onTap}); }` — renders a 3:4 slot. Defeated = colored art + gold border + ✓ badge + name. Pending = grayscale+blurred art + name, **no lock icon**. Whole slot tappable.

- [ ] **Step 1: Write the failing widget test**

Create `test/presentation/sticker_slot_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/domain/models/boss.dart';
import 'package:elden_world_cup/domain/models/map_coord.dart';
import 'package:elden_world_cup/presentation/album/widgets/sticker_slot.dart';

const _boss = Boss(
  id: 'malenia', name: 'Malenia', region: 'haligtree',
  art: 'images/malenia.webp', locationName: 'loc',
  mapCoord: MapCoord(0.6, 0.4), lore: 'l',
);

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('shows name in both states', (tester) async {
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: false, onTap: () {})));
    expect(find.text('MALENIA'), findsOneWidget);
  });

  testWidgets('defeated shows check badge, pending does not', (tester) async {
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: true, onTap: () {})));
    expect(find.byKey(const Key('slot-check')), findsOneWidget);

    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: false, onTap: () {})));
    expect(find.byKey(const Key('slot-check')), findsNothing);
  });

  testWidgets('tap fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: false, onTap: () => tapped = true)));
    await tester.tap(find.byType(StickerSlot));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/sticker_slot_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Implement `sticker_slot.dart`**

Create `lib/presentation/album/widgets/sticker_slot.dart`:

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../domain/models/boss.dart';
import '../../theme/app_theme.dart';

class StickerSlot extends StatelessWidget {
  const StickerSlot({
    super.key,
    required this.boss,
    required this.defeated,
    required this.onTap,
  });

  final Boss boss;
  final bool defeated;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: defeated ? AppColors.gold : AppColors.border,
                width: defeated ? 2 : 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _art(),
                if (defeated)
                  Positioned(
                    top: 4, right: 4,
                    child: Container(
                      key: const Key('slot-check'),
                      width: 16, height: 16,
                      decoration: const BoxDecoration(
                          color: AppColors.gold, shape: BoxShape.circle),
                      child: const Icon(Icons.check,
                          size: 11, color: AppColors.background),
                    ),
                  ),
                _nameStrip(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _art() {
    final image = Image.asset('assets/${boss.art}', fit: BoxFit.cover,
        alignment: const Alignment(0, -0.6),
        errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceAlt));
    if (defeated) return image;
    // pending: grayscale + blur + darken
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.45), BlendMode.darken),
          child: image,
        ),
      ),
    );
  }

  Widget _nameStrip() => Positioned(
        bottom: 0, left: 0, right: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(3, 12, 3, 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
            ),
          ),
          child: Text(boss.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppText.slotName.copyWith(
                  color: defeated ? AppColors.goldLight
                                  : const Color(0xFF9A8A66))),
        ),
      );
}

// Standard luminance grayscale matrix for ColorFilter.matrix.
const List<double> _grayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];
```

> Note: `Image.asset` paths are prefixed with `assets/` because `boss.art` stores paths relative to `assets/` (e.g. `images/malenia.webp`). The `errorBuilder` guarantees missing art never crashes — it shows a neutral fill (supports the never-block rule).

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/presentation/sticker_slot_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/album/widgets/sticker_slot.dart test/presentation/sticker_slot_test.dart
git commit -m "feat: StickerSlot widget (colored defeated vs blurred pending, no lock)"
```

---

## Task 8: Album screen scaffolding (header + region sections + grid)

**Files:**
- Create: `lib/presentation/album/widgets/progress_header.dart`
- Create: `lib/presentation/album/widgets/region_section.dart`
- Create: `lib/presentation/album/album_screen.dart`
- Test: `test/presentation/album_screen_test.dart`

**Interfaces:**
- Consumes: `AlbumController` (via `provider`), `StickerSlot`, `Boss`, `Region`.
- Produces:
  - `class ProgressHeader extends StatelessWidget { const ProgressHeader({required this.defeated, required this.total}); }`
  - `class RegionSection extends StatelessWidget { const RegionSection({required this.region, required this.bosses, required this.controller, required this.onBossTap}); }` where `onBossTap` is `void Function(Boss)`.
  - `class AlbumScreen extends StatelessWidget` — reads `AlbumController` from context; while `!isLoaded` shows a centered loader; otherwise a `CustomScrollView` with `ProgressHeader` then one `RegionSection` per region (in order). Tapping a slot calls `BossSheet.show(context, boss)` (Task 12 wires the real call; until then a no-op stub is acceptable — but this task ships with the stub calling an injected `onBossTap`).

- [ ] **Step 1: Write the failing widget test**

Create `test/presentation/album_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elden_world_cup/data/boss_repository.dart';
import 'package:elden_world_cup/data/progress_store.dart';
import 'package:elden_world_cup/state/album_controller.dart';
import 'package:elden_world_cup/presentation/album/album_screen.dart';

const _json = '''
{"regions":[{"id":"limgrave","name":"Limgrave","order":1}],
 "bosses":[{"id":"margit","name":"Margit","region":"limgrave","art":"a.webp",
   "locationName":"loc","mapCoord":{"x":0.1,"y":0.2},"lore":"l"}]}''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('renders region header and a slot after load', (tester) async {
    final c = AlbumController(
        repo: BossRepository.withLoader((_) async => _json),
        store: ProgressStore());
    await c.init();

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: c,
      child: const MaterialApp(home: AlbumScreen()),
    ));
    await tester.pump();

    expect(find.text('Limgrave'), findsOneWidget);
    expect(find.text('MARGIT'), findsOneWidget);
    expect(find.textContaining('1'), findsWidgets); // counter "0/1" etc.
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/album_screen_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Implement `progress_header.dart`**

Create `lib/presentation/album/widgets/progress_header.dart`:

```dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key, required this.defeated, required this.total});
  final int defeated;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : defeated / total;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚔️ Elden Album', style: AppText.title),
          const SizedBox(height: 4),
          Text('$defeated de $total bosses derrotados',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct, minHeight: 6,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Implement `region_section.dart`**

Create `lib/presentation/album/widgets/region_section.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../domain/models/boss.dart';
import '../../../domain/models/region.dart';
import '../../../state/album_controller.dart';
import '../../theme/app_theme.dart';
import 'sticker_slot.dart';

class RegionSection extends StatelessWidget {
  const RegionSection({
    super.key,
    required this.region,
    required this.bosses,
    required this.controller,
    required this.onBossTap,
  });

  final Region region;
  final List<Boss> bosses;
  final AlbumController controller;
  final void Function(Boss) onBossTap;

  @override
  Widget build(BuildContext context) {
    final defeated = controller.defeatedIn(region.id);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(region.name.toUpperCase(), style: AppText.regionLabel),
              const SizedBox(width: 8),
              const Expanded(child: Divider(color: AppColors.border, height: 1)),
              const SizedBox(width: 8),
              Text('$defeated/${bosses.length}',
                  style: const TextStyle(color: Color(0xFF6B5D44), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3 / 4,
            children: [
              for (final boss in bosses)
                StickerSlot(
                  boss: boss,
                  defeated: controller.isDefeated(boss.id),
                  onTap: () => onBossTap(boss),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Implement `album_screen.dart`**

Create `lib/presentation/album/album_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/boss.dart';
import '../../state/album_controller.dart';
import '../theme/app_theme.dart';
import 'widgets/progress_header.dart';
import 'widgets/region_section.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key, this.onBossTap});

  /// Injection seam for tests; when null, taps are wired to BossSheet in Task 12.
  final void Function(BuildContext, Boss)? onBossTap;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AlbumController>();
    if (!c.isLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProgressHeader(
                defeated: c.totalDefeated, total: c.totalBosses),
          ),
          for (final region in c.regions)
            SliverToBoxAdapter(
              child: RegionSection(
                region: region,
                bosses: c.data.bossesIn(region.id),
                controller: c,
                onBossTap: (boss) => onBossTap?.call(context, boss),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `flutter test test/presentation/album_screen_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/album test/presentation/album_screen_test.dart
git commit -m "feat: AlbumScreen with progress header and region grids"
```

---

## Task 9: Combat & Loot sections (bottom sheet pieces)

**Files:**
- Create: `lib/presentation/boss/widgets/combat_section.dart`
- Create: `lib/presentation/boss/widgets/loot_section.dart`
- Test: `test/presentation/combat_loot_test.dart`

**Interfaces:**
- Consumes: `Boss`, `DamageType`, `LootItem`, theme.
- Produces:
  - `class CombatSection extends StatelessWidget { const CombatSection({required this.strongVs, required this.weakTo}); }`
  - `class LootSection extends StatelessWidget { const LootSection({required this.loot}); }`
  - `class SectionLabel extends StatelessWidget { const SectionLabel(this.text); }` (shared label widget, also reused by Tasks 10–11).

- [ ] **Step 1: Write the failing test**

Create `test/presentation/combat_loot_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/domain/models/damage_type.dart';
import 'package:elden_world_cup/domain/models/loot_item.dart';
import 'package:elden_world_cup/presentation/boss/widgets/combat_section.dart';
import 'package:elden_world_cup/presentation/boss/widgets/loot_section.dart';

Widget _host(Widget c) => MaterialApp(home: Scaffold(body: c));

void main() {
  testWidgets('combat shows both columns and damage labels', (tester) async {
    await tester.pumpWidget(_host(const CombatSection(
      strongVs: [DamageType.holy],
      weakTo: [DamageType.fire],
    )));
    expect(find.text('Mais forte VS'), findsOneWidget);
    expect(find.text('Mais fraco para'), findsOneWidget);
    expect(find.text('Sagrado'), findsOneWidget);
    expect(find.text('Fogo'), findsOneWidget);
  });

  testWidgets('loot lists each item name', (tester) async {
    await tester.pumpWidget(_host(const LootSection(
      loot: [LootItem(name: 'Lembrança'), LootItem(name: 'Grande Runa')],
    )));
    expect(find.text('Lembrança'), findsOneWidget);
    expect(find.text('Grande Runa'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/combat_loot_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Implement the shared `SectionLabel`**

Create `lib/presentation/boss/widgets/section_label.dart`:

```dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text, style: AppText.sectionLabel),
      );
}
```

- [ ] **Step 4: Implement `combat_section.dart`**

Create `lib/presentation/boss/widgets/combat_section.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../domain/models/damage_type.dart';
import '../../theme/app_theme.dart';

class CombatSection extends StatelessWidget {
  const CombatSection({super.key, required this.strongVs, required this.weakTo});
  final List<DamageType> strongVs;
  final List<DamageType> weakTo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _col('Mais forte VS', strongVs, AppColors.strong)),
        const SizedBox(width: 10),
        Expanded(child: _col('Mais fraco para', weakTo, AppColors.weak)),
      ],
    );
  }

  Widget _col(String title, List<DamageType> types, Color titleColor) =>
      Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1209),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: TextStyle(
                    color: titleColor, fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: .6)),
            const SizedBox(height: 9),
            for (final t in types)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.5),
                child: Row(children: [
                  Container(
                    width: 22, height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: t.color,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(t.emoji, style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(t.label,
                        style: const TextStyle(
                            color: AppColors.textBody, fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
          ],
        ),
      );
}
```

- [ ] **Step 5: Implement `loot_section.dart`**

Create `lib/presentation/boss/widgets/loot_section.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../domain/models/loot_item.dart';
import '../../theme/app_theme.dart';

class LootSection extends StatelessWidget {
  const LootSection({super.key, required this.loot});
  final List<LootItem> loot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: loot.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final item = loot[i];
          return SizedBox(
            width: 74,
            child: Column(
              children: [
                Container(
                  width: 74, height: 74,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: item.icon == null
                      ? const Text('💎', style: TextStyle(fontSize: 28))
                      : Image.asset('assets/${item.icon}',
                          width: 40, height: 40,
                          errorBuilder: (_, __, ___) =>
                              const Text('💎', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(height: 5),
                Text(item.name,
                    maxLines: 2, textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textBody, fontSize: 9, height: 1.2)),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

> Loot icons fall back to the 💎 emoji when missing — supports never-block.

- [ ] **Step 6: Run tests to verify they pass**

Run: `flutter test test/presentation/combat_loot_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/boss/widgets/combat_section.dart lib/presentation/boss/widgets/loot_section.dart lib/presentation/boss/widgets/section_label.dart test/presentation/combat_loot_test.dart
git commit -m "feat: CombatSection + LootSection + shared SectionLabel"
```

---

## Task 10: Map section (preview + spoiler lock/unlock) and fullscreen map

**Files:**
- Create: `lib/presentation/boss/widgets/map_section.dart`
- Create: `lib/presentation/map/fullscreen_map.dart`
- Test: `test/presentation/map_section_test.dart`

**Interfaces:**
- Consumes: `Boss`, `MapCoord`, theme.
- Produces:
  - `class MapSection extends StatelessWidget { const MapSection({required this.boss, required this.revealed, required this.onReveal, required this.onHide, required this.onOpenFullscreen}); }` — when `!revealed`: blurred map + 🔒 + "Localização oculta para evitar spoiler" + a "👁 Revelar mapa" button calling `onReveal`. When `revealed`: base map cropped near the pin + pin + location text + "⤢ Ampliar" (calls `onOpenFullscreen`) + a small "🔒 Ocultar" calling `onHide`.
  - `class FullscreenMap extends StatelessWidget { const FullscreenMap({required this.boss}); static Future<void> show(BuildContext, Boss); }` — `InteractiveViewer` over `assets/images/map/base_map.webp` with the pin at `boss.mapCoord`.

- [ ] **Step 1: Write the failing test**

Create `test/presentation/map_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/domain/models/boss.dart';
import 'package:elden_world_cup/domain/models/map_coord.dart';
import 'package:elden_world_cup/presentation/boss/widgets/map_section.dart';

const _boss = Boss(
  id: 'malenia', name: 'Malenia', region: 'haligtree',
  art: 'images/malenia.webp', locationName: 'Elphael, Braço da Haligtree',
  mapCoord: MapCoord(0.6, 0.4), lore: 'l',
);

Widget _host(Widget c) => MaterialApp(home: Scaffold(body: c));

void main() {
  testWidgets('locked state shows reveal button and hides location',
      (tester) async {
    var revealed = false;
    await tester.pumpWidget(_host(MapSection(
      boss: _boss, revealed: false,
      onReveal: () => revealed = true, onHide: () {}, onOpenFullscreen: () {},
    )));
    expect(find.text('👁 Revelar mapa'), findsOneWidget);
    expect(find.text('Elphael, Braço da Haligtree'), findsNothing);

    await tester.tap(find.text('👁 Revelar mapa'));
    expect(revealed, isTrue);
  });

  testWidgets('revealed state shows location and amplify control',
      (tester) async {
    await tester.pumpWidget(_host(MapSection(
      boss: _boss, revealed: true,
      onReveal: () {}, onHide: () {}, onOpenFullscreen: () {},
    )));
    expect(find.text('Elphael, Braço da Haligtree'), findsOneWidget);
    expect(find.textContaining('Ampliar'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/map_section_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Implement `fullscreen_map.dart`**

Create `lib/presentation/map/fullscreen_map.dart`:

```dart
import 'package:flutter/material.dart';
import '../../domain/models/boss.dart';
import '../theme/app_theme.dart';

class FullscreenMap extends StatelessWidget {
  const FullscreenMap({super.key, required this.boss});
  final Boss boss;

  static Future<void> show(BuildContext context, Boss boss) =>
      Navigator.of(context).push(MaterialPageRoute(
          fullscreenDialog: true, builder: (_) => FullscreenMap(boss: boss)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8, maxScale: 5,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Image.asset('assets/images/map/base_map.webp',
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          errorBuilder: (_, __, ___) =>
                              Container(color: const Color(0xFF14201A))),
                      Positioned(
                        left: boss.mapCoord.x * constraints.maxWidth - 14,
                        top: boss.mapCoord.y * constraints.maxHeight - 28,
                        child: const Text('📍',
                            style: TextStyle(fontSize: 28)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.goldLight),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text('Localização de ${boss.name}',
                    style: const TextStyle(
                        color: AppColors.goldLight,
                        fontWeight: FontWeight.w800, fontSize: 15)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Implement `map_section.dart`**

Create `lib/presentation/boss/widgets/map_section.dart`:

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../domain/models/boss.dart';
import '../../theme/app_theme.dart';

class MapSection extends StatelessWidget {
  const MapSection({
    super.key,
    required this.boss,
    required this.revealed,
    required this.onReveal,
    required this.onHide,
    required this.onOpenFullscreen,
  });

  final Boss boss;
  final bool revealed;
  final VoidCallback onReveal;
  final VoidCallback onHide;
  final VoidCallback onOpenFullscreen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 160,
        child: Stack(fit: StackFit.expand, children: [
          _baseMap(),
          if (!revealed) _locked() else _revealedOverlay(),
        ]),
      ),
    );
  }

  Widget _baseMap() {
    final img = Image.asset('assets/images/map/base_map.webp',
        fit: BoxFit.cover,
        alignment: Alignment(boss.mapCoord.x * 2 - 1, boss.mapCoord.y * 2 - 1),
        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF14201A)));
    if (revealed) return img;
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5), BlendMode.darken),
        child: img,
      ),
    );
  }

  Widget _locked() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('Localização oculta para evitar spoiler',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFFC9B78F), fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onReveal,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.background),
              child: const Text('👁 Revelar mapa',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
            ),
          ],
        ),
      );

  Widget _revealedOverlay() => Stack(children: [
        // pin (centered since the base map is aligned on the coord)
        const Center(child: Text('📍', style: TextStyle(fontSize: 26))),
        Positioned(
          top: 8, left: 8,
          child: GestureDetector(
            onTap: onHide,
            child: _chip('🔒 Ocultar', muted: true),
          ),
        ),
        Positioned(
          top: 8, right: 8,
          child: GestureDetector(
            onTap: onOpenFullscreen,
            child: _chip('⤢ Ampliar'),
          ),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(11, 18, 11, 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
              ),
            ),
            child: Text(boss.locationName,
                style: const TextStyle(
                    color: Color(0xFFCFE0D3), fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]);

  Widget _chip(String text, {bool muted = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.85),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(text,
            style: TextStyle(
                color: muted ? AppColors.textMuted : const Color(0xFFC9B78F),
                fontSize: 9, fontWeight: FontWeight.w700)),
      );
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/presentation/map_section_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/boss/widgets/map_section.dart lib/presentation/map/fullscreen_map.dart test/presentation/map_section_test.dart
git commit -m "feat: MapSection with spoiler lock/unlock + FullscreenMap (InteractiveViewer)"
```

---

## Task 11: Boss hero (collapsing, blurred when pending) + reveal overlay

**Files:**
- Create: `lib/presentation/boss/widgets/boss_hero.dart`
- Create: `lib/presentation/boss/widgets/reveal_overlay.dart`
- Test: `test/presentation/boss_hero_test.dart`

**Interfaces:**
- Consumes: `Boss`, theme.
- Produces:
  - `class BossHero extends StatelessWidget { const BossHero({required this.boss, required this.defeated}); }` — meant to be the `flexibleSpace` child content; renders the art (blurred B&W with "⚔️ Derrote para revelar" when `!defeated`; colored when `defeated`) + gradient + name/subtitle.
  - `class RevealOverlay extends StatefulWidget { const RevealOverlay({required this.child, required this.play, this.onDone}); }` — wraps `child`; when `play` becomes true, runs a ~700ms glow+sparkle animation over it.

- [ ] **Step 1: Write the failing test**

Create `test/presentation/boss_hero_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elden_world_cup/domain/models/boss.dart';
import 'package:elden_world_cup/domain/models/map_coord.dart';
import 'package:elden_world_cup/presentation/boss/widgets/boss_hero.dart';

const _boss = Boss(
  id: 'malenia', name: 'Malenia', subtitle: 'Boss opcional',
  region: 'haligtree', art: 'images/malenia.webp', locationName: 'loc',
  mapCoord: MapCoord(0.6, 0.4), lore: 'l',
);

Widget _host(Widget c) => MaterialApp(home: Scaffold(body: c));

void main() {
  testWidgets('pending shows "Derrote para revelar"', (tester) async {
    await tester.pumpWidget(_host(const BossHero(boss: _boss, defeated: false)));
    expect(find.textContaining('Derrote para revelar'), findsOneWidget);
    expect(find.text('Malenia'), findsOneWidget);
  });

  testWidgets('defeated does not show the reveal hint', (tester) async {
    await tester.pumpWidget(_host(const BossHero(boss: _boss, defeated: true)));
    expect(find.textContaining('Derrote para revelar'), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/boss_hero_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Implement `boss_hero.dart`**

Create `lib/presentation/boss/widgets/boss_hero.dart`:

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../domain/models/boss.dart';
import '../../theme/app_theme.dart';

class BossHero extends StatelessWidget {
  const BossHero({super.key, required this.boss, required this.defeated});
  final Boss boss;
  final bool defeated;

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      _art(),
      const _BottomFade(),
      if (!defeated)
        const Positioned(
          top: 12, left: 0, right: 0,
          child: Text('⚔️ Derrote para revelar',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFFB9A878), fontSize: 11,
                  fontWeight: FontWeight.w700, letterSpacing: .5)),
        ),
      Positioned(
        bottom: 12, left: 16, right: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(boss.name,
                style: const TextStyle(
                    color: AppColors.goldLight, fontSize: 24,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)])),
            if (boss.subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(boss.subtitle!,
                    style: const TextStyle(
                        color: Color(0xFFC9B78F), fontSize: 12)),
              ),
          ],
        ),
      ),
    ]);
  }

  Widget _art() {
    final img = Image.asset('assets/${boss.art}',
        fit: BoxFit.cover, alignment: const Alignment(0, -0.6),
        errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceAlt));
    if (defeated) return img;
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5), BlendMode.darken),
        child: img,
      ),
    );
  }
}

class _BottomFade extends StatelessWidget {
  const _BottomFade();
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            stops: const [0.45, 1.0],
            colors: [Colors.transparent, AppColors.background],
          ),
        ),
      );
}
```

> Note: the pending hero uses blur+darken to read as "locked." A true grayscale can be added later; blur+darken already communicates the state and keeps this task focused.

- [ ] **Step 4: Implement `reveal_overlay.dart`**

Create `lib/presentation/boss/widgets/reveal_overlay.dart`:

```dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RevealOverlay extends StatefulWidget {
  const RevealOverlay({
    super.key,
    required this.child,
    required this.play,
    this.onDone,
  });

  final Widget child;
  final bool play;
  final VoidCallback? onDone;

  @override
  State<RevealOverlay> createState() => _RevealOverlayState();
}

class _RevealOverlayState extends State<RevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void didUpdateWidget(RevealOverlay old) {
    super.didUpdateWidget(old);
    if (widget.play && !old.play) {
      _c.forward(from: 0).whenComplete(() => widget.onDone?.call());
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final v = _c.value;
          if (v == 0) return const SizedBox.shrink();
          final glow = (v < 0.5 ? v * 2 : (1 - v) * 2).clamp(0.0, 1.0);
          return Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldLight.withValues(alpha: glow * 0.6),
                      blurRadius: 60, spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Opacity(
                    opacity: glow,
                    child: const Text('✨', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ]);
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/presentation/boss_hero_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/boss/widgets/boss_hero.dart lib/presentation/boss/widgets/reveal_overlay.dart test/presentation/boss_hero_test.dart
git commit -m "feat: BossHero (collapsing, blurred when pending) + RevealOverlay animation"
```

---

## Task 12: BossSheet — assemble the bottom sheet + wire reveal/map/defeat + connect to album

**Files:**
- Create: `lib/presentation/boss/boss_sheet.dart`
- Modify: `lib/presentation/album/album_screen.dart` (wire `onBossTap` default to `BossSheet.show`)
- Test: `test/presentation/boss_sheet_test.dart`

**Interfaces:**
- Consumes: `AlbumController` (provider), `Boss`, `BossHero`, `RevealOverlay`, `CombatSection`, `LootSection`, `MapSection`, `FullscreenMap`, `SectionLabel`.
- Produces: `class BossSheet extends StatefulWidget { const BossSheet({required this.boss}); static Future<void> show(BuildContext, Boss); }` — a scrollable modal bottom sheet (`showModalBottomSheet` with `isScrollControlled: true`) using `CustomScrollView` + `SliverAppBar` (expandedHeight 230, pinned, `FlexibleSpaceBar` background = `BossHero`). Body slivers in order: map → combat → loot → lore → action button. Reading `AlbumController` for `isDefeated` / `isMapRevealed`. Action button toggles defeat (and plays reveal). Map section calls `controller.revealMap/hideMap` and `FullscreenMap.show`.

- [ ] **Step 1: Write the failing test**

Create `test/presentation/boss_sheet_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elden_world_cup/data/boss_repository.dart';
import 'package:elden_world_cup/data/progress_store.dart';
import 'package:elden_world_cup/state/album_controller.dart';
import 'package:elden_world_cup/presentation/boss/boss_sheet.dart';

const _json = '''
{"regions":[{"id":"haligtree","name":"Haligtree","order":1}],
 "bosses":[{"id":"malenia","name":"Malenia","subtitle":"Boss opcional",
   "region":"haligtree","art":"images/malenia.webp",
   "locationName":"Elphael","mapCoord":{"x":0.6,"y":0.4},
   "strongVs":["holy"],"weakTo":["fire"],
   "loot":[{"name":"Lembrança"}],"lore":"Filha de Marika."}]}''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('sheet shows sections and toggles defeat via button',
      (tester) async {
    final c = AlbumController(
        repo: BossRepository.withLoader((_) async => _json),
        store: ProgressStore());
    await c.init();
    final boss = c.data.bossById('malenia');

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: c,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => BossSheet.show(context, boss),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // sections present
    expect(find.text('Filha de Marika.'), findsOneWidget);
    expect(find.text('Lembrança'), findsOneWidget);
    expect(find.text('Mais forte VS'), findsOneWidget);
    // map starts locked (pending boss)
    expect(find.text('👁 Revelar mapa'), findsOneWidget);

    // mark as defeated
    expect(find.text('⚔️ Marcar como derrotado'), findsOneWidget);
    await tester.tap(find.text('⚔️ Marcar como derrotado'));
    await tester.pumpAndSettle();

    expect(c.isDefeated('malenia'), isTrue);
    expect(find.text('✓ Conquista registrada'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/boss_sheet_test.dart`
Expected: FAIL — URI doesn't exist.

- [ ] **Step 3: Implement `boss_sheet.dart`**

Create `lib/presentation/boss/boss_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/boss.dart';
import '../../state/album_controller.dart';
import '../map/fullscreen_map.dart';
import '../theme/app_theme.dart';
import 'widgets/boss_hero.dart';
import 'widgets/combat_section.dart';
import 'widgets/loot_section.dart';
import 'widgets/map_section.dart';
import 'widgets/reveal_overlay.dart';
import 'widgets/section_label.dart';

class BossSheet extends StatefulWidget {
  const BossSheet({super.key, required this.boss});
  final Boss boss;

  static Future<void> show(BuildContext context, Boss boss) {
    final controller = context.read<AlbumController>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: FractionallySizedBox(
          heightFactor: 0.92,
          child: BossSheet(boss: boss),
        ),
      ),
    );
  }

  @override
  State<BossSheet> createState() => _BossSheetState();
}

class _BossSheetState extends State<BossSheet> {
  bool _playReveal = false;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AlbumController>();
    final boss = widget.boss;
    final defeated = c.isDefeated(boss.id);
    final mapRevealed = c.isMapRevealed(boss.id);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 230,
          pinned: true,
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.goldLight),
          title: _CollapsedTitle(boss: boss),
          flexibleSpace: FlexibleSpaceBar(
            background: RevealOverlay(
              play: _playReveal,
              onDone: () => setState(() => _playReveal = false),
              child: BossHero(boss: boss, defeated: defeated),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('📍 Onde encontrar'),
                MapSection(
                  boss: boss,
                  revealed: mapRevealed,
                  onReveal: () => c.revealMap(boss.id),
                  onHide: () => c.hideMap(boss.id),
                  onOpenFullscreen: () => FullscreenMap.show(context, boss),
                ),
                const SectionLabel('⚔️ Combate'),
                CombatSection(strongVs: boss.strongVs, weakTo: boss.weakTo),
                const SectionLabel('💎 Loot'),
                LootSection(loot: boss.loot),
                const SectionLabel('📖 Lore'),
                Text(boss.lore, style: AppText.lore),
                const SizedBox(height: 20),
                _actionButton(c, defeated),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(AlbumController c, bool defeated) {
    if (!defeated) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await c.toggleDefeated(widget.boss.id);
            setState(() => _playReveal = true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('⚔️ Marcar como derrotado',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      );
    }
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.gold),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('✓ Conquista registrada',
              style: TextStyle(
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      ),
      TextButton(
        onPressed: () => c.toggleDefeated(widget.boss.id),
        child: const Text('Desmarcar',
            style: TextStyle(color: Color(0xFF6B5D44), fontSize: 12)),
      ),
    ]);
  }
}

class _CollapsedTitle extends StatelessWidget {
  const _CollapsedTitle({required this.boss});
  final Boss boss;
  @override
  Widget build(BuildContext context) {
    // Only meaningful when collapsed; SliverAppBar shows it pinned.
    return Text(boss.name,
        style: const TextStyle(
            color: AppColors.goldLight, fontSize: 16,
            fontWeight: FontWeight.w800));
  }
}
```

- [ ] **Step 4: Wire the album to open the sheet by default**

Modify `lib/presentation/album/album_screen.dart` — change the `onBossTap` fallback from a no-op to `BossSheet.show`. Replace the import block and the tap line:

Add import at top:
```dart
import '../boss/boss_sheet.dart';
```

Change:
```dart
onBossTap: (boss) => onBossTap?.call(context, boss),
```
to:
```dart
onBossTap: (boss) =>
    (onBossTap ?? (ctx, b) => BossSheet.show(ctx, b)).call(context, boss),
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/presentation/boss_sheet_test.dart`
Expected: PASS.

- [ ] **Step 6: Run the full suite**

Run: `flutter test`
Expected: all tests PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/boss/boss_sheet.dart lib/presentation/album/album_screen.dart test/presentation/boss_sheet_test.dart
git commit -m "feat: BossSheet assembling hero/map/combat/loot/lore + reveal, wired to album"
```

---

## Task 13: App entry point — wire it all together + run

**Files:**
- Modify: `lib/main.dart`
- Test: `test/app_smoke_test.dart`

**Interfaces:**
- Consumes: `AlbumController`, `BossRepository`, `ProgressStore`, `AlbumScreen`.
- Produces: `main()` that provides an initialized `AlbumController` and shows `AlbumScreen`.

- [ ] **Step 1: Write the failing smoke test**

Create `test/app_smoke_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elden_world_cup/data/boss_repository.dart';
import 'package:elden_world_cup/data/progress_store.dart';
import 'package:elden_world_cup/state/album_controller.dart';
import 'package:elden_world_cup/presentation/album/album_screen.dart';

const _json = '''
{"regions":[{"id":"limgrave","name":"Limgrave","order":1}],
 "bosses":[{"id":"margit","name":"Margit","region":"limgrave","art":"a.webp",
   "locationName":"loc","mapCoord":{"x":0.1,"y":0.2},"lore":"l"}]}''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('app boots into album with content', (tester) async {
    final c = AlbumController(
        repo: BossRepository.withLoader((_) async => _json),
        store: ProgressStore());
    await c.init();

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: c,
      child: const MaterialApp(home: AlbumScreen()),
    ));
    await tester.pump();

    expect(find.text('⚔️ Elden Album'), findsOneWidget);
    expect(find.text('MARGIT'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/app_smoke_test.dart`
Expected: FAIL until `main.dart` compiles with the new imports (it will pass once Step 3's symbols exist; the test itself doesn't import main, so it mainly guards the wiring contract).

- [ ] **Step 3: Implement `main.dart`**

Replace `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/boss_repository.dart';
import 'data/progress_store.dart';
import 'state/album_controller.dart';
import 'presentation/album/album_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EldenAlbumApp());
}

class EldenAlbumApp extends StatelessWidget {
  const EldenAlbumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AlbumController(repo: BossRepository(), store: ProgressStore())
            ..init(),
      child: MaterialApp(
        title: 'Elden Album',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.gold, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: const AlbumScreen(),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the smoke test and full suite**

Run: `flutter test`
Expected: all tests PASS.

- [ ] **Step 5: Static analysis**

Run: `flutter analyze`
Expected: "No issues found!" (fix any lints surfaced — e.g. unused imports).

- [ ] **Step 6: Boot the app to confirm it runs**

Run: `flutter run -d <device>` (or your simulator/emulator). Verify: the album loads with regions and slots; tapping a slot opens the sheet; the map starts locked; "Marcar como derrotado" plays the reveal and the slot turns colored.

> If no device is available in this environment, note it in the delivery report and rely on the widget tests as the verification of behavior.

- [ ] **Step 7: Commit**

```bash
git add lib/main.dart test/app_smoke_test.dart
git commit -m "feat: wire app entry point (provider + AlbumScreen)"
```

---

## Task 14: Dev-only coordinate picker tool

**Files:**
- Create: `lib/dev/coord_picker_screen.dart`
- Test: none (dev tool; manual use)

**Interfaces:**
- Consumes: theme.
- Produces: `class CoordPickerScreen extends StatelessWidget` — shows `assets/images/map/base_map.webp` in a `LayoutBuilder`; on tap, computes relative `(x,y)` = `(localPosition.dx / width, localPosition.dy / height)` and shows it in a `SnackBar` + prints via `debugPrint`. Not referenced from `main.dart`.

- [ ] **Step 1: Implement `coord_picker_screen.dart`**

Create `lib/dev/coord_picker_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../presentation/theme/app_theme.dart';

/// DEV-ONLY: tap the base map to read a boss's relative (x,y) coordinate.
/// Not wired into the shipped app. To use temporarily, set
/// `home: const CoordPickerScreen()` in main.dart.
class CoordPickerScreen extends StatelessWidget {
  const CoordPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Coord Picker (dev)')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapDown: (details) {
              final x = (details.localPosition.dx / constraints.maxWidth)
                  .clamp(0.0, 1.0);
              final y = (details.localPosition.dy / constraints.maxHeight)
                  .clamp(0.0, 1.0);
              final text =
                  '"mapCoord": { "x": ${x.toStringAsFixed(3)}, "y": ${y.toStringAsFixed(3)} }';
              debugPrint(text);
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(SnackBar(content: Text(text)));
            },
            child: Image.asset('assets/images/map/base_map.webp',
                fit: BoxFit.cover,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                errorBuilder: (_, __, ___) => const Center(
                    child: Text('base_map.webp ausente (placeholder)',
                        style: TextStyle(color: AppColors.textMuted)))),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/dev/coord_picker_screen.dart`
Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/dev/coord_picker_screen.dart
git commit -m "feat: dev-only coordinate picker tool for map curation"
```

---

## Task 15: Finalize the delivery report

**Files:**
- Modify: `docs/superpowers/DELIVERY_REPORT.md`

- [ ] **Step 1: Fill in the "What I need from you" section**

Update `docs/superpowers/DELIVERY_REPORT.md` to reflect the finished state. It must list, concretely:

```markdown
## What I need from you (to reach 100%)

### Assets
- [ ] **Boss art (portrait ~3:4)** for each boss. Currently ALL bosses render
      `assets/images/malenia.webp` as a placeholder. Drop each file in
      `assets/images/` and set its path in `assets/bosses.json` → `art`.
- [ ] **Base map image** at `assets/images/map/base_map.webp` (high-res,
      single image of the Elden Ring map). Until provided, preview/fullscreen
      show a neutral fallback.
- [ ] **Loot icons** in `assets/images/loot/` and their paths in each boss's
      `loot[].icon` (optional — falls back to 💎 emoji).

### Content curation (in `assets/bosses.json`)
- [ ] Replace placeholder **lore**, **subtitles**, **strongVs/weakTo**, and
      **locationName** with accurate values.
- [ ] Set real **mapCoord (x,y)** per boss using the dev coordinate picker
      (`lib/dev/coord_picker_screen.dart` — see its header to enable).
- [ ] Add the remaining bosses to grow from ~12 toward the full roster.

### Decisions / legal
- [ ] Confirm licensing approach for boss art, map image, and lore (fan
      project vs. original art). See the design spec's risk note.

### Environment
- [ ] If `flutter run` could not be executed in the build environment, run it
      once on a device/emulator to confirm the live flow.
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/DELIVERY_REPORT.md
git commit -m "docs: finalize delivery report (placeholders + what's needed)"
```

---

## Notes for the implementer

- **Run `flutter test` after each task** — the suite is fast and catches regressions across layers.
- **Never block on a missing asset.** Every `Image.asset` in this plan already has an `errorBuilder` fallback. If you hit a missing asset that would block, add a fallback + a delivery-report line; do not stop.
- **Keep files focused.** If a widget file grows past its single responsibility, split it (per the project's widget-organization rule: a widget worth being its own thing gets its own file).
- **Commit per task** (the steps already do this). Do not squash unrelated work.
