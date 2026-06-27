# Mobile-width frame on web

## Problem

The app was designed for phone proportions (narrow portrait). On a desktop
browser the window is much wider, so layouts stretch and look wrong.

## Goal

On web, contain the app in a centered phone-width column, with the side
margins filled by the app background color. On native mobile (Android/iOS),
nothing changes.

## Approach

A single wrapping widget plugged into `MaterialApp.builder`, so every screen
— including those pushed via `Navigator` (BossDetails, FullscreenMap, Search)
— inherits the frame without touching any individual screen.

### `MobileFrame` widget

New file: `lib/app/mobile_frame.dart`.

```dart
class MobileFrame extends StatelessWidget {
  const MobileFrame({super.key, required this.child, this.isWeb = kIsWeb});

  final Widget child;
  final bool isWeb; // injectable so both paths are testable

  static const double maxWidth = 430; // iPhone Pro Max logical px

  @override
  Widget build(BuildContext context) {
    if (!isWeb) return child;
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

- `!isWeb` → returns `child` untouched. `kIsWeb` is a compile-time constant,
  so the native build is identical to today.
- Web → centered `ConstrainedBox` (max 430px) over `AppColors.background`,
  with a subtle 15%-opacity gold vertical border for finish.

### Wiring

In `lib/main.dart`, add to the `MaterialApp`:

```dart
builder: (context, child) => MobileFrame(child: child!),
```

The `builder` wraps the `MaterialApp`'s internal `Navigator`, so all pushed
routes are contained too.

## Testing

`test/app/mobile_frame_test.dart`:

- With `isWeb: true`, the child is wrapped in a `ConstrainedBox` whose
  `maxWidth` is 430.
- With `isWeb: false`, the widget returns the child directly (no
  `ConstrainedBox` constraint applied by the frame).

## Out of scope

- No per-screen responsive layout (no multi-column grids on desktop).
- No phone "bezel"/notch chrome — just a width limit and a subtle border.
- Width (430) and border are easy to tweak after seeing it live.
