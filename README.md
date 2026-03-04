# Dice - Minimalistic 3D Dice iOS App

Ultra-minimalistic iOS app featuring a single 3D die with photorealistic graphics and physics-based interaction.

## Features

- **3D Dice**: Realistic chamfered cube with rounded edges
- **Physics Simulation**: SceneKit physics engine (Bullet Physics) for realistic tumbling
- **Flick Gesture**: Natural touch interaction - flick the dice to roll
- **PBR Materials**: Physically-based rendering with diffuse, normal, roughness, metallic, and AO maps
- **Three-Point Lighting**: Professional lighting setup with key, fill, and rim lights
- **Result Detection**: Automatically detects which face lands on top (1-6)

## How to Use

1. Open `Dice.xcodeproj` in Xcode
2. Select a target device (iOS 14.0+)
3. Build and run (⌘R)
4. Flick the dice with your finger to roll
5. Watch the dice tumble realistically and land on a number
6. The result will be printed in the console

## Implementation Details

### Architecture
- **Framework**: SceneKit (not RealityKit)
- **Pattern**: MVC with SceneKit layer
- **Physics**: Bullet Physics via SceneKit

### Key Components

#### DiceViewController
- Main view controller with SCNView
- Configures rendering quality (4x multisampling, 60 FPS)
- Hides status bar for minimalistic appearance

#### DiceScene
- Scene setup with camera, lighting, and physics world
- Fixed perspective camera at (0, 3, 5)
- Three-point lighting + ambient
- Physics floor/board for dice collision
- Standard Earth gravity (9.8 m/s²)

#### DiceNode
- Chamfered box geometry (1×1×1 units, corner radius 0.1)
- PBR materials with generated textures
- Physics body with realistic parameters:
  - Mass: 10 grams
  - Restitution: 0.4 (low bounce)
  - Friction: 0.6
  - Angular damping: 0.3
- Result detection using dot product of face normals
- Velocity monitoring for rest state detection

#### PhysicsConfigurator
- Centralized physics parameters
- Easy tuning without hunting through code
- Separate configurations for dice and board

#### FlickGestureHandler
- Touch tracking (position, velocity, timing)
- Converts 2D screen gestures to 3D physics impulses
- Force magnitude tuning
- Random angular impulse for variation
- Velocity thresholds (min: 50, max: 2000 pts/sec)

#### TextureGenerator
- Programmatically generates PBR texture maps
- Diffuse map with pips (1-6 faces)
- Normal, roughness, metallic, and AO maps
- 2048×2048 resolution

### Physics Parameters

```swift
// Dice
mass: 0.010 kg (10 grams)
restitution: 0.4
friction: 0.6
rollingFriction: 0.3
damping: 0.1
angularDamping: 0.3

// Board
restitution: 0.3 (wooden/felt surface)
friction: 0.7
```

### Performance

- **Target**: 60 FPS on iPhone 11+
- **Fallback**: 30+ FPS on iPhone 8+
- **Optimizations**:
  - 4x multisampling antialiasing
  - Physics simulation at 60Hz
  - Dice geometry under 5000 triangles

## Customization

### Adjust Physics Feel

Edit `PhysicsConfigurator.swift`:
```swift
static let diceFriction: CGFloat = 0.6        // Higher = less sliding
static let diceRestitution: CGFloat = 0.4     // Higher = more bouncy
static let diceAngularDamping: CGFloat = 0.3  // Higher = stops rotating faster
```

### Adjust Gesture Sensitivity

Edit `FlickGestureHandler.swift`:
```swift
private let forceFactor: CGFloat = 1.0           // Higher = stronger flicks
private let minVelocityThreshold: CGFloat = 50   // Lower = more sensitive
private let maxVelocityThreshold: CGFloat = 2000 // Higher = allows faster flicks
```

### Improve Textures

Replace programmatic textures in `TextureGenerator.swift` with professional PBR maps:
1. Create or download high-quality textures (2048×2048)
2. Add to `Assets.xcassets/DiceTextures/`
3. Update `DiceNode.applyMaterial()`:
```swift
material.diffuse.contents = UIImage(named: "dice_diffuse")
material.normal.contents = UIImage(named: "dice_normal")
// etc.
```

Recommended sources:
- Substance Designer (has dice templates)
- Poly Haven (polyhaven.com)
- Sketchfab
- TurboSquid

## Project Structure

```
Dice/
├── Dice.xcodeproj
├── Dice/
│   ├── App/
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   └── Info.plist
│   ├── Views/
│   │   └── DiceViewController.swift
│   ├── SceneKit/
│   │   ├── DiceScene.swift
│   │   ├── DiceNode.swift
│   │   ├── PhysicsConfigurator.swift
│   │   └── TextureGenerator.swift
│   ├── Gestures/
│   │   └── FlickGestureHandler.swift
│   └── Assets.xcassets/
└── README.md
```

## Roadmap

### Potential Enhancements
- [ ] Professional PBR textures (Substance Designer)
- [ ] HDRI environment lighting for better reflections
- [ ] Haptic feedback on flick and land
- [ ] Sound effects (dice rolling, landing)
- [ ] Multiple dice with collision
- [ ] Different dice types (D4, D8, D12, D20)
- [ ] Save roll history
- [ ] Shake to roll gesture

## Technical Notes

### Why SceneKit over RealityKit?
- Mature physics engine (Bullet Physics)
- Full control over physics parameters
- Lighter weight (no AR overhead)
- Better for single-object use case
- More extensive documentation and examples

### Randomness
- Physics simulation provides natural randomness
- Initial orientation randomized on each flick
- Small random angular impulses ensure non-deterministic results
- Over 100 rolls, distribution should be roughly even (~16.7% per face)

## Requirements

- iOS 14.0+
- Xcode 12.0+
- iPhone or iPad

## License

This is a demonstration project created with Claude Code.

## Credits

- Created by Claude Code
- Physics: SceneKit (Bullet Physics)
- Rendering: SceneKit (Metal)
