# 🎮 Flick Gesture - Re-Added

## Overview

The **flick/swipe gesture** has been added back to the dice app, now working seamlessly with both 1 and 2 dice modes.

## How It Works

### Flick Any Die
- **Touch and hold** on any die
- **Swipe** in any direction
- **All active dice** throw in the flick direction
- Faster flick = more spin and force

### Gesture Behavior

**Slow Touch (< 50 pts/sec):**
- Pan gesture fails
- Tap gesture fires instead
- Random throw triggered

**Fast Swipe (≥ 50 pts/sec):**
- Pan gesture succeeds
- Directional throw applied
- All active dice thrown in swipe direction

## Three Ways to Throw

| Method | Trigger | Behavior | Best For |
|--------|---------|----------|----------|
| **Tap Dice** | Single tap on any die | Random throw all dice | Quick rolls |
| **Flick Dice** | Swipe on any die | Directional throw all dice | Controlled rolling |
| **Button** | Tap floating button | Random throw all dice | Easy access |

## Technical Implementation

### FlickGestureHandler (Updated)

**Changed from single die to multi-dice support:**

```swift
class FlickGestureHandler: NSObject, UIGestureRecognizerDelegate {
    private weak var sceneView: SCNView?
    private weak var diceScene: DiceScene?          // Changed from diceNode
    private var throwAction: (() -> Void)?          // Callback for throw

    init(sceneView: SCNView, diceScene: DiceScene, throwAction: @escaping () -> Void) {
        self.sceneView = sceneView
        self.diceScene = diceScene
        self.throwAction = throwAction
        super.init()
        setupGestureRecognizers()
    }
}
```

**Hit Detection (Updated):**

```swift
case .began:
    // Check if starting touch is on any active dice
    let hitTestOptions: [SCNHitTestOption: Any] = [
        .categoryBitMask: 1,                                    // Only dice
        .searchMode: SCNHitTestSearchMode.closest.rawValue
    ]
    let hitResults = sceneView.hitTest(location, options: hitTestOptions)

    // Check if we hit any active dice
    let activeDice = diceScene.getActiveDice()
    touchStartedOnDice = hitResults.first.map { hit in
        activeDice.contains { dice in
            hit.node == dice || hit.node.parent == dice
        }
    } ?? false
```

**Apply Flick to All Active Dice:**

```swift
private func applyFlickToActiveDice(direction2D: CGPoint, velocity: CGFloat, touchPoint: CGPoint) {
    let activeDice = diceScene.getActiveDice()

    for (index, dice) in activeDice.enumerated() {
        // Reset velocity
        dice.physicsBody?.velocity = SCNVector3Zero
        dice.physicsBody?.angularVelocity = SCNVector4Zero

        // Lift dice
        var currentPos = dice.position
        currentPos.y = 1.5
        dice.position = currentPos

        // Randomize orientation
        dice.randomizeOrientation()

        // Calculate directional force
        let forceScale: Float = 0.002
        let force3D = SCNVector3(
            Float(direction2D.x) * Float(velocity) * forceScale,
            Float(velocity) * forceScale * 0.3,
            -Float(direction2D.y) * Float(velocity) * forceScale
        )

        // Apply force and torque
        dice.physicsBody?.applyForce(force3D, at: contactPoint, asImpulse: true)

        let angularStrength = min(Float(velocity) * 0.003, 5.0)
        let angularImpulse = SCNVector4(
            Float.random(in: -angularStrength...angularStrength),
            Float.random(in: -angularStrength...angularStrength),
            Float.random(in: -angularStrength...angularStrength),
            1.0
        )
        dice.physicsBody?.applyTorque(angularImpulse, asImpulse: true)
    }
}
```

### DiceViewController (Updated)

**Gesture Setup with Coordination:**

```swift
private func setupGestures() {
    // Initialize flick gesture handler
    flickGestureHandler = FlickGestureHandler(
        sceneView: scnView,
        diceScene: diceScene,
        throwAction: { [weak self] in
            self?.throwDiceButtonTapped()
        }
    )

    // Add tap gesture
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

    // Make tap wait for pan to fail (flick has priority)
    if let panGesture = flickGestureHandler.panGesture {
        tapGesture.require(toFail: panGesture)
    }

    scnView.addGestureRecognizer(tapGesture)
}
```

## Gesture Coordination

### Priority System

1. **Pan Gesture (Flick)** - Highest priority
   - Activates if velocity ≥ 50 pts/sec
   - Applies directional force
   - Prevents tap from firing

2. **Tap Gesture** - Lower priority
   - Waits for pan to fail (slow movement)
   - Applies random force
   - Only if pan didn't succeed

### Velocity Thresholds

```swift
minVelocityThreshold: 50 pts/sec    // Minimum to register as flick
maxVelocityThreshold: 2000 pts/sec  // Maximum cap for safety
```

