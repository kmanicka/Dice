# Manual Testing Guide - Dice Throw in Tray

## ✅ Current Status

The app is running with:
- Dice visible in wooden tray
- Blue "Throw Dice" button at bottom
- Tray walls to contain dice
- Enhanced logging for debugging
- Reduced physics forces to keep dice in tray

## 🧪 Step-by-Step Testing Instructions

### Test 1: Initial State
**Expected:**
- ✅ Dice sitting in wooden tray
- ✅ Blue button labeled "🎲 Throw Dice" at bottom
- ✅ Tray walls visible (4 wooden sides)

**Screenshot taken:** `/tmp/test6_with_blue_button.png` ✅

---

### Test 2: Click the Throw Dice Button

**How to test:**
1. Click the blue "Throw Dice" button at the bottom of the screen
2. Watch what happens

**Expected behavior:**
1. **Immediately:** Dice repositions to random spot elevated above tray (y=1.5)
2. **0.5-1s:** Dice falls and tumbles
3. **1-2s:** Dice bounces off floor/walls
4. **2-3s:** Dice settles on a face showing a number (1-6)

**What to look for:**
- ✅ Dice moves from original position
- ✅ Dice stays visible (doesn't fly off screen)
- ✅ Dice tumbles/rotates as it falls
- ✅ Dice stays within the tray walls
- ✅ Dice comes to rest showing a clear number

**Check console logs** (if available) for:
```
🎲 ========== THROW BUTTON TAPPED ==========
📍 Dice repositioned to (X, 1.5, Z)
💨 Force applied: (X, Y, Z)
🌀 Torque applied: (X, Y, Z)
✅ Throw complete - dice should be falling and tumbling
```

---

### Test 3: Multiple Throws

**How to test:**
1. Click "Throw Dice" button multiple times (5-10 throws)
2. Observe each throw

**Expected:**
- ✅ Each throw produces different starting position
- ✅ Each throw produces different tumbling pattern
- ✅ Each throw results in different final number
- ✅ Dice NEVER flies out of the tray
- ✅ Dice ALWAYS settles within tray boundaries

**Record results:**
```
Throw 1: Final number = ___
Throw 2: Final number = ___
Throw 3: Final number = ___
Throw 4: Final number = ___
Throw 5: Final number = ___
```

Distribution should be roughly random (not always same number).

---

### Test 4: Edge Cases

**Test 4a: Rapid clicking**
- Click button rapidly 3-4 times
- Expected: Dice resets and throws each time, no crashes

**Test 4b: Wait for complete settle**
- Throw dice
- Wait until completely stopped (3-5 seconds)
- Throw again
- Expected: Clean reset and new throw

---

## 🐛 Known Issues to Watch For

### Issue: Dice Flies Off Screen
**Symptoms:** Dice disappears after button click
**Status:** Should be FIXED with current settings
- Reduced forces: X/Z: ±0.3, Y: -0.2 to 0.1
- Heavier dice: 50g mass (was 10g)
- Higher damping: 0.5 linear, 0.6 angular
- Tray walls: 4 sides with physics collision

**If this still happens:** Report the throw that caused it

### Issue: Dice Doesn't Move
**Symptoms:** Button click doesn't trigger throw
**Debug:** Check if button is responding (should change color slightly when pressed)

### Issue: Dice Gets Stuck
**Symptoms:** Dice bounces continuously or vibrates in place
**Status:** Should be prevented by damping settings

---

## 📊 Physics Settings Applied

```swift
Dice:
- Mass: 50g (heavier for stability)
- Restitution: 0.3 (low bounce)
- Friction: 0.8 (high grip)
- Rolling Friction: 0.5
- Damping: 0.5 (linear)
- Angular Damping: 0.6 (rotational)

Throw Forces:
- Position: Random in tray, y=1.5
- Force: X/Z: ±0.3, Y: -0.2 to +0.1
- Torque: ±4 on each axis

Tray:
- Size: 4x4 units
- Wall height: 1.0 unit
- Floor at y=0
- Walls: Static physics bodies
```

---

## ✅ Success Criteria

The dice throwing is working correctly if:

1. **Visibility:** Dice stays visible throughout entire throw
2. **Containment:** Dice never leaves the tray boundaries
3. **Movement:** Dice tumbles realistically when thrown
4. **Settlement:** Dice settles within 2-3 seconds
5. **Randomness:** Different throws produce different results
6. **Reliability:** Works consistently on multiple throws

---

## 📸 Screenshot Evidence Needed

Please take screenshots at these moments:

1. **Before throw:** Initial dice position ✅ (already captured)
2. **During throw:** While dice is mid-air/tumbling
3. **After settle:** Final position showing result number
4. **Multiple throws:** Final positions from 3-5 different throws

This will help verify end-to-end functionality.

---

## 🔧 If Issues Persist

If dice still flies off screen, we can:
1. Reduce forces further (currently ±0.3)
2. Add invisible ceiling
3. Increase dice mass more (currently 50g)
4. Increase damping values
5. Make tray walls higher

**Current build is ready for manual testing!**
