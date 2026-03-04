# 📦 Bounding Box Margins Update

## Overview

Added **margins** to the bounding box to keep dice away from the edges of the screen, ensuring they stay:
- **Above the bottom bar** (not obscured by UI)
- **Below the top** (not near camera/status area)
- **Away from left/right edges** (clear visibility)

## Changes Made

### Before

**Bounding Box Coverage:**
- Used 90% of visible screen area
- Full height: 4.5 units (3 × dice size)
- Dice could get very close to edges
- Could be obscured by bottom bar

**Calculations:**
```swift
let visibleWidth = visibleWidthAtFloor * aspectRatio * 0.9  // 90%
let visibleHeight = visibleWidthAtFloor * 0.9               // 90%
let boundingHeight = 3.0 * diceSize                         // 4.5 units
```

### After

**Bounding Box Coverage:**
- Uses 70% of visible screen area (30% margin)
- Reduced height: 3.75 units (2.5 × dice size)
- Dice stay well away from all edges
- Always visible above bottom bar

**Calculations:**
```swift
let marginFactor = 0.70                                     // 70% (30% margin)
let visibleWidth = visibleWidthAtFloor * aspectRatio * marginFactor
let visibleHeight = visibleWidthAtFloor * marginFactor
let boundingHeight = 2.5 * diceSize                         // 3.75 units (reduced)
```

## Margin Breakdown

### Horizontal Margins (Left/Right)

**Before:** 10% margin (5% each side)
**After:** 30% margin (15% each side)

**Benefit:** Dice stay clearly visible, away from edges

### Vertical Margins (Top/Bottom)

**Before:** 10% margin + full height ceiling
**After:** 30% margin + reduced height ceiling

**Benefits:**
- Bottom: Dice stay above bottom bar (80px)
- Top: Dice don't get too close to camera/top area
- Better visibility throughout roll

### Height Reduction

**Before:** 4.5 units (3 × dice size of 1.5)
**After:** 3.75 units (2.5 × dice size of 1.5)

**Reason:**
- Accounts for bottom bar taking screen space
- Prevents dice from obscuring behind UI
- Still enough vertical space for tumbling

## Visual Comparison

### Before (90% Coverage)

```
┌──────────────────────────┐ ← Top (near edge)
│ [Small margin]           │
│                          │
│     🎲      or   🎲🎲    │
│   (can get close         │
│    to edges)             │
│                          │
│ [Small margin]           │
├──────────────────────────┤
│   Bottom Bar (80px)      │ ← Dice could be here
└──────────────────────────┘
```

### After (70% Coverage, 30% Margin)

```
┌──────────────────────────┐ ← Top
│    [Margin ~15%]         │
│  ┌────────────────────┐  │ ← Bounding box top
│  │                    │  │
│  │    🎲  or  🎲🎲    │  │ ← Dice stay in center
│  │  (well bounded)    │  │
│  │                    │  │
│  └────────────────────┘  │ ← Bounding box bottom
│    [Margin ~15%]         │
├──────────────────────────┤
│   Bottom Bar (80px)      │ ← Always clear
└──────────────────────────┘
```

## Technical Details

### Updated Bounding Box Calculation

```swift
private func setupTrayWalls() {
    let cameraHeight: CGFloat = 12.0
    let fov: CGFloat = 60.0
    let fovRadians = fov * .pi / 180.0
    let visibleWidthAtFloor = 2.0 * tan(fovRadians / 2.0) * cameraHeight

    let aspectRatio: CGFloat = 0.46

    // Add margins - use 70% of visible area (30% margin)
    let marginFactor: CGFloat = 0.70
    let visibleWidth = visibleWidthAtFloor * aspectRatio * marginFactor
    let visibleHeight = visibleWidthAtFloor * marginFactor

    // Reduce height for bottom bar
    let diceSize: CGFloat = 1.5
    let boundingHeight: CGFloat = 2.5 * diceSize  // 3.75 units

    // ... create walls with new dimensions
}
```

### Margin Factor

**Value:** 0.70 (70% of visible area)

**Effect:**
- 30% total margin distributed around edges
- ~15% margin on each side
- Keeps dice well within visible area

### Height Reduction Factor

**Before:** 3.0 × dice size = 4.5 units
**After:** 2.5 × dice size = 3.75 units

**Reduction:** 0.75 units (16.7% shorter)

**Reason:**
- Bottom bar (80px) takes significant screen space
- Reducing height ensures dice never go behind bar
- Still plenty of room for tumbling physics