**Velocity Examples:**
- Slow drag: 20-40 pts/sec → Tap fires
- Normal flick: 200-800 pts/sec → Directional throw
- Fast flick: 800-2000 pts/sec → Maximum force throw

## Direction Mapping

### Screen to 3D World

```
Screen Coordinates → 3D World:
- Swipe Right → Dice move +X (right)
- Swipe Left  → Dice move -X (left)
- Swipe Up    → Dice move +Z (away from camera)
- Swipe Down  → Dice move -Z (toward camera)
- Diagonal    → Combined X+Z motion
```

### Force Calculation

```swift
forceScale = 0.002 (small to stay in bounds)

Force X = swipe_x * velocity * 0.002
Force Y = velocity * 0.002 * 0.3        // Small lift
Force Z = -swipe_y * velocity * 0.002   // Negative for proper direction

Angular Spin = velocity * 0.003 (capped at 5.0)
```

## User Experience

### Interaction Flow

**Scenario 1: Quick Tap (1 Die)**
```
User taps die
   ↓
Pan gesture begins (velocity tracking)
   ↓
User releases quickly (velocity = 30 pts/sec)
   ↓
Pan gesture fails (< 50 threshold)
   ↓
Tap gesture fires
   ↓
Random throw (1 die)
```

**Scenario 2: Directional Flick (2 Dice)**
```
User touches die and holds
   ↓
Pan gesture begins
   ↓
User swipes right (velocity = 450 pts/sec)
   ↓
Pan gesture succeeds (≥ 50 threshold)
   ↓
Calculate direction: (1.0, 0) normalized
   ↓
Apply flick to both active dice
   ↓
Both dice throw rightward
   ↓
Tumble with spin
   ↓
Settle on random faces
```

**Scenario 3: Button Press**
```
User taps floating button
   ↓
Random throw (all active dice)
   ↓
Same as tap behavior
```

## Multi-Dice Behavior

### 1 Die Mode
- Flick single die → Die throws in flick direction
- Tap single die → Die throws randomly

### 2 Dice Mode
- Flick either die → **Both dice** throw in flick direction
- Tap either die → **Both dice** throw randomly
- Both get same directional force
- Both get unique random spin

### Why All Dice Throw Together

**Design Decision:**
- Flicking one die throws all active dice
- Creates consistent behavior with tap gesture
- Simulates rolling all dice together
- More natural for tabletop gaming feel

## Force Scaling

### Reduced for Containment

```swift
forceScale = 0.002 // Much smaller than original 0.01
```

**Reason:**
- Keeps dice within bounding box
- Prevents flying off screen
- Still allows directional control
- Bounces off invisible walls

### Velocity Mapping

```
Velocity (pts/sec)  →  Force Magnitude
    50              →  0.1   (minimum)
   200              →  0.4   (typical)
   500              →  1.0   (strong)
  1000              →  2.0   (very strong)
  2000              →  4.0   (maximum)
```

## Console Output

**Flick Detection:**
```
🖐️ Flick started on dice
🚀 Flick detected: 487 pts/sec
🚀 Die 1 flick applied: 487 pts/sec, force=(0.234, 0.292, -0.123), spin=1.46
🚀 Die 2 flick applied: 487 pts/sec, force=(0.234, 0.292, -0.123), spin=1.46
```

**Slow Swipe (Tap Fires):**
```
🖐️ Flick started on dice
⚠️ Flick too slow: 32 pts/sec (min: 50) - allowing tap
👆 Tap at location (187.5, 412.3), hits: 1
🎲 Dice tapped! Initiating random throw...
```

## Benefits

✅ **Directional control** - Throw dice in specific direction
✅ **Variable force** - Flick speed affects throw strength
✅ **Works with 1 or 2 dice** - Consistent behavior
✅ **Coordinated gestures** - No conflict with tap
✅ **Natural feel** - Intuitive swipe-to-throw
✅ **Contained physics** - Forces calibrated to stay in bounds

## Testing

### Manual Tests

1. **Flick Right (1 Die):**
   - Select "1 Die"
   - Touch and swipe right on die
   - Expected: Die throws rightward

2. **Flick Left (2 Dice):**
   - Select "2 Dice"
   - Touch and swipe left on either die
   - Expected: Both dice throw leftward

3. **Slow Drag:**
   - Touch die and drag slowly
   - Expected: Tap fires instead (random throw)

4. **Fast Flick:**
   - Swipe very fast
   - Expected: Maximum force throw in swipe direction

5. **Diagonal Flick:**
   - Swipe diagonally (e.g., up-right)
   - Expected: Dice throw in diagonal direction

## Summary

✅ **Flick gesture re-added**
✅ **Works with 1 or 2 dice**
✅ **Coordinated with tap gesture**
✅ **Directional throwing**
✅ **Variable force based on swipe speed**
✅ **All active dice throw together**

The dice app now has three intuitive ways to throw: **tap** for quick random rolls, **flick** for directional control, and **button** for easy access! 🎲
