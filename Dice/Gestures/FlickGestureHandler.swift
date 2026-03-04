//
//  FlickGestureHandler.swift
//  Dice
//
//  Created by Claude Code
//

import UIKit
import SceneKit

class FlickGestureHandler: NSObject, UIGestureRecognizerDelegate {

    private weak var sceneView: SCNView?
    private weak var diceScene: DiceScene?
    private var throwAction: (() -> Void)?

    // Touch tracking properties
    private var touchStartPosition: CGPoint = .zero
    private var touchStartTime: TimeInterval = 0
    private var lastTouchPosition: CGPoint = .zero
    private var lastTouchTime: TimeInterval = 0
    private var touchStartedOnDice: Bool = false

    // Tuning parameters
    private let forceFactor: CGFloat = 1.0           // Multiplier for impulse strength
    private let minVelocityThreshold: CGFloat = 50   // Minimum velocity to register flick (points/sec)
    private let maxVelocityThreshold: CGFloat = 2000 // Maximum velocity cap (points/sec)
    private let randomAngularFactor: CGFloat = 0.2   // Random angular impulse variation

    // Expose pan gesture so tap can require it to fail
    private(set) var panGesture: UIPanGestureRecognizer?

    init(sceneView: SCNView, diceScene: DiceScene, throwAction: @escaping () -> Void) {
        self.sceneView = sceneView
        self.diceScene = diceScene
        self.throwAction = throwAction
        super.init()

        setupGestureRecognizers()
    }

    private func setupGestureRecognizers() {
        // Use pan gesture for better touch tracking
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture?.delegate = self
        if let panGesture = panGesture {
            sceneView?.addGestureRecognizer(panGesture)
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let sceneView = sceneView,
              let diceScene = diceScene else { return }

        let location = gesture.location(in: sceneView)
        let currentTime = Date().timeIntervalSince1970

        switch gesture.state {
        case .began:
            // Check if starting touch is on any active dice
            let hitTestOptions: [SCNHitTestOption: Any] = [
                .categoryBitMask: 1,
                .searchMode: SCNHitTestSearchMode.closest.rawValue
            ]
            let hitResults = sceneView.hitTest(location, options: hitTestOptions)

            // Check if we hit any active dice
            let activeDice = diceScene.getActiveDice()
            touchStartedOnDice = hitResults.first.map { hit in
                activeDice.contains { dice in
                    hit.node == dice || hit.node.parent == dice
                }
            } ?? false

            guard touchStartedOnDice else {
                // Not touching dice, fail gesture immediately
                gesture.state = .failed
                return
            }

            // Record start position and time
            touchStartPosition = location
            touchStartTime = currentTime
            lastTouchPosition = location
            lastTouchTime = currentTime
            print("🖐️ Flick started on dice")

        case .changed:
            // Update last position for velocity calculation
            lastTouchPosition = location
            lastTouchTime = currentTime

        case .ended:
            // Only proceed if touch started on dice
            guard touchStartedOnDice else {
                gesture.state = .failed
                return
            }

            // Calculate velocity and apply impulse
            let totalDeltaX = location.x - touchStartPosition.x
            let totalDeltaY = location.y - touchStartPosition.y
            let totalTime = currentTime - touchStartTime

            guard totalTime > 0 else {
                gesture.state = .failed
                return
            }

            let totalDistance = sqrt(totalDeltaX * totalDeltaX + totalDeltaY * totalDeltaY)
            let velocity = totalDistance / CGFloat(totalTime)

            // Check velocity threshold - if too slow, fail gesture to allow tap
            guard velocity >= minVelocityThreshold else {
                print("⚠️ Flick too slow: \(Int(velocity)) pts/sec (min: \(Int(minVelocityThreshold))) - allowing tap")
                gesture.state = .failed
                return
            }

            // Cap maximum velocity
            let cappedVelocity = min(velocity, maxVelocityThreshold)

            // Calculate direction from start to end
            let direction2D = CGPoint(x: totalDeltaX, y: totalDeltaY)
            let normalizedDirection2D = normalize(direction2D)

            print("🚀 Flick detected: \(Int(cappedVelocity)) pts/sec")

            // Apply flick to all active dice
            applyFlickToActiveDice(
                direction2D: normalizedDirection2D,
                velocity: cappedVelocity,
                touchPoint: location
            )

        default:
            break
        }
    }

    private func applyFlickToActiveDice(direction2D: CGPoint, velocity: CGFloat, touchPoint: CGPoint) {
        guard let sceneView = sceneView,
              let diceScene = diceScene else { return }

        let activeDice = diceScene.getActiveDice()

        for (index, dice) in activeDice.enumerated() {
            // Reset dice velocity
            dice.physicsBody?.velocity = SCNVector3Zero
            dice.physicsBody?.angularVelocity = SCNVector4Zero

            // Lift dice slightly for better flick effect
            var currentPos = dice.position
            currentPos.y = 1.5
            dice.position = currentPos

            // Randomize dice orientation for non-deterministic results
            dice.randomizeOrientation()

            // Convert 2D screen direction to 3D world space with REDUCED force to stay in bounds
            let forceScale: Float = 0.002 // Much smaller to prevent escaping
            let force3D = SCNVector3(
                Float(direction2D.x) * Float(velocity) * forceScale,
                Float(velocity) * forceScale * 0.3, // Small upward component
                -Float(direction2D.y) * Float(velocity) * forceScale
            )

            // Calculate touch point on dice surface for realistic torque
            let hitResults = sceneView.hitTest(touchPoint, options: [:])
            var contactPoint = SCNVector3(0, 0, 0) // Default to center

            if let hit = hitResults.first(where: { $0.node == dice }) {
                contactPoint = hit.localCoordinates
            }

            // Apply force at contact point (creates spin/torque)
            dice.physicsBody?.applyForce(force3D, at: contactPoint, asImpulse: true)

            // Add angular impulse based on flick speed for tumbling
            let angularStrength = min(Float(velocity) * 0.003, 5.0) // Cap at 5
            let randomAngularX = Float.random(in: -angularStrength...angularStrength)
            let randomAngularY = Float.random(in: -angularStrength...angularStrength)
            let randomAngularZ = Float.random(in: -angularStrength...angularStrength)

            let angularImpulse = SCNVector4(randomAngularX, randomAngularY, randomAngularZ, 1.0)
            dice.physicsBody?.applyTorque(angularImpulse, asImpulse: true)

            print("🚀 Die \(index + 1) flick applied: \(Int(velocity)) pts/sec, force=(\(String(format: "%.3f", force3D.x)), \(String(format: "%.3f", force3D.y)), \(String(format: "%.3f", force3D.z))), spin=\(String(format: "%.2f", angularStrength))")
        }
    }

    private func normalize(_ point: CGPoint) -> CGPoint {
        let length = sqrt(point.x * point.x + point.y * point.y)
        guard length > 0 else { return .zero }
        return CGPoint(x: point.x / length, y: point.y / length)
    }
}
