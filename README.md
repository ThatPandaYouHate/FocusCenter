# Focus Center

En iOS-app med fokus-spel designade för att hjälpa dig koncentrera dig på ljudinnehåll som poddar, ljudböcker och artiklar.

## Spel

- **Patiens** (Klondike) - Draw 1 och Draw 3
- **Minesweeper** - Nybörjare, Medel, Expert
- **2048** - Klassiska swipe-spelet
- **Nonogram** - Pixelpussel (5x5, 10x10, 15x15)

## Krav

- Xcode 15+
- iOS 17.0+
- Swift 5.9+

## Komma igång

### Alternativ 1: XcodeGen (rekommenderat)

```bash
brew install xcodegen  # om ej installerat
xcodegen generate
open FocusCenter.xcodeproj
```

### Alternativ 2: Öppna direkt

Om XcodeGen redan körts finns `FocusCenter.xcodeproj` i projektmappen:

```bash
open FocusCenter.xcodeproj
```

Välj en iOS-simulator och tryck Cmd+R för att bygga och köra.

## Lägga till ett nytt spel

1. Skapa en ny mapp under `FocusCenter/Games/DittSpel/`
2. Implementera spelets vy (SwiftUI View)
3. Lägg till en ny case i `GameType` enum (`FocusCenter/Core/GameType.swift`)
4. Kör `xcodegen generate` för att uppdatera projektfilen
