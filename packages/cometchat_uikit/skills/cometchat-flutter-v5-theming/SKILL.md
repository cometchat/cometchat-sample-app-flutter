---
name: cometchat-flutter-v5-theming
description: >
  Use when customizing the visual appearance of CometChat Flutter UIKit v5 components.
  Triggers on mentions of CometChatThemeHelper, CometChatColorPalette, CometChatSpacing,
  CometChatTypography, CometChatThemeMode, dark mode, light mode, theme, colors, styling,
  custom theme, Style class, merge(), getColorPalette, getSpacing, getTypography,
  ThemeExtension, primary color, neutral colors, background colors, text colors, icon colors,
  button colors, border colors, or any CometChat{Component}Style class. Also use when the
  user asks about changing colors, fonts, spacing, or appearance of v5 chat components.
license: "MIT"
compatibility: "cometchat_uikit_shared ^5.2.3; flutter >=2.5.0"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter v5 theme colors typography spacing dark-mode styling"
---

# CometChat Flutter UIKit v5 — Theming & Styling

How to customize the visual appearance of all CometChat v5 components.

## Theme System Architecture

Three layers, resolved via Flutter's `ThemeExtension` system:

1. `CometChatColorPalette` — all colors (primary, extended primary, neutral, alert, background, text, icon, button, border)
2. `CometChatSpacing` — spacing, padding, margin, and radius tokens
3. `CometChatTypography` — text styles (heading1-4, body, caption1-2, button, link, title)

Access via static helpers:
```dart
final colors = CometChatThemeHelper.getColorPalette(context);
final spacing = CometChatThemeHelper.getSpacing(context);
final typography = CometChatThemeHelper.getTypography(context);
```

## Default Resolution Chain

For each color token, `CometChatThemeHelper` resolves in this order:

1. `Theme.of(context).extension<CometChatColorPalette>()?.{token}` — user-provided ThemeExtension
2. Brightness-aware default — light/dark fallback hardcoded in the helper

For spacing: `CometChatSpacing()` defaults merged with `Theme.of(context).extension<CometChatSpacing>()`.

For typography: Each text style class (e.g., `CometChatTextStyleHeading1`) has a static `.of(context)` that resolves from ThemeExtension or returns defaults.

## Applying a Custom Theme

Register `CometChatColorPalette` as a `ThemeExtension` on your `ThemeData`:

```dart
// ✅ CORRECT — register as ThemeExtension
MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    extensions: [
      CometChatColorPalette(
        primary: const Color(0xFF6852D6),
        background1: Colors.white,
        textPrimary: const Color(0xFF141414),
      ),
      CometChatSpacing(
        padding4: 20, // Override default 16
      ),
    ],
  ),
  // ...
)

// ❌ WRONG — trying to pass colors directly to components
CometChatConversations(
  // There is no 'primaryColor' prop — use ThemeExtension
)
```

## Dark Mode

Control via `CometChatThemeMode`:

```dart
// ✅ CORRECT — set before MaterialApp builds
CometChatThemeMode.mode = ThemeMode.dark;

// Or follow system:
CometChatThemeMode.mode = ThemeMode.system;
```

`CometChatThemeHelper.getBrightness(context)` checks `CometChatThemeMode.mode`:
- `ThemeMode.system` → uses `MediaQuery.of(context).platformBrightness`
- `ThemeMode.light` → `Brightness.light`
- `ThemeMode.dark` → `Brightness.dark`

## Color Token Table

| Category | Tokens | Light Default | Dark Default |
|----------|--------|---------------|--------------|
| Primary | `primary` | `#6852D6` | `#604CC3` |
| Extended Primary | `extendedPrimary50`–`900` | Blended with white (96%→11%) | Blended with black (80%→8%) |
| Neutral | `neutral50`–`900` | `#FFFFFF`→`#141414` | `#141414`→`#FFFFFF` |
| Alert | `info` | `#0B7BEA` | `#0D66BF` |
| Alert | `warning` | `#FFAB00` | `#D08D04` |
| Alert | `error` | `#F44649` | `#C73C3E` |
| Alert | `success` | `#09C26F` | `#0B9F5D` |
| Alert | `error100` | `#F9EAEF` | `#3A0C05` |
| Background | `background1`–`4` | neutral50→neutral300 | neutral50→neutral300 |
| Text | `textPrimary` | neutral900 | neutral900 |
| Text | `textSecondary` | neutral600 | neutral600 |
| Text | `textTertiary` | neutral500 | neutral500 |
| Text | `textDisabled` | neutral400 | neutral400 |
| Text | `textWhite` | neutral50 | neutral50 |
| Text | `textHighlight` | primary | primary |
| Border | `borderLight` | neutral200 | neutral200 |
| Border | `borderDefault` | neutral300 | neutral300 |
| Border | `borderDark` | neutral400 | neutral400 |
| Border | `borderHighlight` | primary | primary |
| Icon | `iconPrimary` | neutral900 | neutral900 |
| Icon | `iconSecondary` | neutral500 | neutral500 |
| Icon | `iconTertiary` | neutral400 | neutral400 |
| Icon | `iconWhite` | neutral50 | neutral50 |
| Icon | `iconHighlight` | primary | primary |
| Button | `buttonBackground` | primary | primary |
| Button | `secondaryButtonBackground` | neutral900 | neutral900 |
| Button | `buttonIconColor`, `buttonText` | `#FFFFFF` | `#FFFFFF` |
| Button | `secondaryButtonIcon`, `secondaryButtonText` | neutral900 | neutral900 |
| Special | `white` | `Colors.white` | `Colors.white` |
| Special | `black` | `Colors.black` | `Colors.black` |
| Special | `messageSeen` | `#56E8A7` | `#56E8A7` |

