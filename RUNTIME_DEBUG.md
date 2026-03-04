# Runtime Debugging Guide

## How to Debug the Blank Screen

The app has been instrumented with extensive logging. Follow these steps:

### 1. Run in Simulator
1. Open `Dice.xcodeproj` in Xcode
2. Select an iPhone Simulator
3. Press `⌘R` to run
4. Look at the **Xcode Console** (bottom panel - press `⌘⇧Y` if not visible)

### 2. Check Console Output

You should see logs like this if everything is working:

```
🪟 Creating window and view controller
📱 DiceViewController viewDidLoad
📐 View bounds: (0.0, 0.0, 393.0, 852.0)
📐 SCNView frame: (0.0, 0.0, 393.0, 852.0)
✅ SCNView added to view hierarchy
🖼️ SceneView setup complete
🎬 Initializing DiceScene
📷 Camera setup complete
💡 Lighting setup complete
🟫 Floor setup complete
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
📊 Scene has 5 child nodes
🎲 Dice node exists: true
👆 Gestures setup complete
✅ DiceViewController ready
✅ Window is now key and visible
```

### 3. Diagnose Issues

**If you see missing emojis or errors:**
- Look for any lines with "❌" or "error"
- Look for any missing steps (e.g., if you see "Lighting setup" but not "Lighting setup complete")
- Check if view bounds are (0, 0, 0, 0) - this means layout hasn't happened

**Common Issues:**

1. **View bounds are zero**
   - Solution: Move scene setup to `viewDidAppear` instead of `viewDidLoad`

2. **Textures failing to generate**
   - Look for crashes or errors during DiceNode initialization
   - May need to simplify texture generation

3. **Scene not visible**
   - Camera might be pointing wrong direction
   - Lighting might be too dark
   - Background color might match dice color

### 4. Quick Fixes to Try

If the console shows everything initialized but screen is still blank:

#### Fix A: Move Setup to viewDidAppear

Edit `DiceViewController.swift`:
```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if diceScene == nil {
        setupScene()
        setupGestures()
    }
}
```

#### Fix B: Simplify Dice Material

Edit `DiceNode.swift`, replace `applyMaterial()`:
```swift
private func applyMaterial() {
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.white
    self.geometry?.materials = [material]
}
```

#### Fix C: Test with Simple Box

Replace entire `DiceScene.swift` setupDice() method:
```swift
private func setupDice() {
    // Simple test box
    let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
    boxGeometry.firstMaterial?.diffuse.contents = UIColor.red

    diceNode = DiceNode()
    diceNode?.geometry = boxGeometry
    diceNode?.position = SCNVector3(0, 1, 0)

    if let dice = diceNode {
        scene.rootNode.addChildNode(dice)
    }
}
```

### 5. Test Camera Manually

Add this to `viewDidLoad` in `DiceViewController.swift`:
```swift
scnView.allowsCameraControl = true  // Temporarily enable camera control
```

Then in simulator, use mouse to rotate view. If you can see the dice when rotating, the camera position is the issue.

### 6. Share Console Output

If still having issues, copy the ENTIRE console output from when you launch the app and share it. This will show exactly where the problem is.

## Expected Behavior

When working correctly:
- Screen shows dark gray/black background
- White/ivory dice visible in center
- Black pips (dots) visible on dice faces
- FPS counter in top-right shows ~60 FPS
- You can flick/drag the dice and it tumbles

## Most Likely Issue

Based on blank screen symptoms, the most likely causes are:

1. **View layout timing** - `view.bounds` is zero at `viewDidLoad`
2. **Texture generation crash** - Textures are too large or fail to create
3. **Camera pointing at empty space** - Less likely since we set it explicitly

The debug logs will reveal which one it is!
