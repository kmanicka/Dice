# 🎨 UI Updates - Bottom Bar & Settings

## Changes Made

### 1. ✅ Separate Sound and Haptics Toggles

**Before:**
- Single toggle: "Sound & Haptics" (🔊 Enabled / 🔇 Disabled)
- Both controlled together

**After:**
- **Sound**: 🔊 Enabled / 🔇 Disabled
- **Haptics**: 📳 Enabled / Disabled
- Independent controls

### 2. ✅ Centered Roll Button

**Before:**
- Roll button on right side of bottom bar
- Settings button on left side

**After:**
- **Roll button** centered in bottom bar
- More prominent and accessible

### 3. ✅ Icon-Only Settings Button

**Before:**
- Settings button: "⚙️ Settings" (120px wide)
- Left side of bottom bar

**After:**
- Settings button: "⚙️" (50px × 50px, icon only)
- Right side of bottom bar
- More compact, cleaner look

## Updated Layout

### Bottom Bar

```
┌────────────────────────────┐
│                            │
│        Dice Area           │
│                            │
├────────────────────────────┤
│          🎲 Roll       ⚙️  │
│         (center)    (right)│
└────────────────────────────┘
```

**Layout:**
- **Center**: 🎲 Roll (120px wide, blue button)
- **Right**: ⚙️ (50px × 50px, gray button)
- **Left**: Empty

### Settings Panel (Expanded)

```
┌────────────────────────────┐
│ Settings              ✕   │
│                            │
│ Number of Dice             │
│ [1 Dice    |    2 Dice]    │
│                            │
│ Sound                      │
│ [🔊 Enabled            ]   │
│                            │
│ Haptics                    │
│ [📳 Enabled            ]   │
└────────────────────────────┘
```

**Height:** 310px (increased from 250px)

**Contents:**
1. **Title**: "Settings" with ✕ close button
2. **Number of Dice**: Segmented control
3. **Sound**: Toggle button
4. **Haptics**: Toggle button

## Technical Details

### Settings Button (Updated)

```swift
private func setupSettingsButton() {
    settingsButton = UIButton(type: .system)
    settingsButton.setTitle("⚙️", for: .normal)
    settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
    settingsButton.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
    settingsButton.setTitleColor(.white, for: .normal)
    settingsButton.layer.cornerRadius = 25

    // Position in bottom bar (right side, icon only)
    let buttonSize: CGFloat = 50
    let padding: CGFloat = 20
    settingsButton.frame = CGRect(
        x: view.bounds.width - buttonSize - padding,
        y: 15,
        width: buttonSize,
        height: buttonSize
    )
}
```

### Throw Button (Updated)

```swift
private func setupThrowButton() {
    throwButton = UIButton(type: .system)
    throwButton.setTitle("🎲 Roll", for: .normal)
    // ... styling ...

    // Position in bottom bar (centered)
    let buttonWidth: CGFloat = 120
    let buttonHeight: CGFloat = 50
    throwButton.frame = CGRect(
        x: (view.bounds.width - buttonWidth) / 2,  // Centered
        y: 15,
        width: buttonWidth,
        height: buttonHeight
    )
    throwButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
}
```

### Sound Toggle (New)

```swift
private func setupSoundToggle() {
    soundToggle = UIButton(type: .system)
    updateSoundToggleAppearance()
    soundToggle.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    soundToggle.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.3, alpha: 1.0)
    soundToggle.setTitleColor(.white, for: .normal)
    soundToggle.layer.cornerRadius = 18
    soundToggle.contentHorizontalAlignment = .left
    soundToggle.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

    soundToggle.frame = CGRect(x: 20, y: 170, width: view.bounds.width - 40, height: 36)
    soundToggle.addTarget(self, action: #selector(toggleSound), for: .touchUpInside)
}
```

### Haptics Toggle (New)

```swift
private func setupHapticsToggle() {
    hapticsToggle = UIButton(type: .system)
    updateHapticsToggleAppearance()
    // ... same styling as sound toggle ...

    hapticsToggle.frame = CGRect(x: 20, y: 230, width: view.bounds.width - 40, height: 36)
    hapticsToggle.addTarget(self, action: #selector(toggleHaptics), for: .touchUpInside)
}
```