## Spacing Tokens

`CometChatSpacing` provides spacing, padding, margin, and radius tokens:

| Token | Default Value |
|-------|--------------|
| `spacing` / `padding` / `margin` / `radius` | 2 |
| `spacing1` / `padding1` / `margin1` / `radius1` | 4 |
| `spacing2` / `padding2` / `margin2` / `radius2` | 8 |
| `spacing3` / `padding3` / `margin3` / `radius3` | 12 |
| `spacing4` / `padding4` / `margin4` / `radius4` | 16 |
| `spacing5` / `padding5` / `margin5` / `radius5` | 20 |
| `spacing6` / `padding6` / `margin6` / `radius6` | 24 |
| `spacing7`–`spacing20` / `margin7`–`margin20` | 28–80 (increments of 4) |
| `spacingMax` / `radiusMax` | 1000 |

## Typography Tokens

`CometChatTypography` provides these text styles:

| Token | Class |
|-------|-------|
| `heading1` | `CometChatTextStyleHeading1` |
| `heading2` | `CometChatTextStyleHeading2` |
| `heading3` | `CometChatTextStyleHeading3` |
| `heading4` | `CometChatTextStyleHeading4` |
| `body` | `CometChatTextStyleBody` |
| `caption1` | `CometChatTextStyleCaption1` |
| `caption2` | `CometChatTextStyleCaption2` |
| `button` | `CometChatTextStyleButton` |
| `link` | `CometChatTextStyleLink` |
| `title` | `CometChatTextStyleTitle` |

Each has `.bold`, `.medium`, `.regular` variants accessible as properties.

## Component Style Classes — merge() Pattern

Every component has a `CometChat{Component}Style` that extends `ThemeExtension`. Styles are resolved using `CometChatThemeHelper.getTheme()` and merged with widget-level overrides:

```dart
// ✅ CORRECT — pass style to component
CometChatConversations(
  conversationsStyle: CometChatConversationsStyle(
    backgroundColor: Colors.black,
    titleTextColor: Colors.white,
  ),
)

// Internal resolution (how components resolve styles):
// 1. Get from ThemeExtension: Theme.of(context).extension<CometChatConversationsStyle>()
// 2. Fallback to defaults: CometChatConversationsStyle.of(context)
// 3. Merge with widget prop: .merge(widget.conversationsStyle)
```

### How merge() works internally:

```dart
// Inside component's didChangeDependencies():
style = CometChatThemeHelper.getTheme<CometChatConversationsStyle>(
    context: context,
    defaultTheme: CometChatConversationsStyle.of,
).merge(widget.conversationsStyle);
```

## Gotchas

### `colorPalette.white` is hardcoded
`white`, `black`, and `transparent` on `CometChatColorPalette` have default values (`Colors.white`, `Colors.black`, `Colors.transparent`) that are NOT brightness-aware. They remain the same in both light and dark mode. If you need a brightness-aware "white", use `neutral50` instead.

### Theme caching is critical
Components cache theme in `didChangeDependencies()`. If you call `CometChatThemeHelper.getColorPalette(context)` in `build()`, you'll get jank during keyboard animations because `MediaQuery` changes trigger rebuilds.

```dart
// ✅ CORRECT — cache once
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  colorPalette = CometChatThemeHelper.getColorPalette(context);
  spacing = CometChatThemeHelper.getSpacing(context);
  typography = CometChatThemeHelper.getTypography(context);
}

// ❌ WRONG — in build()
@override
Widget build(BuildContext context) {
  final colorPalette = CometChatThemeHelper.getColorPalette(context); // Jank!
}
```

### Extended primary colors are auto-generated
If you only set `primary`, the extended primary shades (50–900) are automatically generated by blending with white (light mode) or black (dark mode). You can override individual shades via `CometChatColorPalette(extendedPrimary500: ...)`.

## Anti-Patterns

```dart
// ❌ WRONG — hardcoded colors
Container(color: Color(0xFF6852D6))

// ✅ CORRECT — use theme tokens
Container(color: colorPalette.primary)

// ❌ WRONG — hardcoded text styles
Text('Hello', style: TextStyle(fontSize: 16))

// ✅ CORRECT — use typography tokens
Text('Hello', style: typography.body?.regular)
```

## Checklist — Theming

- [ ] Colors from `CometChatThemeHelper.getColorPalette(context)`, never hardcoded
- [ ] Spacing from `CometChatThemeHelper.getSpacing(context)`
- [ ] Typography from `CometChatThemeHelper.getTypography(context)`
- [ ] Theme cached in `didChangeDependencies()`, not `build()`
- [ ] Custom theme registered as `ThemeExtension` on `ThemeData`
- [ ] Dark mode set via `CometChatThemeMode.mode` before MaterialApp builds
- [ ] Component styles passed via constructor props (e.g., `conversationsStyle:`)
