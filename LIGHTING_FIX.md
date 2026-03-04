# 💡 Soft Lighting Fix

## Problem

The dice surface was **too shiny**, causing the black dots (pips) to become **invisible** due to bright specular reflections washing out the diffuse texture.

## Root Cause

Two issues contributed to excessive shininess:

1. **Overly Bright Lights**:
   - Key light: 2000 intensity (too bright)
   - Top light: 1200 intensity (very bright)
   - Total: 3 bright lights + accent = harsh lighting

2. **Low Roughness Material**:
   - Roughness map: 0.3 (dark gray = smooth/shiny surface)
   - PBR materials with low roughness create mirror-like reflections
   - Bright lights + smooth surface = excessive specular highlights

## Solution

Applied **soft, diffuse lighting** with two key changes:

### 1. Reduced Light Intensity

**Before:**
```swift
keyLight.intensity = 2000    // Very bright directional
topLight.intensity = 1200    // Very bright overhead
accentLight.intensity = 400  // Purple accent
ambientLight.intensity = 300 // Low ambient
```

**After:**
```swift
keyLight.intensity = 800     // Soft directional (60% reduction)
fillLight.intensity = 200    // Subtle fill (replaces bright top light)
ambientLight.intensity = 600 // High ambient (2x increase)
```

### 2. Increased Surface Roughness

**Before:**
```swift
// Roughness map: 0.3 (smooth, shiny surface)
UIColor(white: 0.3, alpha: 1.0).setFill()
```

**After:**
```swift
// Roughness map: 0.75 (matte, diffuse surface)
UIColor(white: 0.75, alpha: 1.0).setFill()
```

## Technical Details

### Lighting Configuration

#### Key Light (Main Directional)
- **Type**: Directional
- **Intensity**: 800 (reduced from 2000)
- **Color**: Neutral soft white (0.95, 0.95, 0.98)
- **Position**: (3, 8, 5)
- **Purpose**: Primary illumination without harsh highlights

#### Fill Light (Subtle Omni)
- **Type**: Omni
- **Intensity**: 200 (replaces 1200 top light)
- **Color**: Soft cool tone (0.7, 0.75, 0.85)
- **Position**: (-3, 5, -2)
- **Purpose**: Fills shadows gently

#### Ambient Light (High Base)
- **Type**: Ambient
- **Intensity**: 600 (doubled from 300)
- **Color**: Soft cool ambient (0.6, 0.65, 0.7)
- **Purpose**: Ensures all surfaces are visible, reduces contrast

### Material Configuration

#### Roughness Map
- **Value**: 0.75 (increased from 0.3)
- **Effect**: Surface scatters light diffusely instead of reflecting it mirror-like
- **Result**: Matte appearance, pips remain visible

#### PBR Material Properties
```swift
material.lightingModel = .physicallyBased
material.diffuse.contents = faceTexture        // White with black pips
material.roughness.contents = roughnessMap     // 0.75 (matte)
material.metalness.contents = metallicMap      // 0.0 (non-metallic)
material.normal.contents = normalMap           // Subtle depth
material.ambientOcclusion.contents = aoMap     // Pip shadows
```

## Before vs After

### Before (Shiny)
- **Key Light**: 2000 intensity → Harsh specular highlights
- **Top Light**: 1200 intensity → Bright spot on top face
- **Accent Light**: 400 intensity → Purple tint
- **Ambient**: 300 intensity → Dark shadows
- **Roughness**: 0.3 → Mirror-like reflections
- **Result**: White surfaces reflect lights brightly, black pips wash out

### After (Soft)
- **Key Light**: 800 intensity → Gentle illumination
- **Fill Light**: 200 intensity → Subtle fill
- **Ambient**: 600 intensity → Bright base light
- **Roughness**: 0.75 → Matte diffuse surface
- **Result**: Even, soft lighting, pips clearly visible

## Lighting Principles Applied

### 1. High Ambient Light
- Bright ambient light (600) ensures all surfaces have base illumination
- Reduces contrast between lit and shadowed areas
- Prevents dark spots where pips disappear

### 2. Low Directional Intensity
- Reduced directional light (800 vs 2000) prevents harsh specular highlights
- Still provides depth and form through subtle shadows
- Doesn't overwhelm the diffuse texture

### 3. Matte Surface (High Roughness)
- Roughness 0.75 scatters light in all directions (diffuse reflection)
- Prevents mirror-like specular reflections
- Maintains texture visibility under all angles

### 4. Simplified Setup
- Removed overly bright top light (was 1200)
- Removed purple accent (was causing color shifts)
- 3 lights total: directional + fill + ambient
- Cleaner, more predictable lighting

## PBR Roughness Scale

In PBR (Physically-Based Rendering):
- **0.0 (black)**: Mirror-like, perfect reflections
- **0.3 (dark gray)**: Smooth, shiny (old value) ❌
- **0.5 (medium gray)**: Semi-matte
- **0.75 (light gray)**: Matte, diffuse (new value) ✅
- **1.0 (white)**: Completely rough, no reflections

## Benefits

✅ **Pips always visible** - No washout from specular highlights
✅ **Soft, even lighting** - No harsh bright spots
✅ **Matte appearance** - Like real plastic/resin dice
✅ **Better readability** - Clear contrast between white and black
✅ **Gaming aesthetic maintained** - Cool color palette preserved
✅ **Performance** - Fewer lights = better performance

## Testing

### Visual Tests

1. **Pip Visibility Test:**
   - Tap dice to throw
   - Observe all faces as dice tumbles
   - Check that pips are visible on all orientations
   - Expected: Black pips clearly visible on white faces

2. **Lighting Angle Test:**
   - Let dice settle on different faces (1-6)
   - Check each face for shininess
   - Expected: No bright specular spots washing out pips

3. **Animation Test:**
   - Throw dice multiple times
   - Watch during tumbling
   - Expected: Pips remain visible throughout motion

### Before/After Comparison

**Before (Shiny):**
- Some angles: Pips invisible due to bright reflections
- Top face especially bright (top light 1200)
- White surface acts like mirror
- Hard to read during tumbling

**After (Soft):**
- All angles: Pips clearly visible
- Even illumination across all faces
- Matte white surface
- Easy to read at all times

## Summary

✅ **Reduced light intensity by 60%** (2000 → 800 key light)
✅ **Increased ambient by 100%** (300 → 600)
✅ **Increased roughness by 150%** (0.3 → 0.75)
✅ **Result**: Soft, matte dice with always-visible pips

The dice now has a **matte finish** similar to real plastic dice, with **soft, even lighting** that ensures the black pips are visible from any angle.
