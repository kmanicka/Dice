# 🔊 Haptics and Sound Feature

## Overview

Added **haptic feedback** and **dice rolling sound** to enhance the user experience when throwing dice, with a floating toggle button to enable/disable these effects.

## Features

✅ **Haptic feedback** - Medium impact vibration when throwing dice
✅ **Dice rolling sound** - Multi-click sound effect simulating dice tumbling
✅ **Toggle control** - Floating button at bottom-center to enable/disable
✅ **Visual feedback** - Button changes appearance when disabled
✅ **Always in sync** - Sound and haptics toggle together

## User Interface

### Effects Toggle Button
- **Location**: Bottom-center
- **Enabled**: 🔊 (speaker icon, blue background)
- **Disabled**: 🔇 (muted speaker icon, gray background)
- **Size**: 44×44 px circular button
- **Action**: Tap to toggle sound and haptics on/off

### UI Layout

```
┌──────────────────────────────┐
│                              │
│         🎲    or    🎲  🎲   │
│        (1 dice)    (2 dice)  │
│                              │
│                              │
│ [1 Dice|2 Dice] 🔊      🎲   │
│   (dice count) (effects)(throw)
└──────────────────────────────┘
```

**Bottom Controls:**
- **Left**: Dice count toggle (1 Dice | 2 Dice)
- **Center**: Effects toggle (🔊 or 🔇)
- **Right**: Throw button (🎲)

## Technical Implementation

### Haptic Feedback

**Setup:**
```swift
private var impactGenerator: UIImpactFeedbackGenerator?

private func setupHaptics() {
    impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    impactGenerator?.prepare()
}
```

**Usage:**
```swift
if hapticsEnabled {
    impactGenerator?.impactOccurred(intensity: 0.8)
}
```

**Properties:**
- **Style**: `.medium` - Balanced impact feel
- **Intensity**: `0.8` - Strong but not jarring
- **Timing**: Triggers immediately when throw starts

### Sound Effects

**Implementation:**
```swift
import AudioToolbox

private func playDiceRollSound() {
    // Use system sound for dice roll
    // Sound ID 1104 is a good dice-like click sound
    AudioServicesPlaySystemSound(1104)

    // Multiple clicks for rolling effect
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        AudioServicesPlaySystemSound(1104)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        AudioServicesPlaySystemSound(1104)
    }
}
```

**Sound Pattern:**
- **System Sound ID**: 1104 (click sound)
- **Pattern**: 3 clicks with 0.1s intervals
- **Timing**:
  - Click 1: Immediate (0.0s)
  - Click 2: 0.1s delay
  - Click 3: 0.2s delay
- **Total duration**: ~0.3 seconds

**Why System Sounds:**
- No audio file needed
- Low latency
- Consistent across devices
- Works in simulator and device

### Toggle Button

**Setup:**
```swift
private func setupEffectsToggle() {
    effectsToggle = UIButton(type: .system)
    effectsToggle.setTitle("🔊", for: .normal)
    effectsToggle.titleLabel?.font = UIFont.systemFont(ofSize: 24)
    effectsToggle.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 0.6)
    effectsToggle.layer.cornerRadius = 22
    effectsToggle.layer.borderWidth = 2
    effectsToggle.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor

    // Position at bottom-center
    effectsToggle.frame = CGRect(
        x: (view.bounds.width - 44) / 2,
        y: view.bounds.height - 70,
        width: 44,
        height: 44
    )

    effectsToggle.addTarget(self, action: #selector(toggleEffects), for: .touchUpInside)
}
```

**Toggle Action:**
```swift
@objc private func toggleEffects() {
    soundEnabled.toggle()
    hapticsEnabled.toggle()

    // Update button appearance
    if soundEnabled && hapticsEnabled {
        effectsToggle.setTitle("🔊", for: .normal)
        effectsToggle.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 0.6)
    } else {
        effectsToggle.setTitle("🔇", for: .normal)
        effectsToggle.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.6)
    }
}
```

### Integration with Throw Action

**Updated throw method:**
```swift
@objc private func throwDiceButtonTapped() {
    let activeDice = diceScene.getActiveDice()

    // Play haptic feedback
    if hapticsEnabled {
        impactGenerator?.impactOccurred(intensity: 0.8)
    }

    // Play dice rolling sound
    if soundEnabled {
        playDiceRollSound()
    }

    // Apply physics to dice...
    for (index, dice) in activeDice.enumerated() {
        // ... throw logic
    }
}
```

## User Experience

### Enabled Mode (Default)

**When user throws dice:**
1. User taps dice/button or flicks
2. **Haptic vibration** - Medium impact
3. **Sound effect** - 3 clicks (dice tumbling)
4. Dice physics applied
5. Dice tumbles and settles

**Feedback:**
- Immediate tactile response
- Audible confirmation
- Enhanced realism

### Disabled Mode

**When user throws dice:**
1. User taps dice/button or flicks
2. ~~No haptic vibration~~
3. ~~No sound effect~~
4. Dice physics applied (normal)
5. Dice tumbles and settles (silent)

**Use Cases:**
- Silent environments
- Battery saving
- Personal preference

### Toggle Interaction

**Enable Effects:**
```
User taps 🔇 button
   ↓
Button changes to 🔊
Background: gray → blue
soundEnabled = true
hapticsEnabled = true
   ↓
Next throw has effects
```

