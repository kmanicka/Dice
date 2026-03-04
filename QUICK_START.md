# Quick Start Guide

## ✅ Build Status: WORKING

The project has been debugged and builds successfully!

## 🎯 Get Rolling in 3 Steps

### 1. Open in Xcode
```bash
cd /Users/kmanickavelu/workspaces/xcode/dice
open Dice.xcodeproj
```

### 2. Select Target
- Choose iPhone simulator (iOS 14.0+) or a connected device
- Recommended: iPhone 14 Pro or newer for best performance

### 3. Build & Run
- Press `⌘R` or click the Play button
- Wait for build to complete
- App launches with a 3D dice on dark background

## 🎲 How to Use

**Flick to Roll:**
1. Touch the dice and drag in any direction
2. The faster you drag, the harder it flicks
3. Release to throw the dice
4. Watch it tumble realistically
5. Result (1-6) appears in Xcode console

**Tips:**
- Gentle swipes = light rolls
- Fast flicks = strong throws
- Very slow drags are ignored (prevents accidental taps)
- Very fast flicks are capped (prevents dice flying away)

## 🔧 Customization

### Make Dice More Bouncy
Edit `Dice/SceneKit/PhysicsConfigurator.swift`:
```swift
static let diceRestitution: CGFloat = 0.6  // Change from 0.4
```

### Make Flicks Stronger
Edit `Dice/Gestures/FlickGestureHandler.swift`:
```swift
private let forceFactor: CGFloat = 1.5  // Change from 1.0
```

### Show Result On Screen (Not Just Console)
Add to `DiceNode.swift` in `onDiceRested()`:
```swift
// Show alert with result
if let topFace = getCurrentTopFace() {
    DispatchQueue.main.async {
        // Add UI code here
    }
}
```

## 📱 Device Requirements

**Minimum:**
- iOS 14.0+
- iPhone 8 or newer (30 FPS)

**Recommended:**
- iOS 15.0+
- iPhone 11 or newer (60 FPS)

**Simulators:**
- Works on all iOS simulators
- Performance may vary based on Mac specs

## 🐛 Troubleshooting

### Build Errors
**"Cannot find DiceViewController"**
- Clean build folder: `⌘⇧K`
- Rebuild: `⌘B`

**Code signing issues**
- Go to project settings → Signing & Capabilities
- Select your team or use automatic signing

### Runtime Issues
**Dice doesn't appear**
- Check Xcode console for errors
- Verify iOS deployment target is 14.0+

**Dice doesn't move when I touch it**
- Make sure you're dragging, not just tapping
- Drag faster to exceed minimum velocity (50 pts/sec)

**Dice flies off screen**
- Reduce `forceFactor` in FlickGestureHandler.swift
- Or reduce `maxVelocityThreshold`

**No result in console**
- Result only prints when dice comes to rest
- Wait ~2 seconds after dice stops moving
- Check dice isn't stuck or still vibrating

## 📊 Performance

### FPS Display
Statistics are shown in top-right corner:
- **60 FPS** = Perfect performance
- **30-60 FPS** = Good performance
- **< 30 FPS** = Reduce quality or use newer device

### Disable Statistics (Production)
Edit `DiceViewController.swift`:
```swift
scnView.showsStatistics = false  // Change from true
```

## 🎨 Visual Improvements

### Add Professional Textures
1. Create/download PBR texture maps (2048×2048):
   - dice_diffuse.png
   - dice_normal.png
   - dice_roughness.png
   - dice_metallic.png
   - dice_ao.png

2. Add to `Dice/Assets.xcassets/DiceTextures/`

3. Edit `DiceNode.swift` `applyMaterial()`:
```swift
material.diffuse.contents = UIImage(named: "dice_diffuse")
material.normal.contents = UIImage(named: "dice_normal")
material.roughness.contents = UIImage(named: "dice_roughness")
material.metalness.contents = UIImage(named: "dice_metallic")
material.ambientOcclusion.contents = UIImage(named: "dice_ao")
```

**Texture Sources:**
- Substance Designer (best quality, has dice templates)
- Poly Haven - polyhaven.com (free)
- Sketchfab - sketchfab.com (some free)
- TurboSquid - turbosquid.com (paid)

## 🚀 Next Features to Add

### Easy Additions (< 30 min each)
1. **Haptic Feedback**
   ```swift
   let impact = UIImpactFeedbackGenerator(style: .heavy)
   impact.impactOccurred()
   ```

2. **Sound Effects**
   - Add roll.wav and land.wav to Assets
   - Use AVAudioPlayer to play on flick/land

3. **On-Screen Result**
   - Add UILabel to show last roll
   - Update in onDiceRested()

### Medium Additions (1-2 hours each)
1. **Shake to Roll**
   - Use CMMotionManager
   - Detect shake gesture
   - Apply random impulse

2. **Roll History**
   - Array to store results
   - TableView to display
   - Calculate statistics

3. **Multiple Dice**
   - Create array of DiceNode
   - Enable collision between dice
   - Sum results

## 💡 Tips & Tricks

**Better Physics Feel:**
- Increase `angularDamping` (0.3 → 0.5) for faster stopping
- Decrease `friction` (0.6 → 0.4) for more sliding
- Increase `restitution` (0.4 → 0.6) for more bounce

**Better Visuals:**
- Add HDRI environment for reflections
- Increase shadow quality
- Add depth of field to camera
- Add motion blur

**Better Performance:**
- Reduce texture resolution (2048 → 1024)
- Disable shadows on fill/rim lights
- Reduce antialiasing (4x → 2x)
- Lower physics time step (60Hz → 30Hz)

## 📚 Learn More

- **README.md** - Full documentation
- **IMPLEMENTATION_SUMMARY.md** - Technical details
- **SceneKit docs** - https://developer.apple.com/scenekit/
- **Physics tutorial** - Search "SceneKit physics" on Apple Developer

## ✅ Verification

Your app is working correctly if:
- [x] Dice appears as white rounded cube
- [x] Black dots visible on faces (1-6 pips)
- [x] Dragging applies force to dice
- [x] Dice tumbles and rotates realistically
- [x] Dice bounces slightly when hitting floor
- [x] Dice eventually comes to rest
- [x] Console prints "🎲 Dice rolled: X" (1-6)
- [x] Each roll gives different results
- [x] FPS counter shows 30+ FPS

## 🎉 You're Ready!

Open `Dice.xcodeproj` and start rolling! 🎲
