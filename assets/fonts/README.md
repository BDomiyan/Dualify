# Font Assets

This directory contains the custom fonts used in the Dualify Dashboard application.

## Font Families

### Manrope (Main App Font)
- **Usage**: Primary font for the entire application
- **Weights Available**:
  - Regular (400): `Manrope-Regular.ttf`
  - Medium (500): `Manrope-Medium.ttf`
  - Bold (700): `Manrope-Bold.ttf`
  - ExtraBold (800): `Manrope-ExtraBold.ttf`
- **Source**: [Google Fonts - Manrope](https://fonts.google.com/specimen/Manrope)

### Fredoka One (Login Screen Title)
- **Usage**: Login screen title "Dualify" with text shadow effect
- **Weights Available**:
  - Regular (400): `FredokaOne-Regular.ttf`
- **Source**: [Google Fonts - Fredoka One](https://fonts.google.com/specimen/Fredoka+One)

### Lexend (Login Screen Body)
- **Usage**: Login screen body text and descriptions
- **Weights Available**:
  - Regular (400): `Lexend-Regular.ttf`
- **Source**: [Google Fonts - Lexend](https://fonts.google.com/specimen/Lexend)

## Configuration

The fonts are configured in `pubspec.yaml` under the `flutter.fonts` section with proper weight mappings.

## Usage in Code

```dart
// Manrope font family (main app font)
TextStyle(
  fontFamily: 'Manrope',
  fontWeight: FontWeight.w400, // or w500, w700, w800
)

// Fredoka One font family (login title)
TextStyle(
  fontFamily: 'Fredoka One',
  fontWeight: FontWeight.w400,
)

// Lexend font family (login body text)
TextStyle(
  fontFamily: 'Lexend',
  fontWeight: FontWeight.w400,
)
```

## Installation Notes

**Important**: The current font files are placeholders. In a production environment, you need to:

1. Download the actual font files from Google Fonts
2. Replace the placeholder files with the real TTF files
3. Ensure proper licensing compliance

## Testing

Use the `FontTestWidget` in `lib/core/theme/font_test.dart` to verify all fonts load correctly during development.