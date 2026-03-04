//
//  PhysicsConfigurator.swift
//  Dice
//
//  Created by Claude Code
//

import SceneKit

class PhysicsConfigurator {

    // MARK: - Physics Constants

    // Dice physics parameters
    static let diceMass: CGFloat = 0.050              // 50 grams (heavier for stability)
    static let diceRestitution: CGFloat = 0.3         // Very low bounce
    static let diceFriction: CGFloat = 0.8            // High friction
    static let diceRollingFriction: CGFloat = 0.5     // Higher resistance to rolling
    static let diceDamping: CGFloat = 0.5             // Higher linear dampening
    static let diceAngularDamping: CGFloat = 0.6      // Higher angular dampening (more controlled tumbling)

    // Board/Table physics parameters
    static let boardRestitution: CGFloat = 0.3        // Wooden/felt surface feel
    static let boardFriction: CGFloat = 0.7           // Good grip on surface

    // MARK: - Configuration Methods

    static func configureDicePhysics(node: SCNNode) {
        // Create dynamic physics body
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)

        // Apply dice physics parameters
        physicsBody.mass = diceMass
        physicsBody.restitution = diceRestitution
        physicsBody.friction = diceFriction
        physicsBody.rollingFriction = diceRollingFriction
        physicsBody.damping = diceDamping
        physicsBody.angularDamping = diceAngularDamping

        // Allow the dice to sleep when at rest for performance
        physicsBody.isAffectedByGravity = true
        physicsBody.allowsResting = true

        node.physicsBody = physicsBody
    }

    static func configureBoardPhysics(node: SCNNode) {
        // Create static physics body
        let physicsBody = SCNPhysicsBody(type: .static, shape: nil)

        // Apply board physics parameters
        physicsBody.restitution = boardRestitution
        physicsBody.friction = boardFriction

        node.physicsBody = physicsBody
    }
}
