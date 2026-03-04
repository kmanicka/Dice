//
//  DiceViewController.swift
//  Dice
//
//  Created by Claude Code
//

import UIKit
import SceneKit
import AudioToolbox

class DiceViewController: UIViewController {

    private var scnView: SCNView!
    private var diceScene: DiceScene!
    private var sceneInitialized = false
    private var flickGestureHandler: FlickGestureHandler!

    // Bottom bar
    private var bottomBar: UIView!
    private var throwButton: UIButton!
    private var settingsButton: UIButton!

    // Settings panel
    private var settingsPanel: UIView!
    private var settingsPanelVisible: Bool = false
    private var diceCountToggle: UISegmentedControl!
    private var soundToggle: UIButton!
    private var hapticsToggle: UIButton!

    // Haptics and Sound
    private var impactGenerator: UIImpactFeedbackGenerator?
    private var soundEnabled: Bool = true
    private var hapticsEnabled: Bool = true

    // Result display
    private var resultLabel: UILabel!
    private var firstLaunch: Bool = true
    private var tooltipLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("📱 DiceViewController viewDidLoad")

        setupSceneView()
        print("🖼️ SceneView setup complete")

        // Setup scene immediately in viewDidLoad
        setupScene()
        print("🎬 Scene setup complete in viewDidLoad")
        setupGestures()
        print("👆 Gestures setup complete")

        // Setup bottom bar with buttons
        setupBottomBar()

        // Setup settings panel
        setupSettingsPanel()

        // Setup haptics
        setupHaptics()

        // Setup result display
        setupResultDisplay()

