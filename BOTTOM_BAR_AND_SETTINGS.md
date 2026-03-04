# 📊 Bottom Bar & Settings Panel

## Overview

Redesigned the UI with a **bottom bar** for primary actions and a **slide-up settings panel** for configuration options.

## Features

✅ **Bottom Bar** - Fixed bar at the bottom with primary buttons
✅ **Settings Panel** - Slide-up panel with all settings
✅ **Clean Layout** - No floating buttons cluttering the screen
✅ **Smooth Animation** - Settings panel slides in/out
✅ **Modern Design** - Dark theme with rounded corners

## User Interface

### Bottom Bar

**Location**: Fixed at bottom of screen
**Height**: 80px
**Background**: Dark translucent (rgba: 0.1, 0.1, 0.15, 0.95)
**Border**: Subtle white line on top

**Buttons:**
- **Left**: ⚙️ Settings (120px wide, gray)
- **Right**: 🎲 Roll (120px wide, blue)

### Settings Panel

**Location**: Slides up from bottom
**Height**: 250px
**Background**: Dark (rgba: 0.15, 0.15, 0.2, 0.98)
**Corner Radius**: 20px (top corners only)
**Shadow**: Subtle shadow for depth

**Contents:**
- **Title**: "Settings" (bold, 24pt)
- **Close Button**: ✕ (top-right)
- **Dice Count Section**:
  - Label: "Number of Dice"
  - Segmented Control: [1 Dice | 2 Dice]
- **Effects Section**:
  - Label: "Sound & Haptics"
  - Toggle Button: 🔊 Enabled / 🔇 Disabled

## Layout

```
┌────────────────────────────┐
│                            │
│      🎲    or    🎲  🎲    │
│     (1 dice)   (2 dice)    │
│                            │
│         (Dice area)        │
│                            │
├────────────────────────────┤  ← Settings Panel (slides up)
│ Settings              ✕   │
│                            │
│ Number of Dice             │
│ [1 Dice    |    2 Dice]    │
│                            │
│ Sound & Haptics            │
│ [🔊 Enabled            ]   │
└────────────────────────────┘
├────────────────────────────┤  ← Bottom Bar (always visible)
│ ⚙️ Settings    🎲 Roll    │
└────────────────────────────┘
```

## Technical Implementation

### Bottom Bar Setup

```swift
private func setupBottomBar() {
    let barHeight: CGFloat = 80
    bottomBar = UIView(frame: CGRect(
        x: 0,
        y: view.bounds.height - barHeight,
        width: view.bounds.width,
        height: barHeight
    ))
    bottomBar.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.95)
    bottomBar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]

    // Add subtle top border
    let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 1))
    topBorder.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    bottomBar.addSubview(topBorder)

    view.addSubview(bottomBar)

    setupThrowButton()
    setupSettingsButton()
}
```

### Throw Button (in Bottom Bar)

```swift
private func setupThrowButton() {
    throwButton = UIButton(type: .system)
    throwButton.setTitle("🎲 Roll", for: .normal)
    throwButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    throwButton.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
    throwButton.setTitleColor(.white, for: .normal)
    throwButton.layer.cornerRadius = 25
    throwButton.layer.shadowColor = UIColor.black.cgColor
    throwButton.layer.shadowOffset = CGSize(width: 0, height: 2)
    throwButton.layer.shadowRadius = 4
    throwButton.layer.shadowOpacity = 0.3

    // Position in bottom bar (right side)
    let buttonWidth: CGFloat = 120
    let buttonHeight: CGFloat = 50
    let padding: CGFloat = 20
    throwButton.frame = CGRect(
        x: view.bounds.width - buttonWidth - padding,
        y: 15,
        width: buttonWidth,
        height: buttonHeight
    )
}
```

### Settings Button (in Bottom Bar)

```swift
private func setupSettingsButton() {
    settingsButton = UIButton(type: .system)
    settingsButton.setTitle("⚙️ Settings", for: .normal)
    settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    settingsButton.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
    settingsButton.setTitleColor(.white, for: .normal)
    settingsButton.layer.cornerRadius = 25

    // Position in bottom bar (left side)
    let buttonWidth: CGFloat = 120
    let buttonHeight: CGFloat = 50
    let padding: CGFloat = 20
    settingsButton.frame = CGRect(
        x: padding,
        y: 15,
        width: buttonWidth,
        height: buttonHeight
    )
}
```

### Settings Panel Setup

```swift
private func setupSettingsPanel() {
    let panelHeight: CGFloat = 250
    settingsPanel = UIView(frame: CGRect(
        x: 0,
        y: view.bounds.height,  // Start off-screen
        width: view.bounds.width,
        height: panelHeight
    ))
    settingsPanel.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 0.98)
    settingsPanel.layer.cornerRadius = 20
    settingsPanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    settingsPanel.layer.shadowColor = UIColor.black.cgColor
    settingsPanel.layer.shadowOffset = CGSize(width: 0, height: -4)
    settingsPanel.layer.shadowRadius = 8
    settingsPanel.layer.shadowOpacity = 0.4

    view.addSubview(settingsPanel)

    // Add title, close button, and settings controls
    // ...
}
```

### Toggle Settings Panel Animation

