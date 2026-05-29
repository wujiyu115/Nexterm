# Outdoor Tech Fusion UI Restyle

## Decisions

- **Navigation**: Keep current 3-tab structure (Vaults/Terminal/Settings). Do NOT flatten to 6 tabs.
- **Decorative elements**: Implement ALL (topographic contours, film grain noise, mountain ridge, glow orbs).
- **Themes**: Both dark and light themes per design spec.
- **Functionality**: Zero changes. Style and layout only.

## Source of Truth

Design spec: `设计稿/terminal-pro-design-spec.md`
HTML prototype: `设计稿/terminal-pro-ios.html`

## Color System

| Token | Dark | Light | Usage |
|-------|------|-------|-------|
| accent | `#5cb85c` | `#5cb85c` | Global green accent |
| bg | `#0d1117` | `#f5f0e6` | Page background |
| bg-elevated | `#161b22` | `#faf8f3` | Elevated surface |
| surface | `rgba(22,27,34,0.78)` | `rgba(255,255,255,0.78)` | Semi-transparent panels |
| fg | `#e6edf3` | `#1a1a1a` | Primary text |
| fg-secondary | `#8b949e` | `#6b7280` | Secondary text |
| card-bg | `rgba(22,27,34,0.65)` | `rgba(255,255,255,0.65)` | Glassmorphism card bg |
| input-bg | `rgba(30,36,44,0.8)` | `rgba(0,0,0,0.04)` | Input field bg |
| border | `rgba(48,54,61,0.6)` | `rgba(0,0,0,0.08)` | Borders |
| glass-border | `rgba(92,184,92,0.08)` | `rgba(92,184,92,0.12)` | Card glass border |

## Component Styles

1. **Cards**: Semi-transparent bg + blur(12px) + green glass border + diagonal gradient sheen + scale(0.98) on press
2. **Nav title**: 34px/700 + bottom green gradient line
3. **Section labels**: 13px/600 uppercase green + glowing vertical bar
4. **Status indicators**: Green with glow + pulse ring animation
5. **Icon containers**: accent-dim background + diagonal light reflection
6. **Search bar**: input-bg + blur(8px) + border
7. **Forms**: input-bg + border + green focus ring
8. **Terminal**: Grid background overlay, green cursor, prompt colors per spec

## Decorative Layers (on app scaffold background)

1. **Topographic contours**: SVG ellipses rendered as CustomPaint or static SVG, 3.5% dark / 6% light opacity
2. **Film grain**: Noise texture overlay, 25% dark / 15% light, overlay blend mode
3. **Mountain ridge**: SVG polygon silhouettes above tab bar, 4% dark / 6% light
4. **Ambient glows**: 3 radial gradients (top-right green, bottom-left green, mid-right blue)

## Implementation Strategy

Bottom-up:
1. Theme layer (AppTheme colors, fonts, radius tokens)
2. Shared decorative background widget (contours + noise + glows + ridge)
3. Component-level styles (cards, list tiles, search, forms, nav headers)
4. Screen-by-screen application

## Files to Modify

- `lib/core/theme/app_theme.dart` — complete color rewrite
- `lib/core/theme/theme_provider.dart` — keep as-is (light/dark/system logic unchanged)
- `lib/shared/widgets/app_scaffold.dart` — add decorative background layers
- All `ui/` screen files — apply new card/component styles
- All `ui/widgets/` — restyle individual components