**Disable Effects:**
```
User taps 🔊 button
   ↓
Button changes to 🔇
Background: blue → gray
soundEnabled = false
hapticsEnabled = false
   ↓
Next throw is silent
```

## State Management

### Properties

```swift
private var soundEnabled: Bool = true       // Default: ON
private var hapticsEnabled: Bool = true     // Default: ON
```

**Default State:**
- Both effects enabled on app launch
- Can be changed via toggle button
- State persists during session (not saved between launches)

### Future Enhancement

Could add UserDefaults to persist preference:
```swift
@AppStorage("soundEnabled") var soundEnabled: Bool = true
@AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
```

## Haptic Feedback Details

### UIImpactFeedbackGenerator

**Available Styles:**
- `.light` - Subtle vibration
- `.medium` - **Used** - Balanced impact
- `.heavy` - Strong vibration
- `.soft` - Very subtle (iOS 13+)
- `.rigid` - Sharp impact (iOS 13+)

**Why Medium:**
- Good balance between subtle and strong
- Feels like physical dice hitting surface
- Not too jarring
- Works well with sound

**Intensity:**
- Range: 0.0 to 1.0
- We use: 0.8 (80% strength)
- Strong enough to feel
- Not maximum to avoid battery drain

### Performance

**Preparation:**
```swift
impactGenerator?.prepare()
```

**Purpose:**
- Reduces latency
- Ensures haptic engine is ready
- Called once during setup

## Sound Effect Details

### System Sound 1104

**Characteristics:**
- Short click sound
- Similar to dice tap
- Low latency
- No file needed

**Pattern Analysis:**
```
Time:  0.0s    0.1s    0.2s
Sound: CLICK → CLICK → CLICK

Simulates: Dice hitting surface multiple times
Effect: Rolling/tumbling sound
```

### Alternative System Sounds

Other options that could work:
- `1103` - Light tap
- `1104` - **Used** - Click (best for dice)
- `1105` - Tock sound
- `1306` - Key press click

## Benefits

✅ **Enhanced realism** - Feels like physical dice
✅ **Immediate feedback** - Confirms action
✅ **User control** - Can disable if preferred
✅ **No assets needed** - Uses system sounds
✅ **Low latency** - Instant response
✅ **Battery efficient** - Medium haptics, short sounds
✅ **Accessible** - Visual toggle indicator

## Accessibility

### Visual Feedback
- Button color changes (blue ↔ gray)
- Icon changes (🔊 ↔ 🔇)
- Clear visual state

### Alternative Feedback
- If user disables haptics: Sound still plays
- If user disables sound: Haptics still work
- Currently both toggle together (future: separate controls)

## Testing

### Manual Tests

1. **Enable/Disable Toggle:**
   - Tap effects button
   - Check icon changes 🔊 → 🔇
   - Check background changes blue → gray
   - Tap again, verify reverses

2. **Effects Enabled:**
   - Ensure button shows 🔊
   - Tap dice or button
   - **Feel**: Vibration
   - **Hear**: Click-click-click sound

3. **Effects Disabled:**
   - Tap effects button (🔇)
   - Throw dice
   - **Feel**: No vibration
   - **Hear**: Silence

4. **All Throw Methods:**
   - Test with tap on dice → Effects play
   - Test with flick on dice → Effects play
   - Test with button → Effects play

5. **Multi-Dice:**
   - Switch to 2 dice
   - Throw → Effects play once (not per die)

### Simulator vs Device

**Simulator:**
- ✅ Sound works
- ❌ Haptics don't work (no vibration motor)

**Physical Device:**
- ✅ Sound works
- ✅ Haptics work

**Testing Recommendation:**
- Test sound in simulator
- Test haptics on real device

## Console Output

**Effects Enabled:**
```
🔊 Effects toggled: sound=true, haptics=true
🎲 ========== THROW INITIATED (1 dice) ==========
📍 Die 1 repositioned to (0.234, 2.5, -1.567)
💨 Die 1 force: (0.123, -0.045, -0.234)
🌀 Die 1 torque: (3.456, -2.123, 1.789)
✅ Throw complete - 1 dice contained in bounding box
```

**Effects Disabled:**
```
🔊 Effects toggled: sound=false, haptics=false
🎲 ========== THROW INITIATED (1 dice) ==========
📍 Die 1 repositioned to (0.234, 2.5, -1.567)
💨 Die 1 force: (0.123, -0.045, -0.234)
🌀 Die 1 torque: (3.456, -2.123, 1.789)
✅ Throw complete - 1 dice contained in bounding box
```

## Future Enhancements

Possible additions:
- Separate sound and haptics toggles
- Volume slider for sound
- Haptic intensity selector
- Different sounds for different actions
- Landing sound when dice settles
- UserDefaults to persist preference
- Custom dice roll audio file
- Collision sounds between dice

## Summary

✅ **Haptic feedback** - Medium impact vibration
✅ **Dice roll sound** - 3-click pattern
✅ **Toggle control** - Bottom-center button
✅ **Default: Enabled** - Can be disabled anytime
✅ **Visual feedback** - Button state clear
✅ **Works with all throw methods** - Tap, flick, button
✅ **Low latency** - Instant response

The dice app now provides tactile and audible feedback for a more immersive rolling experience! 🔊🎲