### Toggle Actions (Updated)

```swift
@objc private func toggleSound() {
    soundEnabled.toggle()
    updateSoundToggleAppearance()
    print("🔊 Sound toggled: \(soundEnabled)")
}

@objc private func toggleHaptics() {
    hapticsEnabled.toggle()
    updateHapticsToggleAppearance()
    print("📳 Haptics toggled: \(hapticsEnabled)")
}

private func updateSoundToggleAppearance() {
    if soundEnabled {
        soundToggle.setTitle("🔊  Enabled", for: .normal)
    } else {
        soundToggle.setTitle("🔇  Disabled", for: .normal)
    }
}

private func updateHapticsToggleAppearance() {
    if hapticsEnabled {
        hapticsToggle.setTitle("📳  Enabled", for: .normal)
    } else {
        hapticsToggle.setTitle("  Disabled", for: .normal)
    }
}
```

## Settings Panel Positioning (Updated)

```swift
@objc private func toggleSettings() {
    settingsPanelVisible.toggle()

    // Panel height: 310px, bottom bar height: 80px
    let panelY = settingsPanelVisible
        ? view.bounds.height - 310 - 80  // Show above bottom bar
        : view.bounds.height              // Hide off-screen

    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
        self.settingsPanel.frame.origin.y = panelY
    }
}
```

## User Experience

### Independent Controls

**Sound Only:**
```
User disables sound
   ↓
Sound: 🔇 Disabled
Haptics: 📳 Enabled (still on)
   ↓
Next throw: Vibration only, no sound
```

**Haptics Only:**
```
User disables haptics
   ↓
Sound: 🔊 Enabled (still on)
Haptics: Disabled
   ↓
Next throw: Sound only, no vibration
```

**Both Disabled:**
```
User disables both
   ↓
Sound: 🔇 Disabled
Haptics: Disabled
   ↓
Next throw: Silent and no vibration
```

### Button Layout Benefits

**Centered Roll Button:**
- More prominent
- Easier to reach with thumb
- Primary action highlighted
- Balanced layout

**Icon-Only Settings:**
- More compact (50px vs 120px)
- Less screen real estate
- Still easily identifiable
- Modern, clean look

## Spacing and Positioning

### Settings Panel Layout

```
Top:    20px padding
Title:  30px height
Gap:    20px

Dice Count Section:
  Label:   y: 70px
  Toggle:  y: 95px, height: 36px
  Gap:     14px

Sound Section:
  Label:   y: 145px
  Toggle:  y: 170px, height: 36px
  Gap:     14px

Haptics Section:
  Label:   y: 205px
  Toggle:  y: 230px, height: 36px
  Bottom:  44px padding

Total: 310px
```

### Bottom Bar Layout

```
Height: 80px

Settings Button (right):
  x: view.width - 50 - 20
  y: 15
  size: 50×50

Roll Button (center):
  x: (view.width - 120) / 2
  y: 15
  size: 120×50
```

## Benefits

✅ **Granular Control** - Sound and haptics can be toggled independently
✅ **Centered Action** - Primary button (Roll) more prominent
✅ **Cleaner Layout** - Icon-only settings button saves space
✅ **More Settings Space** - Can easily add more options
✅ **Better UX** - Users can disable just sound or just haptics

## Console Output

**Toggle Sound:**
```
🔊 Sound toggled: false
```

**Toggle Haptics:**
```
📳 Haptics toggled: false
```

**Throw with Sound Off, Haptics On:**
```
🎲 ========== THROW INITIATED (1 dice) ==========
(Vibration plays, no sound)
```

**Throw with Sound On, Haptics Off:**
```
🎲 ========== THROW INITIATED (1 dice) ==========
(Sound plays, no vibration)
```

## Summary

✅ **Separate toggles** - Sound and Haptics independent
✅ **Centered Roll button** - More prominent in bottom bar
✅ **Icon-only Settings** - ⚙️ (50×50) on right side
✅ **Taller settings panel** - 310px (from 250px) to fit new toggle
✅ **Better user control** - Disable sound OR haptics individually

The UI is now cleaner, more organized, and provides better control over app features! 🎨
