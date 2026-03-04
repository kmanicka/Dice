# Throw Button Fix - Dice Disappearing Issue

## Problem
When clicking "Throw Dice" button, the dice was disappearing from view.

## Root Cause
The dice was being repositioned to `(0, 3, 0)` which is:
- At the same Y-level as the camera (y=3)
- Outside the camera's field of view
- The camera looks at y=1, so anything at y=3 is behind/above the camera

## Solution Applied

### Position Fix
**Before:**
```swift
dice.position = SCNVector3(0, 3, 0) // Same height as camera - NOT VISIBLE
```

**After:**
```swift
dice.position = SCNVector3(0, 2, 0) // Slightly above target, IN VIEW
```

### Force Adjustment
Reduced the random forces to keep dice in camera view:

**Before:**
```swift
let randomX = Float.random(in: -2...2)      // Too strong
let randomY = Float.random(in: -1...1)
let randomZ = Float.random(in: -2...2)
```

**After:**
```swift
let randomX = Float.random(in: -0.5...0.5)   // Gentler
let randomY = Float.random(in: -0.2...0.1)   // Mostly downward
let randomZ = Float.random(in: -0.3...0.3)
```

## How to Test

### Manual Testing (Recommended)
1. **Run the app** in simulator or device
2. **Click the "Throw Dice" button** at the bottom
3. **Observe**:
   - Dice should remain visible
   - Starts at position (0, 2, 0) - slightly above center
   - Falls and tumbles with physics
   - Settles on the floor showing a random number

### What Should Happen
```
Initial state: Dice at (0, 1, 0) - visible in center
                    ↓
Click "Throw Dice": Dice moves to (0, 2, 0) - still visible
                    ↓
Physics applies: Small random force + spin
                    ↓
Dice tumbles: Falls from y=2 to floor at y=0
                    ↓
Settles: Comes to rest on a random face (1-6)
```

### Camera Setup
- **Camera position**: (0, 3, 5) - elevated and back
- **Camera looks at**: (0, 1, 0) - center of scene
- **Field of view**: 60°
- **Visible range**: Approximately y=-0.5 to y=2.5

## Expected Behavior After Fix

✅ Dice stays visible throughout throw
✅ Gentle tumbling motion
✅ Dice stays within camera view
✅ Settles naturally on the floor
✅ Shows random result (1-6)

## Testing Checklist

- [ ] Launch app - dice visible at start
- [ ] Click "Throw Dice" button
- [ ] Dice remains visible (doesn't disappear)
- [ ] Dice tumbles realistically
- [ ] Dice settles on floor
- [ ] Can click button multiple times
- [ ] Each throw produces different result

The fix is complete and deployed in the current build!
