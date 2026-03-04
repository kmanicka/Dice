//
//  DiceNode.swift
//  Dice
//
//  Created by Claude Code
//

import UIKit
import SceneKit

class DiceNode: SCNNode {

    // Face normal vectors in local space for result detection
    private let faceNormals: [Int: SCNVector3] = [
        1: SCNVector3(0, 0, 1),
        2: SCNVector3(1, 0, 0),
        3: SCNVector3(0, 1, 0),
        4: SCNVector3(-1, 0, 0),
        5: SCNVector3(0, -1, 0),
        6: SCNVector3(0, 0, -1)
    ]

    private var isResting = false
    private var restTimer: Timer?

    // Callback for when dice settles
    var onSettled: ((Int) -> Void)?

    override init() {
        super.init()

        print("🎲 Creating DiceNode")
        createGeometry()
        print("   ✓ Geometry created")
        applyMaterial()
        print("   ✓ Material applied")
        setupPhysics()
        print("   ✓ Physics setup")
        randomizeOrientation()
        print("   ✓ Orientation randomized")

        // Make sure dice CAN be hit tested (default category bit mask is 1)
        self.categoryBitMask = 1

        print("🎲 DiceNode initialization complete")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createGeometry() {
        // Create larger chamfered box for better visibility in top-down view
        let box = SCNBox(width: 1.5, height: 1.5, length: 1.5, chamferRadius: 0.15)
        box.chamferSegmentCount = 8 // Smooth corners

        self.geometry = box
    }

    private func applyMaterial() {
        // Create 6 materials for 6 faces of the dice
        // SCNBox material order: front, right, back, left, top, bottom
        // Map to dice faces: 1, 2, 6, 5, 3, 4 (standard dice opposite faces sum to 7)

        var materials: [SCNMaterial] = []

        let faceMapping = [1, 2, 6, 5, 3, 4] // Maps SCNBox faces to dice numbers

        for faceNumber in faceMapping {
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased

            // Generate face texture with correct pip count
            if let faceTexture = TextureGenerator.generateFaceTexture(faceNumber: faceNumber) {
                material.diffuse.contents = faceTexture
                print("   ✓ Generated texture for face \(faceNumber)")
            } else {
                // Fallback to solid color if texture generation fails
                material.diffuse.contents = UIColor.white
                print("   ⚠️ Fallback color for face \(faceNumber)")
            }

            material.normal.contents = TextureGenerator.generateNormalMap()
            material.roughness.contents = 0.75  // Matte finish (use scalar instead of 1024x1024 texture)
            material.metalness.contents = 0.0   // Non-metallic (use scalar instead of texture)
            material.ambientOcclusion.contents = UIColor(white: 0.8, alpha: 1.0)  // Subtle AO (use color instead of texture)

            materials.append(material)
        }

        self.geometry?.materials = materials
        print("   🎨 PBR materials applied to all 6 dice faces")
    }

    private func setupPhysics() {
        // Configure physics body with realistic parameters
        PhysicsConfigurator.configureDicePhysics(node: self)

        // Start monitoring velocity for rest detection
        startVelocityMonitoring()
    }

    // MARK: - Orientation

    func randomizeOrientation() {
        // Random rotation for each flick to ensure non-deterministic results
        let randomX = Float.random(in: 0...(2 * .pi))
        let randomY = Float.random(in: 0...(2 * .pi))
        let randomZ = Float.random(in: 0...(2 * .pi))

        self.eulerAngles = SCNVector3(randomX, randomY, randomZ)
    }

    // MARK: - Result Detection

    func getCurrentTopFace() -> Int? {
        // Get world up vector
        let worldUp = SCNVector3(0, 1, 0)

        // Calculate dot product for each face normal with world up
        var maxDot: Float = -1.0
        var topFace: Int?

        for (face, normal) in faceNormals {
            // Transform local normal to world space
            let worldNormal = self.convertVector(normal, to: nil)

            // Calculate dot product
            let dot = dotProduct(worldNormal, worldUp)

            if dot > maxDot {
                maxDot = dot
                topFace = face
            }
        }

        return topFace
    }

    private func dotProduct(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        return a.x * b.x + a.y * b.y + a.z * b.z
    }

    // MARK: - Velocity Monitoring

    private func startVelocityMonitoring() {
        // Monitor velocity to detect when dice stops moving
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkRestState()
        }
    }

    private func checkRestState() {
        guard let physicsBody = self.physicsBody else { return }

        let linearVelocity = physicsBody.velocity
        let angularVelocity = physicsBody.angularVelocity

        let linearSpeed = sqrt(
            linearVelocity.x * linearVelocity.x +
            linearVelocity.y * linearVelocity.y +
            linearVelocity.z * linearVelocity.z
        )

        let angularSpeed = sqrt(
            angularVelocity.x * angularVelocity.x +
            angularVelocity.y * angularVelocity.y +
            angularVelocity.z * angularVelocity.z
        )

        // Check if dice is at rest (velocity threshold < 0.01)
        if linearSpeed < 0.01 && angularSpeed < 0.01 {
            if !isResting {
                isResting = true
                // Wait 0.3 seconds to confirm stable rest
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.onDiceRested()
                }
            }
        } else {
            isResting = false
        }
    }

    private func onDiceRested() {
        guard isResting else { return }

        if let topFace = getCurrentTopFace() {
            print("🎲 Dice rolled: \(topFace)")
            onSettled?(topFace)
        }
    }

    deinit {
        restTimer?.invalidate()
    }
}
