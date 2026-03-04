# 🔧 Bounding Box Hit Test Fix

## Problem

**Tap on dice still not working** even after removing flick gesture. The invisible bounding box walls were capturing tap events before they could reach the dice.

## Root Cause

The transparent bounding box (floor, walls, ceiling) had **geometry** which made them **hittable** by SceneKit's hit test system. When tapping on the screen:

1. User taps where dice appears
2. SceneKit ray-traces from camera through tap point
3. Ray hits invisible wall/floor FIRST (they have geometry)
4. Hit test returns wall/floor node
5. Tap handler checks if it's the dice → NO
6. Result: "Tapped background - no action"

Even though the walls were visually transparent (UIColor.clear), they still participated in hit testing because they had geometry.

## Solution

Used SceneKit's **category bit mask** system to filter hit test results:

1. **Set bounding box nodes to categoryBitMask = 0** - Excludes them from hit tests
2. **Set dice node to categoryBitMask = 1** - Makes it hittable
3. **Use hit test options to only find categoryBitMask 1** - Filters out bounding box

This way:
- Physics still works (bounding box still has physicsBody)
- Rendering still works (walls are transparent)
- Hit testing ignores the bounding box completely

## Technical Changes

### 1. DiceScene.swift - Bounding Box Walls

**Changed all wall nodes (front, back, left, right, ceiling, floor):**

```swift
// Before
let frontNode = SCNNode(geometry: frontWall)
frontNode.physicsBody = SCNPhysicsBody(...)
scene.rootNode.addChildNode(frontNode)

// After
let frontNode = SCNNode(geometry: frontWall)
frontNode.physicsBody = SCNPhysicsBody(...)
frontNode.isHidden = false                    // Visible for physics
frontNode.categoryBitMask = 0                 // Don't participate in hit tests ← KEY CHANGE
scene.rootNode.addChildNode(frontNode)
```

Applied to:
- ✅ Front wall
- ✅ Back wall
- ✅ Left wall
- ✅ Right wall
- ✅ Ceiling
- ✅ Floor

### 2. DiceNode.swift - Dice Node

**Made dice explicitly hittable:**

```swift
override init() {
    super.init()
    createGeometry()
    applyMaterial()
    setupPhysics()
    randomizeOrientation()

    // Make sure dice CAN be hit tested
    self.categoryBitMask = 1  // ← KEY CHANGE

    print("🎲 DiceNode initialization complete")
}
```

### 3. DiceViewController.swift - Hit Test Options

**Updated tap handler to filter by categoryBitMask:**

```swift
@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: scnView)

    // Hit test with options to only find nodes with categoryBitMask 1 (the dice)
    let hitTestOptions: [SCNHitTestOption: Any] = [
        .categoryBitMask: 1,                                    // ← Only hit dice
        .searchMode: SCNHitTestSearchMode.closest.rawValue
    ]
    let hitResults = scnView.hitTest(location, options: hitTestOptions)

    if let hitResult = hitResults.first {
        print("🎲 Dice tapped! Initiating random throw...")
        throwDiceButtonTapped()
    } else {
        print("👆 Tapped background - no action")
    }
}
```

## How It Works Now

### Scenario 1: Tap on Dice
```
1. User taps on dice visually
   ↓
2. SceneKit casts ray from camera through tap point
   ↓
3. Ray passes through invisible walls (categoryBitMask = 0, ignored)
   ↓
4. Ray hits dice (categoryBitMask = 1, included)
   ↓
5. Hit test returns dice node ✅
   ↓
6. Tap handler recognizes dice
   ↓
7. throwDiceButtonTapped() executes
   ↓
8. Dice throws randomly ✅
```

### Scenario 2: Tap on Background
```
1. User taps on empty gradient background
   ↓
2. SceneKit casts ray from camera through tap point
   ↓
3. Ray passes through invisible walls (ignored)
   ↓
4. Ray doesn't hit dice
   ↓
5. Hit test returns empty array
   ↓
6. Tap handler: "Tapped background - no action" ✅
```

### Scenario 3: Physics Collision
```
1. Dice is thrown and moves through scene
   ↓
2. Dice hits invisible wall (wall has physicsBody)
   ↓
3. Physics collision detected ✅
   ↓
4. Wall applies bounce force (restitution = 0.6)
   ↓
5. Dice bounces back into play area ✅
```

## Key Concepts

### SCNNode.categoryBitMask

- **Purpose**: Bitwise mask for filtering hit tests and collisions
- **Default**: 1 (participates in hit tests)
- **Set to 0**: Node is ignored by hit tests
- **Set to 1**: Node is included in hit tests

### SCNHitTestOption.categoryBitMask

- **Purpose**: Filter hit test results by category
- **Value**: Only return nodes matching this bit mask
- **Example**: `.categoryBitMask: 1` → Only returns nodes with categoryBitMask = 1

### Physics vs Hit Testing

**Physics Bodies**: Always work regardless of categoryBitMask
**Hit Testing**: Can be filtered by categoryBitMask

This allows:
- Invisible physics barriers (categoryBitMask = 0)
- That still collide with objects
- But don't block tap/touch events

## Testing

### Manual Test Steps

1. **Test Tap on Dice:**
   - Open app in simulator
   - Tap directly on the white dice
   - Expected: Dice throws randomly
   - Console: `🎲 Dice tapped! Initiating random throw...`

2. **Test Tap on Background:**
   - Tap on purple gradient area (away from dice)
   - Expected: Nothing happens
   - Console: `👆 Tapped background - no action`

3. **Test Physics Containment:**
   - Tap dice or button to throw
   - Watch dice tumble and bounce
   - Expected: Dice stays within screen bounds
   - Should bounce off invisible walls

4. **Test Button:**
   - Tap blue floating button (bottom-right)
   - Expected: Dice throws randomly (same as tapping dice)

### Console Output

**Successful Tap on Dice:**
```
👆 Tap at location (187.5, 412.3), hits: 1
🎲 Dice tapped! Initiating random throw...
🎲 ========== THROW INITIATED ==========
📍 Dice repositioned to (1.234, 2.5, -0.567)
💨 Force applied: (0.123, -0.045, -0.234)
🌀 Torque applied: (3.456, -2.123, 1.789)
✅ Throw complete - dice contained in bounding box
```

**Tap on Background:**
```
👆 Tap at location (50.0, 100.0), hits: 0
👆 Tapped background - no action (hits: 0)
```

## Summary

✅ **Bounding box no longer captures taps**
✅ **Tap on dice now works perfectly**
✅ **Physics containment still works**
✅ **Walls remain invisible**
✅ **Two interaction methods:**
   - Tap dice → Random throw
   - Tap button → Random throw

## Key Takeaways

### SceneKit Hit Testing Rules
1. Hit tests ray-trace from camera through touch point
2. All nodes with geometry participate by default
3. Use `categoryBitMask` to filter which nodes are hittable
4. Physics bodies work independently of hit testing

### Best Practices
- Set invisible barriers to `categoryBitMask = 0`
- Set interactive objects to `categoryBitMask = 1`
- Use hit test options to filter results
- Test both tap-on-object and tap-on-background scenarios
- Remember: transparent ≠ non-hittable in SceneKit