```swift
@objc private func toggleSettings() {
    settingsPanelVisible.toggle()

    // Calculate target Y position
    let panelY = settingsPanelVisible
        ? view.bounds.height - 250 - 80  // Above bottom bar
        : view.bounds.height              // Off-screen

    // Animate slide
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
        self.settingsPanel.frame.origin.y = panelY
    }
}
```

## User Experience

### Opening Settings

```
User taps ⚙️ Settings button
   ↓
Settings panel slides up from bottom
   ↓
Animation: 0.3 seconds, ease-in-out
   ↓
Panel appears above bottom bar
   ↓
User can adjust settings
```

### Closing Settings

**Method 1: Close Button**
```
User taps ✕ button (top-right)
   ↓
Settings panel slides down
   ↓
Panel disappears off-screen
```

**Method 2: Settings Button Again**
```
User taps ⚙️ Settings button
   ↓
Settings panel slides down
   ↓
Panel disappears off-screen
```

### Settings Panel Contents

#### Number of Dice Section
- **Label**: "Number of Dice" (16pt, medium weight)
- **Control**: UISegmentedControl
- **Options**: [1 Dice | 2 Dice]
- **Color**: Blue when selected
- **Width**: Full width minus padding (20px each side)

#### Sound & Haptics Section
- **Label**: "Sound & Haptics" (16pt, medium weight)
- **Control**: UIButton (toggle style)
- **States**:
  - Enabled: "🔊 Enabled"
  - Disabled: "🔇 Disabled"
- **Width**: Full width minus padding

### Throwing Dice

```
User taps 🎲 Roll button
   ↓
Button scales down (0.95x)
Background darkens
   ↓
Haptics play (if enabled)
Sound plays (if enabled)
   ↓
Dice throw physics applied
   ↓
Button returns to normal
Dice tumble and settle
```

## Visual Design

### Color Scheme

**Bottom Bar:**
- Background: Dark blue-gray (0.1, 0.1, 0.15, 0.95)
- Border: White 20% opacity

**Buttons:**
- Roll: Blue (0.2, 0.5, 0.9)
- Settings: Gray (0.3, 0.3, 0.35)
- Text: White

**Settings Panel:**
- Background: Darker (0.15, 0.15, 0.2, 0.98)
- Title: White
- Labels: White 80% opacity
- Controls: Dark background with blue accents

### Typography

- **Settings Title**: 24pt, Bold
- **Button Text**: 18pt, Semibold/Medium
- **Labels**: 16pt, Medium
- **Control Text**: 16pt, Regular

### Spacing

- **Bottom Bar**:
  - Height: 80px
  - Padding: 20px sides
  - Button spacing: 15px from top/bottom

- **Settings Panel**:
  - Height: 250px
  - Padding: 20px all sides
  - Element spacing: 10px vertical
  - Control height: 36px

## State Management

### Properties

```swift
private var bottomBar: UIView!
private var throwButton: UIButton!
private var settingsButton: UIButton!

private var settingsPanel: UIView!
private var settingsPanelVisible: Bool = false
private var diceCountToggle: UISegmentedControl!
private var effectsToggle: UIButton!
```

### Initial State

- Bottom bar: Visible
- Settings panel: Hidden (off-screen)
- Dice count: 1 dice
- Effects: Enabled

## Animation Details

### Settings Panel Slide

**Duration**: 0.3 seconds
**Curve**: Ease-in-out
**Property**: frame.origin.y

**Positions:**
- Hidden: `view.bounds.height` (off-screen)
- Visible: `view.bounds.height - 250 - 80` (above bottom bar)

**Shadow**: Follows panel (creates depth illusion)

## Benefits

✅ **Cleaner UI** - No floating buttons blocking view
✅ **Organized** - All settings in one place
✅ **Accessible** - Easy to find and use
✅ **Modern** - Slide-up panel pattern (iOS standard)
✅ **Flexible** - Easy to add more settings
✅ **Professional** - Polished appearance

## Interaction Flow

### Initial View
```
┌────────────────────────────┐
│                            │
│         Dice Area          │
│                            │
├────────────────────────────┤
│ ⚙️ Settings    🎲 Roll    │
└────────────────────────────┘
```

### Settings Open
```
┌────────────────────────────┐
│                            │
│      (Less dice area)      │
├────────────────────────────┤
│ Settings              ✕   │
│ Number of Dice             │
│ [1 Dice    |    2 Dice]    │
│ Sound & Haptics            │
│ [🔊 Enabled            ]   │
├────────────────────────────┤
│ ⚙️ Settings    🎲 Roll    │
└────────────────────────────┘
```

## Console Output

**Opening Settings:**
```
⚙️ Settings panel shown
```

**Closing Settings:**
```
⚙️ Settings panel hidden
```

**Changing Settings:**
```
🔄 Dice count changed to: 2
🔊 Effects toggled: sound=false, haptics=false
```

## Future Enhancements

Possible additions:
- More settings options
- Swipe down to close panel
- Tap outside panel to close
- Settings icon badge for notifications
- Separate sound and haptics toggles
- Dice color/theme selector
- Animation speed slider

## Summary

✅ **Bottom Bar** - Fixed bar with Roll and Settings buttons
✅ **Settings Panel** - Slide-up panel for all settings
✅ **Clean Layout** - No floating buttons
✅ **Smooth Animation** - 0.3s ease-in-out
✅ **All Settings Organized** - Dice count and effects in one place
✅ **Modern Design** - Dark theme with rounded corners

The dice app now has a professional, organized UI with all settings easily accessible! 📊
