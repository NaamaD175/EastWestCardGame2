# EastWestCardGame2

An iOS card game built with Swift and UIKit.  
**Student:** Naama  
**Assignment:** iOS Development – Exercise 2

---

## About the Game

Two players compete in real time using their physical location to determine which side they play on — **East** or **West** — relative to a fixed longitude point in Israel.

Each round, two cards are revealed simultaneously. The player with the higher card wins the round. After **10 rounds**, the player with more points wins. Ties go to the house (computer).

---

## Features

### Core (Exercise 1)
- **Location-based side assignment** — GPS determines East or West side on every app launch
- **Name entry** — first launch shows an "Insert Name" button; subsequent launches show a greeting
- **Game cannot start** without both a name and a confirmed location
- **Automatic gameplay** — no buttons during the game; cards reveal every 5 seconds, shown for 3 seconds
- **Scoring** — updates after every round
- **Result screen** — shows the winner and final score, with a button to return to the main menu

### New (Exercise 2)
- **Dark Mode** — globe images switch to night versions, text becomes light on all screens
- **Portrait support** — home screen adapts correctly to portrait and landscape orientations
- **Sound effects** — card flip sound on each reveal; victory/lose sounds per round
- **End-game sounds** — victory or lose sound plays on the result screen
- **Background music** — loops during gameplay, pauses when the app goes to background, stops when leaving the game

---

## Screens

| Screen | Description |
|--------|-------------|
| **Home** | Name entry, GPS location, side display, START button |
| **Battle** | Card game — automatic rounds, live score, countdown timer |
| **Result** | Winner, final score, back to menu |

---

## Technical Details

- **Language:** Swift 5
- **UI:** UIKit + Storyboard (with programmatic Auto Layout for adaptive screens)
- **Location:** CoreLocation — single location request per session, stopped after first result
- **Audio:** AVFoundation via a shared `SoundManager` singleton
- **Lifecycle:** Timer pauses on `willResignActive`, resumes on `didBecomeActive`
- **Screen stack:** Home → Battle (modal) → Result (modal). Dismissing from Result tears down the full stack in one call.
- **Orientation:** Home supports portrait + landscape. Battle and Result are landscape-only.

---

## How to Run

1. Clone the repository
2. Open `EastWestCardGame.xcodeproj` in Xcode
3. Select a simulator or device
4. Build and run (`⌘R`)

> To test location in the simulator:  
> **Features → Location → Custom Location**  
> Use longitude > `34.817549` for East, or < `34.817549` for West.

> To test Dark Mode in the simulator:  
> **Features → Toggle Appearance** (`⇧⌘A`)

---

## Project Structure

```
EastWestCardGame/
├── HomeViewController.swift       # Home screen: name, location, globe UI
├── BattleViewController.swift     # Game screen: card logic, timer, scoring
├── ResultViewController.swift     # Result screen: winner display
├── RoundTimer.swift               # Countdown timer with delegate
├── SoundManager.swift             # Audio manager (music + effects)
├── Helpers.swift                  # String validation helpers
├── Assets.xcassets/               # Card images, globe images (day + night)
├── backgroundMusic.mp3
├── flipCard.mp3
├── victorySound.mp3
└── loseGame.mp3
```

---

## Screenshots

> *(Add screenshots here)*

---

## Video

> *(Add a link to the demo video here)*