        // Setup first-time tooltip
        if firstLaunch {
            setupTooltip()
        }
    }

    // MARK: - Bottom Bar Setup

    private func setupBottomBar() {
        // Create bottom bar
        let barHeight: CGFloat = 80
        bottomBar = UIView(frame: CGRect(x: 0, y: view.bounds.height - barHeight, width: view.bounds.width, height: barHeight))
        bottomBar.backgroundColor = AppColors.bottomBarBackground
        bottomBar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]

        // Add subtle top border
        let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 1))
        topBorder.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        topBorder.autoresizingMask = [.flexibleWidth]
        bottomBar.addSubview(topBorder)

        view.addSubview(bottomBar)

        // Add buttons to bottom bar
        setupThrowButton()
        setupSettingsButton()

        print("📊 Bottom bar created")
    }

    private func setupThrowButton() {
        throwButton = UIButton(type: .system)
        throwButton.setTitle("🎲 Roll", for: .normal)
        throwButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        throwButton.backgroundColor = AppColors.primaryBlue
        throwButton.setTitleColor(.white, for: .normal)
        throwButton.layer.cornerRadius = 25

        // Enhanced shadow for depth
        throwButton.layer.shadowColor = UIColor.black.cgColor
        throwButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        throwButton.layer.shadowRadius = 8
        throwButton.layer.shadowOpacity = 0.4

        // Subtle border for definition
        throwButton.layer.borderWidth = 0.5
        throwButton.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor

        // Position in bottom bar (centered)
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 50
        throwButton.frame = CGRect(
            x: (view.bounds.width - buttonWidth) / 2,
            y: 15,
            width: buttonWidth,
            height: buttonHeight
        )
        throwButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        throwButton.addTarget(self, action: #selector(throwDiceButtonTapped), for: .touchUpInside)

        // Add visual feedback
        throwButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        throwButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])

        bottomBar.addSubview(throwButton)
        print("🎲 Throw button added to bottom bar (centered)")
    }

    private func setupSettingsButton() {
        settingsButton = UIButton(type: .system)
        settingsButton.setTitle("⚙️", for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        settingsButton.backgroundColor = AppColors.settingsGray
        settingsButton.setTitleColor(.white, for: .normal)
        settingsButton.layer.cornerRadius = 25

        // Position in bottom bar (right side, icon only)
        let buttonSize: CGFloat = 50
        let padding: CGFloat = 20
        settingsButton.frame = CGRect(
            x: view.bounds.width - buttonSize - padding,
            y: 15,
            width: buttonSize,
            height: buttonSize
        )
        settingsButton.autoresizingMask = [.flexibleLeftMargin]
        settingsButton.addTarget(self, action: #selector(toggleSettings), for: .touchUpInside)

        bottomBar.addSubview(settingsButton)
        print("⚙️ Settings button added to bottom bar (right, icon only)")
    }

    // MARK: - Settings Panel Setup

    private func setupSettingsPanel() {
        let panelHeight: CGFloat = 310
        settingsPanel = UIView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: panelHeight))
        settingsPanel.backgroundColor = AppColors.settingsPanelBackground
        settingsPanel.autoresizingMask = [.flexibleWidth]
        settingsPanel.layer.cornerRadius = 20
        settingsPanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        settingsPanel.layer.shadowColor = UIColor.black.cgColor
        settingsPanel.layer.shadowOffset = CGSize(width: 0, height: -4)
        settingsPanel.layer.shadowRadius = 8
        settingsPanel.layer.shadowOpacity = 0.4

        view.addSubview(settingsPanel)

        // Add settings title
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 20, width: view.bounds.width - 40, height: 30))
        titleLabel.text = "Settings"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.autoresizingMask = [.flexibleWidth]
        settingsPanel.addSubview(titleLabel)

        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.frame = CGRect(x: view.bounds.width - 50, y: 20, width: 30, height: 30)
        closeButton.autoresizingMask = [.flexibleLeftMargin]
        closeButton.addTarget(self, action: #selector(toggleSettings), for: .touchUpInside)
        settingsPanel.addSubview(closeButton)

        // Add dice count label
        let diceLabel = UILabel(frame: CGRect(x: 20, y: 70, width: view.bounds.width - 40, height: 20))
        diceLabel.text = "Number of Dice"
        diceLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        diceLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        diceLabel.autoresizingMask = [.flexibleWidth]
        settingsPanel.addSubview(diceLabel)

        // Add dice count toggle
        setupDiceCountToggle()

        // Add sound label
        let soundLabel = UILabel(frame: CGRect(x: 20, y: 145, width: view.bounds.width - 40, height: 20))
        soundLabel.text = "Sound"
        soundLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        soundLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        soundLabel.autoresizingMask = [.flexibleWidth]
        settingsPanel.addSubview(soundLabel)

        // Add sound toggle
        setupSoundToggle()

        // Add haptics label
        let hapticsLabel = UILabel(frame: CGRect(x: 20, y: 205, width: view.bounds.width - 40, height: 20))
        hapticsLabel.text = "Haptics"
        hapticsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        hapticsLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        hapticsLabel.autoresizingMask = [.flexibleWidth]
        settingsPanel.addSubview(hapticsLabel)

        // Add haptics toggle
        setupHapticsToggle()

        print("⚙️ Settings panel created (hidden)")
    }

    private func setupDiceCountToggle() {
        // Create segmented control for 1 or 2 dice
        diceCountToggle = UISegmentedControl(items: ["1 Dice", "2 Dice"])
        diceCountToggle.selectedSegmentIndex = 0

        // Style the toggle
        diceCountToggle.backgroundColor = AppColors.toggleBackground
        diceCountToggle.selectedSegmentTintColor = AppColors.primaryBlue
        diceCountToggle.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        diceCountToggle.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)

        // Position in settings panel
        diceCountToggle.frame = CGRect(x: 20, y: 95, width: view.bounds.width - 40, height: 36)
        diceCountToggle.autoresizingMask = [.flexibleWidth]
        diceCountToggle.addTarget(self, action: #selector(diceCountChanged), for: .valueChanged)

        settingsPanel.addSubview(diceCountToggle)
    }

    private func setupSoundToggle() {
        soundToggle = UIButton(type: .system)
        updateSoundToggleAppearance()
        soundToggle.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        soundToggle.backgroundColor = AppColors.toggleBackground
        soundToggle.setTitleColor(.white, for: .normal)
        soundToggle.layer.cornerRadius = 18
        soundToggle.contentHorizontalAlignment = .left
        soundToggle.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        // Position in settings panel
        soundToggle.frame = CGRect(x: 20, y: 170, width: view.bounds.width - 40, height: 36)
        soundToggle.autoresizingMask = [.flexibleWidth]
        soundToggle.addTarget(self, action: #selector(toggleSound), for: .touchUpInside)

        settingsPanel.addSubview(soundToggle)
    }

    private func setupHapticsToggle() {
        hapticsToggle = UIButton(type: .system)
        updateHapticsToggleAppearance()
        hapticsToggle.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        hapticsToggle.backgroundColor = AppColors.toggleBackground
        hapticsToggle.setTitleColor(.white, for: .normal)
        hapticsToggle.layer.cornerRadius = 18
        hapticsToggle.contentHorizontalAlignment = .left
        hapticsToggle.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        // Position in settings panel
        hapticsToggle.frame = CGRect(x: 20, y: 230, width: view.bounds.width - 40, height: 36)
        hapticsToggle.autoresizingMask = [.flexibleWidth]
        hapticsToggle.addTarget(self, action: #selector(toggleHaptics), for: .touchUpInside)

        settingsPanel.addSubview(hapticsToggle)
    }

    // MARK: - Actions

    @objc private func toggleSettings() {
        settingsPanelVisible.toggle()

        let panelY = settingsPanelVisible ? view.bounds.height - 310 - 80 : view.bounds.height

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.settingsPanel.frame.origin.y = panelY
        }

        print("⚙️ Settings panel \(settingsPanelVisible ? "shown" : "hidden")")
    }

    @objc private func toggleSound() {
        soundEnabled.toggle()
        updateSoundToggleAppearance()
        print("🔊 Sound toggled: \(soundEnabled)")
    }

    @objc private func toggleHaptics() {
        hapticsEnabled.toggle()
        updateHapticsToggleAppearance()
        print("📳 Haptics toggled: \(hapticsEnabled)")
    }

    private func updateSoundToggleAppearance() {
        if soundEnabled {
            soundToggle.setTitle("🔊  Enabled", for: .normal)
        } else {
            soundToggle.setTitle("🔇  Disabled", for: .normal)
        }
    }

    private func updateHapticsToggleAppearance() {
        if hapticsEnabled {
            hapticsToggle.setTitle("📳  Enabled", for: .normal)
        } else {
            hapticsToggle.setTitle("  Disabled", for: .normal)
        }
    }

    @objc private func diceCountChanged() {
        let count = diceCountToggle.selectedSegmentIndex + 1
        diceScene.setDiceCount(count)
        print("🔄 Dice count changed to: \(count)")
    }

    private func setupHaptics() {
        impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator?.prepare()
    }

    private func setupResultDisplay() {
        // Create large result number display
        resultLabel = UILabel()
        resultLabel.font = UIFont.systemFont(ofSize: 96, weight: .bold)
        resultLabel.textColor = .white
        resultLabel.textAlignment = .center
        resultLabel.alpha = 0
        resultLabel.layer.shadowColor = UIColor.black.cgColor
        resultLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        resultLabel.layer.shadowRadius = 8
        resultLabel.layer.shadowOpacity = 0.5

        resultLabel.frame = CGRect(x: 0, y: view.bounds.height / 3, width: view.bounds.width, height: 120)
        resultLabel.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]

        view.addSubview(resultLabel)
        print("🎯 Result display created")
    }

    private func setupTooltip() {
        // Create tooltip for first-time users
        tooltipLabel = UILabel()
        tooltipLabel.text = "👆 Tap or flick dice to roll"
        tooltipLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tooltipLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        tooltipLabel.textAlignment = .center
        tooltipLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        tooltipLabel.layer.cornerRadius = 12
        tooltipLabel.clipsToBounds = true

        let tooltipWidth: CGFloat = 250
        let tooltipHeight: CGFloat = 44
        tooltipLabel.frame = CGRect(
            x: (view.bounds.width - tooltipWidth) / 2,
            y: view.bounds.height / 2 - 50,
            width: tooltipWidth,
            height: tooltipHeight
        )
        tooltipLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]

        view.addSubview(tooltipLabel)

        // Fade out after 3 seconds
        UIView.animate(withDuration: 0.5, delay: 3.0, options: .curveEaseOut) {
            self.tooltipLabel.alpha = 0
        } completion: { _ in
            self.tooltipLabel.removeFromSuperview()
            self.firstLaunch = false
        }

        print("💬 First-time tooltip displayed")
    }

    func showResult(_ number: Int) {
        resultLabel.text = "\(number)"

        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseIn) {
            self.resultLabel.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 2.0, options: .curveEaseOut) {
                self.resultLabel.alpha = 0
            }
        }
    }

    @objc private func buttonTouchDown() {
        throwButton.backgroundColor = AppColors.primaryBlueDark
        throwButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }

    @objc private func buttonTouchUp() {
        throwButton.backgroundColor = AppColors.primaryBlue
        throwButton.transform = CGAffineTransform.identity
    }

    @objc private func throwDiceButtonTapped() {
        let activeDice = diceScene.getActiveDice()
        guard !activeDice.isEmpty else {
            print("❌ ERROR: No active dice!")
            return
        }

        // Play haptic feedback
        if hapticsEnabled {
            impactGenerator?.impactOccurred(intensity: 0.8)
        }

        // Play dice rolling sound
        if soundEnabled {
            playDiceRollSound()
        }

        print("🎲 ========== THROW INITIATED (\(activeDice.count) dice) ==========")

        for (index, dice) in activeDice.enumerated() {
            // Reset position to random spot within safe bounds
            // Spread dice apart if there are multiple
            let baseOffsetX: Float = activeDice.count == 2 ? (index == 0 ? -1.5 : 1.5) : 0
            let randomX = baseOffsetX + Float.random(in: -0.5...0.5)
            let randomZ = Float.random(in: -2.0...2.0)

            dice.position = SCNVector3(randomX, 2.5, randomZ) // Elevated for tumbling
            dice.physicsBody?.velocity = SCNVector3Zero
            dice.physicsBody?.angularVelocity = SCNVector4Zero

            print("📍 Die \(index + 1) repositioned to (\(randomX), 2.5, \(randomZ))")

            // Randomize initial orientation
            dice.randomizeOrientation()

            // Apply SMALL controlled impulse to keep dice within bounds
            let impulseX = Float.random(in: -0.3...0.3)
            let impulseY = Float.random(in: -0.2...0.0) // Gentle downward
            let impulseZ = Float.random(in: -0.3...0.3)
            let impulse = SCNVector3(impulseX, impulseY, impulseZ)

            dice.physicsBody?.applyForce(impulse, asImpulse: true)
            print("💨 Die \(index + 1) force: (\(impulseX), \(impulseY), \(impulseZ))")

            // Apply moderate angular impulse for tumbling
            let randomAngularX = Float.random(in: -5...5)
            let randomAngularY = Float.random(in: -5...5)
            let randomAngularZ = Float.random(in: -5...5)
            let angularImpulse = SCNVector4(randomAngularX, randomAngularY, randomAngularZ, 1.0)

            dice.physicsBody?.applyTorque(angularImpulse, asImpulse: true)
            print("🌀 Die \(index + 1) torque: (\(randomAngularX), \(randomAngularY), \(randomAngularZ))")
        }

        print("✅ Throw complete - \(activeDice.count) dice contained in bounding box")
    }

    private func setupSceneView() {
        // Create and configure SCNView
        scnView = SCNView(frame: view.bounds)
        scnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Modern gaming gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            AppColors.gradientTop.cgColor,
            AppColors.gradientMiddle.cgColor,
            AppColors.gradientBottom.cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)

        scnView.backgroundColor = .clear // Transparent to show gradient

        print("📐 View bounds: \(view.bounds)")
        print("📐 SCNView frame: \(scnView.frame)")

        // Configure rendering quality
        scnView.antialiasingMode = .multisampling4X
        scnView.preferredFramesPerSecond = 60

        // Clean production settings
        scnView.showsStatistics = false
        scnView.allowsCameraControl = false

        view.addSubview(scnView)
        print("✅ SCNView with gaming gradient background added")
    }

    private func setupScene() {
        // Initialize and set the dice scene
        diceScene = DiceScene()
        scnView.scene = diceScene.scene

        // Setup result callbacks for all dice
        for dice in diceScene.diceNodes {
            dice.onSettled = { [weak self] result in
                self?.showResult(result)
            }
        }

        // Start idle animation
        diceScene.startIdleAnimation()

        print("📊 Scene has \(diceScene.scene.rootNode.childNodes.count) child nodes")
        print("🎲 Dice node exists: \(diceScene.diceNode != nil)")
    }

    private func setupGestures() {
        // Initialize flick gesture handler for swipe-to-throw
        // Pass all dice nodes so any can be flicked
        flickGestureHandler = FlickGestureHandler(
            sceneView: scnView,
            diceScene: diceScene,
            throwAction: { [weak self] in
                self?.throwDiceButtonTapped()
            }
        )

        // Add tap gesture recognizer for click-to-throw on dice
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1

        // Make tap wait for pan to fail (flick has priority)
        if let panGesture = flickGestureHandler.panGesture {
            tapGesture.require(toFail: panGesture)
        }

        scnView.addGestureRecognizer(tapGesture)

        print("👆 Gestures enabled:")
        print("   - Tap on dice: Random throw")
        print("   - Flick/swipe on dice: Directional throw")
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: scnView)

        // Hit test with options to only find nodes with categoryBitMask 1 (the dice)
        let hitTestOptions: [SCNHitTestOption: Any] = [
            .categoryBitMask: 1,
            .searchMode: SCNHitTestSearchMode.closest.rawValue
        ]
        let hitResults = scnView.hitTest(location, options: hitTestOptions)

        print("👆 Tap at location \(location), hits: \(hitResults.count)")

        // Check if we hit any dice
        if let hitResult = hitResults.first {
            // Check if the hit node is one of our dice
            let activeDice = diceScene.getActiveDice()
            let hitADice = activeDice.contains { dice in
                hitResult.node == dice || hitResult.node.parent == dice
            }

            if hitADice {
                print("🎲 Dice tapped! Initiating random throw...")
                throwDiceButtonTapped()
            } else {
                print("👆 Tapped background - no action")
            }
        } else {
            print("👆 Tapped background - no action (hits: \(hitResults.count))")
        }
    }

    // MARK: - Sound Effects

    private func playDiceRollSound() {
        // Use system sound for dice roll
        // Sound ID 1104 is a good dice-like click sound
        // We play it multiple times with slight delays for rolling effect
        AudioServicesPlaySystemSound(1104)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            AudioServicesPlaySystemSound(1104)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            AudioServicesPlaySystemSound(1104)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true // Minimalistic - no status bar
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - App Colors

private enum AppColors {
    static let gradientTop = UIColor(red: 0.08, green: 0.05, blue: 0.15, alpha: 1.0)
    static let gradientMiddle = UIColor(red: 0.05, green: 0.10, blue: 0.20, alpha: 1.0)
    static let gradientBottom = UIColor(red: 0.0, green: 0.15, blue: 0.20, alpha: 1.0)
    static let primaryBlue = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
    static let primaryBlueDark = UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0)
    static let settingsGray = UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
    static let toggleBackground = UIColor(red: 0.25, green: 0.25, blue: 0.3, alpha: 1.0)
    static let bottomBarBackground = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.95)
    static let settingsPanelBackground = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 0.98)
}