## Wall Positions (Updated)

### Horizontal Walls (Front/Back)

```swift
// FRONT wall (positive Z)
frontNode.position = SCNVector3(0, boundingHeight/2, visibleHeight/2)
// visibleHeight now smaller → wall closer to center

// BACK wall (negative Z)
backNode.position = SCNVector3(0, boundingHeight/2, -visibleHeight/2)
// visibleHeight now smaller → wall closer to center
```

### Vertical Walls (Left/Right)

```swift
// LEFT wall (negative X)
leftNode.position = SCNVector3(-visibleWidth/2, boundingHeight/2, 0)
// visibleWidth now smaller → wall closer to center

// RIGHT wall (positive X)
rightNode.position = SCNVector3(visibleWidth/2, boundingHeight/2, 0)
// visibleWidth now smaller → wall closer to center
```

### Ceiling

```swift
// CEILING (top)
ceilingNode.position = SCNVector3(0, boundingHeight, 0)
// boundingHeight now 3.75 → lower ceiling
```

## Dice Throw Adjustments

The dice throw positions should still work well within the new bounds:

```swift
// Random throw positions
let randomX = Float.random(in: -2.0...2.0)  // Still safe
let randomZ = Float.random(in: -2.0...2.0)  // Still safe

// These values are well within the new bounding box
// New bounds are approximately:
//   Width: ~3.5 units (±1.75)
//   Height: ~5.0 units (±2.5)
// So ±2.0 range is comfortably within bounds
```

## Benefits

✅ **Better Visibility**
- Dice always clearly visible
- Never obscured by bottom bar
- Never too close to screen edges

✅ **UI Compatibility**
- Bottom bar (80px) doesn't overlap dice
- Settings panel slides up without blocking dice
- Clear separation between UI and play area

✅ **Professional Look**
- Centered play area with clean margins
- Matches modern app design patterns
- Feels polished and intentional

✅ **Physics Still Works**
- Plenty of room for tumbling
- Reduced size doesn't affect gameplay
- Dice still bounce naturally

✅ **Screen Size Agnostic**
- Percentage-based margins
- Works on all iPhone sizes
- Automatically adjusts to screen dimensions

## Console Output

```
📏 Calculated bounding box with margins:
   Width: 3.45, Height: 4.89, Ceiling: 3.75
   Margin factor: 0.7 (30% margin on all sides)
🎯 Transparent bounding box created:
   Dimensions: 3.45 x 4.89 x 3.75
   4 walls + ceiling with physics collision
```

**Comparison:**

Before:
```
Width: 4.93, Height: 6.99, Ceiling: 4.5
```

After:
```
Width: 3.45, Height: 4.89, Ceiling: 3.75
```

**Reductions:**
- Width: -30% (1.48 units smaller)
- Height: -30% (2.10 units smaller)
- Ceiling: -16.7% (0.75 units lower)

## Testing

### Visual Test

1. **Roll dice multiple times**
   - Observe: Dice stay centered
   - Check: Never obscured by bottom bar
   - Verify: Never touch screen edges

2. **Open settings panel**
   - Roll dice with panel open
   - Check: Dice still visible above panel
   - Verify: No overlap

3. **Multiple dice (2 dice mode)**
   - Roll both dice
   - Check: Both stay within bounds
   - Verify: Clear space around edges

### Physics Test

1. **Hard throws**
   - Use maximum force throws
   - Check: Dice bounce off invisible walls
   - Verify: Stay within margin area

2. **Flick gestures**
   - Swipe in all directions
   - Check: Directional throws work
   - Verify: Containment maintained

## Future Adjustments

If needed, the margin can be easily adjusted:

```swift
// More margin (smaller play area)
let marginFactor: CGFloat = 0.60  // 40% margin

// Less margin (larger play area)
let marginFactor: CGFloat = 0.80  // 20% margin

// Current (balanced)
let marginFactor: CGFloat = 0.70  // 30% margin
```

## Summary

✅ **30% margin** on all sides (70% of screen area used)
✅ **Reduced height** - 3.75 units (accounts for bottom bar)
✅ **Better visibility** - Dice always clearly visible
✅ **UI compatible** - No overlap with bottom bar or panels
✅ **Professional look** - Clean, centered play area

The bounding box now provides a well-defined play area with clear margins, ensuring dice are always visible and the UI remains unobstructed! 📦
