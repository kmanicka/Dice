# 🎲🎲 Two Dice Feature - Implementation

## Overview

Added the ability to roll **1 or 2 dice** together with a floating toggle control at the bottom of the screen.

## Features

✅ **Toggle between 1 or 2 dice**
✅ **Automatic positioning** - Dice spread apart when 2 are active
✅ **Tap any die** - Works with both dice
✅ **Throw all active dice** - Button and tap throw all visible dice
✅ **Soft lighting** - Both dice have matte finish

## User Interface

### Dice Count Toggle
- **Location**: Bottom-left corner
- **Type**: UISegmentedControl
- **Options**: "1 Die" | "2 Dice"
- **Style**: Blue background matching theme
- **Size**: 140px wide, 32px tall

### Throw Button
- **Location**: Bottom-right corner (unchanged)
- **Behavior**: Throws all active dice

## Technical Implementation

### DiceScene Changes

#### New Properties
```swift
var diceNodes: [DiceNode] = []           // All dice nodes
private(set) var activeDiceCount: Int = 1 // Current active count
```

#### Setup Dice (Modified)
```swift
private func setupDice() {
    // Create 2 dice (show/hide based on active count)
    for i in 0..<2 {
        let dice = DiceNode()

        if i == 0 {
            dice.position = SCNVector3(0, 0.8, 0)      // Center for single
        } else {
            dice.position = SCNVector3(2.0, 0.8, 0)   // Right side
            dice.isHidden = true                       // Hidden by default
        }

        scene.rootNode.addChildNode(dice)
        diceNodes.append(dice)
    }
}
```

#### New Method: setDiceCount()
```swift
func setDiceCount(_ count: Int) {
    activeDiceCount = count

    if count == 1 {
        // Single die - center position
        diceNodes[0].isHidden = false
        diceNodes[0].position = SCNVector3(0, 0.8, 0)
        diceNodes[1].isHidden = true
    } else {
        // Two dice - side by side
        diceNodes[0].isHidden = false
        diceNodes[0].position = SCNVector3(-1.2, 0.8, 0) // Left
        diceNodes[1].isHidden = false
        diceNodes[1].position = SCNVector3(1.2, 0.8, 0)  // Right
    }
}
```

#### New Method: getActiveDice()
```swift
func getActiveDice() -> [DiceNode] {
    return diceNodes.prefix(activeDiceCount).map { $0 }
}
```

### DiceViewController Changes

#### New UI Element
```swift
private var diceCountToggle: UISegmentedControl!

private func setupDiceCountToggle() {
    diceCountToggle = UISegmentedControl(items: ["1 Die", "2 Dice"])
    diceCountToggle.selectedSegmentIndex = 0
    diceCountToggle.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 0.6)
    diceCountToggle.selectedSegmentTintColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.9)

    diceCountToggle.frame = CGRect(x: 20, y: view.bounds.height - 80, width: 140, height: 32)
    diceCountToggle.addTarget(self, action: #selector(diceCountChanged), for: .valueChanged)

    view.addSubview(diceCountToggle)
}

@objc private func diceCountChanged() {
    let count = diceCountToggle.selectedSegmentIndex + 1
    diceScene.setDiceCount(count)
}
```

#### Updated Throw Logic
```swift
@objc private func throwDiceButtonTapped() {
    let activeDice = diceScene.getActiveDice()

    for (index, dice) in activeDice.enumerated() {
        // Spread dice apart if there are multiple
        let baseOffsetX: Float = activeDice.count == 2 ? (index == 0 ? -1.5 : 1.5) : 0
        let randomX = baseOffsetX + Float.random(in: -0.5...0.5)
        let randomZ = Float.random(in: -2.0...2.0)

        dice.position = SCNVector3(randomX, 2.5, randomZ)
        // ... apply forces and torques
    }
}
```

#### Updated Tap Handler
```swift
@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    let activeDice = diceScene.getActiveDice()

    let hitADice = activeDice.contains { dice in
        hitResult.node == dice || hitResult.node.parent == dice
    }

    if hitADice {
        throwDiceButtonTapped() // Throws all active dice
    }
}
```

## Dice Positioning

### Single Die Mode (1 Die)
```
Center: (0, 0.8, 0)

          🎲
       (center)
```

### Two Dice Mode (2 Dice)
```
Left:  (-1.2, 0.8, 0)
Right: ( 1.2, 0.8, 0)

    🎲      🎲
   (left) (right)

Spacing: 2.4 units apart
```

