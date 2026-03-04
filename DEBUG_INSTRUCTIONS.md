# Debug Instructions - What You Should See

## I've Added Visual Debug Markers

The app now has bright colors to help us identify what's working:

### What You Should See When Running:

1. **Green Background** - View controller's view (behind SCNView)
2. **Red Background** - SCNView itself
3. **Blue Label** - "DICE APP RUNNING" text in top-left
4. **Red Box** - Simple 3D test box in the scene center
5. **White Dice** - The actual dice (if textures work)

## How to Run and Test:

### Option 1: Use Xcode (Recommended)
```bash
1. Open Dice.xcodeproj in Xcode
2. Select any iPhone Simulator
3. Press ⌘R to run
4. Look at what colors you see
```

### Option 2: Use Command Line Script
```bash
cd /Users/kmanickavelu/workspaces/xcode/dice
./run_and_debug.sh
```

## What Each Color Means:

### ✅ If you see GREEN:
- View controller IS loading
- UIKit is working
- SceneDelegate is working
- Problem is with SCNView or scene content

### ✅ If you see RED:
- SCNView IS being added
- SceneKit view is working
- Problem is with scene content (camera, objects, etc.)

### ✅ If you see BLUE LABEL "DICE APP RUNNING":
- viewDidLayoutSubviews is being called
- View layout is working
- Scene initialization should be happening

### ✅ If you see RED 3D BOX:
- SceneKit rendering IS working
- Camera is positioned correctly
- Problem is specifically with the dice rendering

### ❌ If screen is COMPLETELY BLACK:
**Most Likely Causes:**
1. View controller isn't being set as root (SceneDelegate issue)
2. View has zero size (layout issue)
3. App is crashing before viewDidLoad

## Debug Checklist:

Run the app and report back what you see:

- [ ] Any green visible?
- [ ] Any red visible?
- [ ] Blue label "DICE APP RUNNING" visible?
- [ ] Any 3D content (red box or white dice)?
- [ ] FPS counter in top-right corner?

## Console Logs to Check:

Open Console in Xcode (⌘⇧Y) and look for these messages:

```
🪟 Creating window and view controller
📱 DiceViewController viewDidLoad
📐 View bounds: (should NOT be 0,0,0,0)
✅ SCNView added to view hierarchy
📐 View layout complete, bounds: (should have actual dimensions)
🏷️ Test label added
🎬 Initializing DiceScene
...
✅ Window is now key and visible
```

**Look for:**
- ❌ Any error messages
- ❌ Bounds showing (0,0,0,0)
- ❌ Missing initialization steps

## Expected Console Output:

If everything is working, you should see this sequence:

```
🪟 Creating window and view controller
📱 DiceViewController viewDidLoad
📐 View bounds: (0.0, 0.0, 393.0, 852.0)
📐 SCNView frame: (0.0, 0.0, 393.0, 852.0)
✅ SCNView added to view hierarchy
🔍 SCNView superview: true
🔍 View controller's view background: Optional(UIExtendedSRGBColorSpace 0 1 0 1)
🖼️ SceneView setup complete
📐 View layout complete, bounds: (0.0, 0.0, 393.0, 852.0)
🏷️ Test label added
📐 Initializing scene...
🎬 Initializing DiceScene
📷 Camera setup complete
💡 Lighting setup complete
🟫 Floor setup complete
🎁 Simple test box added at origin
🎲 Creating DiceNode
   ✓ Geometry created
   ✓ Material applied
   ✓ Physics setup
   ✓ Orientation randomized
🎲 DiceNode initialization complete
🎲 Dice setup complete
⚙️ Physics world setup complete
🖼️ Background setup complete
✅ DiceScene initialization complete
🎬 Scene setup complete
📊 Scene has 6 child nodes (or similar number)
🎲 Dice node exists: true
👆 Gestures setup complete
✅ DiceViewController ready
✅ Window is now key and visible
```

## Quick Fixes Based on What You See:

### Scenario 1: Everything is BLACK
```
Problem: View controller not displaying
Fix: Check SceneDelegate, ensure window is set correctly
```

### Scenario 2: GREEN visible, no RED
```
Problem: SCNView not being added or has wrong frame
Fix: Check view bounds, ensure SCNView frame is correct
```

### Scenario 3: RED visible, no 3D content
```
Problem: Scene not rendering or camera pointing wrong way
Fix: Camera position or scene content issue
```

### Scenario 4: Can see label and SCNView, but no 3D
```
Problem: SceneKit rendering issue
Fix: Check if scene is assigned, check camera settings
```

## After Testing:

**Please report back with:**
1. What colors you saw (green? red? blue label?)
2. Any text visible on screen?
3. Console log output (copy the emoji messages)
4. Any error messages in console?

This will tell us exactly where the problem is!

## Reverting Debug Changes:

Once we identify the issue, I'll remove the debug colors and labels and fix the actual problem. The debug markers are TEMPORARY just for diagnosis.
