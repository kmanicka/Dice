//
//  DiceScene.swift
//  Dice
//
//  Created by Claude Code
//

import UIKit
import SceneKit

class DiceScene {

    let scene: SCNScene
    var diceNode: DiceNode?  // Legacy - first dice for backward compatibility
    var diceNodes: [DiceNode] = []  // All dice nodes
    private var cameraNode: SCNNode!
    private var floorNode: SCNNode!
    private(set) var activeDiceCount: Int = 1  // Current number of active dice

    init() {
        scene = SCNScene()

        print("🎬 Initializing DiceScene")
        setupCamera()
        print("📷 Camera setup complete")
        setupLighting()
        print("💡 Lighting setup complete")
        setupFloor()
        print("🟫 Floor setup complete")
        setupDice()
        print("🎲 Dice setup complete")
        setupPhysicsWorld()
        print("⚙️ Physics world setup complete")
        setupBackground()
        print("🖼️ Background setup complete")
        print("✅ DiceScene initialization complete")
    }

    private func setupCamera() {
        // Create camera - top-down view for full-screen tray
        let camera = SCNCamera()
        camera.fieldOfView = 60
        camera.zNear = 0.1
        camera.zFar = 100

        // Create camera node - positioned directly above for top-down view
        cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 12, 0) // High above for top-down view
        cameraNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0) // Look straight down

        scene.rootNode.addChildNode(cameraNode)
        print("📷 Camera positioned at (0, 12, 0) looking straight down")
    }

    private func setupLighting() {
        // Soft directional light - REDUCED intensity to prevent shininess
        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.intensity = 800  // Reduced from 2000
        keyLight.color = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0) // Neutral soft white
        keyLight.castsShadow = true
        keyLight.shadowMode = .deferred
        keyLight.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3) // Soft shadow

        let keyLightNode = SCNNode()
        keyLightNode.light = keyLight
        keyLightNode.position = SCNVector3(3, 8, 5)
        keyLightNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(keyLightNode)

        // Subtle fill light - very soft
        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.intensity = 200  // Reduced from 400
        fillLight.color = UIColor(red: 0.7, green: 0.75, blue: 0.85, alpha: 1.0) // Soft cool tone

        let fillLightNode = SCNNode()
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(-3, 5, -2)
        scene.rootNode.addChildNode(fillLightNode)

        // High ambient light - fills in shadows softly
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 600  // Increased from 300 for softer overall look
        ambientLight.color = UIColor(red: 0.6, green: 0.65, blue: 0.7, alpha: 1.0) // Soft cool ambient

        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)

        print("💡 Soft lighting setup complete (reduced intensity, high ambient)")
    }

    private func setupFloor() {
        // Create invisible floor with physics only (no visible geometry)
        let floorGeometry = SCNBox(width: 10, height: 0.2, length: 10, chamferRadius: 0)

        // Make floor completely transparent
        floorGeometry.materials = [createInvisibleMaterial()]

        floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3(0, -0.1, 0)

        // Add physics body for collision
        let floorShape = SCNPhysicsShape(geometry: floorGeometry, options: nil)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: floorShape)
        floorNode.physicsBody?.restitution = 0.4
        floorNode.physicsBody?.friction = 0.7

        // Make floor invisible to hit tests
        floorNode.isHidden = false
        floorNode.categoryBitMask = 0 // Don't participate in hit tests

        scene.rootNode.addChildNode(floorNode)
        print("🟫 Invisible floor with physics created (10x10) at y=-0.1")

        // Create transparent bounding box
        setupTrayWalls()
    }

    private func setupTrayWalls() {
        // Calculate visible area based on camera setup
        // Camera at y=12, FOV=60°, looking straight down
        let cameraHeight: CGFloat = 12.0
        let fov: CGFloat = 60.0

        // Calculate how much area is visible at y=0 (floor level)
        let fovRadians = fov * .pi / 180.0
        let visibleWidthAtFloor = 2.0 * tan(fovRadians / 2.0) * cameraHeight

        // Assume aspect ratio of typical iPhone (roughly 9:19.5 or ~0.46)
        let aspectRatio: CGFloat = 0.46 // width/height

        // Add margins to keep dice away from edges
        let marginFactor: CGFloat = 0.90 // 90% of visible area (10% margin)
        let visibleWidth = visibleWidthAtFloor * aspectRatio * marginFactor
        let visibleHeight = visibleWidthAtFloor * marginFactor

        // Dice is 1.5 units, reduce height slightly to account for bottom bar
        let diceSize: CGFloat = 1.5
        let boundingHeight: CGFloat = 2.7 * diceSize // 4.05 units

        let wallThickness: CGFloat = 0.5

        print("📏 Calculated bounding box with margins:")
        print("   Width: \(visibleWidth), Height: \(visibleHeight), Ceiling: \(boundingHeight)")
        print("   Margin factor: \(marginFactor) (10% margin on all sides)")

        // Invisible material for all walls
        let invisibleMaterial = createInvisibleMaterial()

        // Create walls
        createWall(
            geometry: SCNBox(width: visibleWidth, height: boundingHeight, length: wallThickness, chamferRadius: 0),
            position: SCNVector3(0, boundingHeight/2, visibleHeight/2),
            material: invisibleMaterial
        )
        createWall(
            geometry: SCNBox(width: visibleWidth, height: boundingHeight, length: wallThickness, chamferRadius: 0),
            position: SCNVector3(0, boundingHeight/2, -visibleHeight/2),
            material: invisibleMaterial
        )
        createWall(
            geometry: SCNBox(width: wallThickness, height: boundingHeight, length: visibleHeight, chamferRadius: 0),
            position: SCNVector3(-visibleWidth/2, boundingHeight/2, 0),
            material: invisibleMaterial
        )
        createWall(
            geometry: SCNBox(width: wallThickness, height: boundingHeight, length: visibleHeight, chamferRadius: 0),
            position: SCNVector3(visibleWidth/2, boundingHeight/2, 0),
            material: invisibleMaterial
        )
        createWall(
            geometry: SCNBox(width: visibleWidth, height: wallThickness, length: visibleHeight, chamferRadius: 0),
            position: SCNVector3(0, boundingHeight, 0),
            material: invisibleMaterial
        )

        print("🎯 Transparent bounding box created:")
        print("   Dimensions: \(visibleWidth) x \(visibleHeight) x \(boundingHeight)")
        print("   4 walls + ceiling with physics collision")
    }

    private func setupDice() {
        // Create 2 dice (we'll show/hide based on active count)
        for i in 0..<2 {
            let dice = DiceNode()

            // Position dice side by side when both are active
            if i == 0 {
                dice.position = SCNVector3(0, 0.8, 0) // Center position for single die
            } else {
                dice.position = SCNVector3(2.0, 0.8, 0) // Right side, initially
                dice.isHidden = true // Hide second die by default
            }

            scene.rootNode.addChildNode(dice)
            diceNodes.append(dice)

            print("🎲 Dice \(i + 1) added to scene")
        }

        // Set legacy diceNode to first dice for backward compatibility
        diceNode = diceNodes.first

        print("🎲 \(diceNodes.count) dice created, \(activeDiceCount) active")
    }

    private func setupPhysicsWorld() {
        // Configure physics world
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0) // Standard Earth gravity
        scene.physicsWorld.timeStep = 1.0 / 60.0 // 60 FPS physics simulation
    }

    private func setupBackground() {
        // Background is handled by DiceViewController gradient layer
        // SceneKit background is transparent to show through
        scene.background.contents = UIColor.clear
        print("🎨 Transparent background (gradient in view layer)")
    }

    // MARK: - Helper Methods

    private func createInvisibleMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        material.writesToDepthBuffer = true
        return material
    }

    private func createWall(geometry: SCNGeometry, position: SCNVector3, material: SCNMaterial) {
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        node.position = position
        node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: geometry, options: nil))
        node.physicsBody?.friction = 0.3
        node.physicsBody?.restitution = 0.6
        node.categoryBitMask = 0 // Don't participate in hit tests
        scene.rootNode.addChildNode(node)
    }

    // MARK: - Public Methods

    func setDiceCount(_ count: Int) {
        guard count >= 1 && count <= 2 else { return }
        activeDiceCount = count

        if count == 1 {
            // Single die - center position
            diceNodes[0].isHidden = false
            diceNodes[0].position = SCNVector3(0, 0.8, 0)

            if diceNodes.count > 1 {
                diceNodes[1].isHidden = true
            }

            print("🎲 Switched to 1 die mode")
        } else {
            // Two dice - side by side
            diceNodes[0].isHidden = false
            diceNodes[0].position = SCNVector3(-1.2, 0.8, 0) // Left

            if diceNodes.count > 1 {
                diceNodes[1].isHidden = false
                diceNodes[1].position = SCNVector3(1.2, 0.8, 0) // Right
            }

            print("🎲 Switched to 2 dice mode")
        }
    }

    func getActiveDice() -> [DiceNode] {
        return diceNodes.prefix(activeDiceCount).map { $0 }
    }

    func resetDice() {
        guard let dice = diceNode else { return }

        // Reset position and velocity
        dice.position = SCNVector3(0, 1, 0)
        dice.physicsBody?.velocity = SCNVector3Zero
        dice.physicsBody?.angularVelocity = SCNVector4Zero

        // Randomize orientation
        dice.randomizeOrientation()
    }
}
