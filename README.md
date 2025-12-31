# Factlet

A minimalistic iOS app that displays general knowledge factlets on your home screen and lock screen.

## Features

- **Transparent Widget** - Widgets have transparent backgrounds to blend with your wallpaper
- **Light/Dark Text** - Choose white or black text to match your wallpaper
- **Topic Filtering** - Filter factlets by category (Science, History, Nature, etc.)
- **Minimalistic Design** - Clean, elegant UI with Times New Roman typography
- **Customizable Refresh** - Choose how often factlets change: 15 minutes, 30 minutes, hourly, or daily
- **50+ Curated Factlets** - General knowledge facts covering 8 categories

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+

## Installation

1. Open `Factlet.xcodeproj` in Xcode
2. Select your development team in the Signing & Capabilities tab for both targets:
   - Factlet (main app)
   - FactletWidgetExtension
3. Build and run on your device or simulator

## App Group Configuration

The app uses an App Group (`group.com.factlet.app`) to share data between the main app and widget extension. Make sure to:

1. Enable App Groups capability for both targets
2. Use the same App Group identifier in both entitlements files

## Widget Features

### Transparent Background
Widgets have fully transparent backgrounds, allowing your wallpaper to show through.

### Text Color Options
- **Dark Text** - Black text for light wallpapers
- **Light Text** - White text for dark wallpapers

Configure in Settings within the app.

### Widget Sizes
- **Small** - Compact view with category and factlet
- **Medium** - Expanded view with elegant left accent line
- **Large** - Centered layout with branding
- **Lock Screen** - Circular, rectangular, and inline variants

### Topic Filtering
Filter which topics appear in both the app and widgets:
- All (default)
- Science
- History
- Nature
- Language
- Culture
- Human Body
- Geography
- Technology

## Design Philosophy

Factlet follows a minimalistic design approach inspired by the Vocabulary app:

- **Typography**: Times New Roman for a classic, literary feel
- **Colors**: Warm off-white background in the app, transparent widgets
- **Spacing**: Generous whitespace for a calm, focused reading experience
- **Interactions**: Subtle fade animations when refreshing content

## Project Structure

```
Factlet/
├── Factlet.xcodeproj/        # Xcode project file
├── Factlet/                   # Main app target
│   ├── FactletApp.swift      # App entry point
│   ├── ContentView.swift     # Main factlet display + Topics sheet
│   ├── SettingsView.swift    # Refresh interval + text color settings
│   ├── Assets.xcassets/      # App assets
│   └── Info.plist
├── FactletWidget/            # Widget extension target
│   ├── FactletWidget.swift   # Widget views and provider
│   ├── Assets.xcassets/      # Widget assets
│   └── Info.plist
└── Shared/                   # Shared code
    ├── Factlets.swift        # Data model and factlet collection
    └── FactletManager.swift  # State management + categories
```

## Adding More Factlets

Edit `Shared/Factlets.swift` and add new factlets to the `FactletCollection.all` array:

```swift
Factlet(fact: "Your amazing fact here.", category: "Category")
```

Available categories: Science, History, Nature, Language, Culture, Human Body, Geography, Technology

## License

MIT License - Feel free to use and modify for your own projects.