### Throw Positions (2 Dice)
```
Left die:  baseX = -1.5 + random(-0.5 to 0.5)
Right die: baseX =  1.5 + random(-0.5 to 0.5)

Both:      randomZ = random(-2.0 to 2.0)
           startY = 2.5

Result: Dice start separated, tumble independently
```

## User Experience

### Switching Modes

**1 Die → 2 Dice:**
1. User taps "2 Dice" in toggle
2. First die moves left to (-1.2, 0.8, 0)
3. Second die appears right at (1.2, 0.8, 0)
4. Both dice visible and ready

**2 Dice → 1 Die:**
1. User taps "1 Die" in toggle
2. First die moves to center (0, 0.8, 0)
3. Second die disappears (isHidden = true)
4. Single die ready

### Throwing Dice

**Tap Button:**
- Throws all active dice
- Each gets random position and forces
- Dice tumble independently
- May collide during roll (realistic!)

**Tap Any Die:**
- Throws all active dice (not just tapped one)
- Same behavior as button

**Tap Background:**
- No action

## Physics Interactions

### Dice-Dice Collisions
- Both dice have physics bodies
- Can collide with each other during tumbling
- Adds realism to multi-dice rolls
- Contained within bounding box

### Independent Motion
- Each die gets unique random forces
- Each die tumbles independently
- Each die settles on different face
- Realistic multi-dice behavior

## UI Layout

```
┌──────────────────────────────┐
│                              │
│                              │
│         🎲    or    🎲  🎲   │
│        (1 die)     (2 dice)  │
│                              │
│                              │
│                              │
│ [1 Die | 2 Dice]        🎲   │
│   (toggle)           (throw) │
└──────────────────────────────┘
```

## Code Flow

### Initialization
```
viewDidLoad()
    ↓
setupScene()
    ↓
DiceScene.setupDice()
    ↓
Create 2 dice nodes
    ↓
Set dice[0] visible, dice[1] hidden
    ↓
activeDiceCount = 1
```

### Toggle to 2 Dice
```
User taps "2 Dice"
    ↓
diceCountChanged() called
    ↓
diceScene.setDiceCount(2)
    ↓
dice[0].position = (-1.2, 0.8, 0)
dice[1].position = (1.2, 0.8, 0)
dice[1].isHidden = false
    ↓
activeDiceCount = 2
```

### Throw 2 Dice
```
User taps button/dice
    ↓
throwDiceButtonTapped()
    ↓
getActiveDice() → [dice[0], dice[1]]
    ↓
For each die:
    - Random position (spread left/right)
    - Random forces
    - Random torques
    ↓
Both dice tumble independently
    ↓
Both settle showing random faces
```

## Benefits

✅ **Simple UI** - Single toggle, clear options
✅ **Automatic positioning** - Dice move to optimal spots
✅ **Consistent behavior** - All controls work the same
✅ **Realistic physics** - Dice can interact during rolls
✅ **Good spacing** - 2.4 units apart prevents constant collision
✅ **Soft lighting** - Both dice always visible

## Testing

### Manual Test Cases

1. **Toggle Test:**
   - Start app (1 die visible at center)
   - Tap "2 Dice" → 2 dice appear side by side
   - Tap "1 Die" → 1 die at center, second disappears

2. **Throw Test (1 Die):**
   - Select "1 Die"
   - Tap button → Single die tumbles
   - Tap die → Single die tumbles

3. **Throw Test (2 Dice):**
   - Select "2 Dice"
   - Tap button → Both dice tumble
   - Tap either die → Both dice tumble

4. **Collision Test:**
   - Select "2 Dice"
   - Throw multiple times
   - Observe: Sometimes dice collide mid-air (realistic!)

5. **Containment Test:**
   - Select "2 Dice"
   - Throw multiple times
   - Verify: Both dice stay in bounds

## Performance

- **Memory**: 2 dice nodes always created (minimal overhead)
- **Rendering**: Only active dice rendered (isHidden optimization)
- **Physics**: Only active dice simulate physics
- **Lighting**: Same soft lighting for 1 or 2 dice

## Future Enhancements

Possible additions:
- Sum display (show total of 2 dice)
- Individual dice results
- 3+ dice support
- Saved dice count preference
- Animation when switching modes

## Summary

✅ **1 or 2 dice modes** via toggle
✅ **Automatic repositioning** based on count
✅ **Independent physics** for each die
✅ **Tap any die** to throw all active
✅ **Clean UI** at bottom of screen
✅ **Soft matte lighting** on all dice

The dice app now supports rolling 1 or 2 dice together with simple, intuitive controls! 🎲🎲
