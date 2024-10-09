//
//  GameViewController.swift
//  MovementMechanics
//
//  Created by Nathanael Abel on 08/10/24.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var sceneView: CustomSCNView!
    var scene: SCNScene!
    var cameraNode: SCNNode!
    var playerNode: SCNNode!
    var movementSpeed: Float = 2.0
    var direction = SIMD3<Float>(0, 0, 0)
    
    var movementOverlay: UIView! // Overlay for movement buttons
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        addPlayer()
        
        // Ensure buttons are added after setting up the scene
        setupMovementButtons()
        
        // Start updating movement
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .default)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        forceDisableSystemGestures()
    }
    
    // Set up the SceneKit scene and the SCNView
    func setupScene() {
        sceneView = CustomSCNView(frame: self.view.frame) // Use CustomSCNView
        sceneView.allowsCameraControl = false
        sceneView.scene = SCNScene(named: "art.scnassets/MainScene.scn")
        sceneView.scene?.physicsWorld.gravity = SCNVector3(0, -9.8, 0) // Apply gravity
        scene = sceneView.scene
        
        // Remove all gesture recognizers from the sceneView to avoid conflicts
        sceneView.gestureRecognizers?.forEach(sceneView.removeGestureRecognizer)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the sceneView to the main view
        self.view.addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    // Force disable system gestures, especially edge pan
    func forceDisableSystemGestures() {
        if let gestureRecognizers = self.view.window?.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer is UIScreenEdgePanGestureRecognizer || recognizer is UIPanGestureRecognizer {
                    recognizer.isEnabled = false
                }
            }
        }
    }
    
    // Add player as a box with a camera node in front of it for first-person view
    func addPlayer() {
        let boxGeometry = SCNBox(width: 0.5, height: 1.8, length: 0.5, chamferRadius: 0)
        playerNode = SCNNode(geometry: boxGeometry)
        
        // Use a kinematic physics body for manual movement while respecting collisions
        let physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: boxGeometry, options: nil))
        
        // No need to worry about gravity or damping for a kinematic body
        playerNode.physicsBody = physicsBody
        playerNode.position = SCNVector3(0, 1.0, 0) // Slightly above the ground
        
        scene.rootNode.addChildNode(playerNode)
        
        // Create a camera node and position it in front of the box for first-person view
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 1.6, 0.5) // Slightly above and in front of the player box
        playerNode.addChildNode(cameraNode)
    }
    
    // Create movement buttons for iOS touch input
    func setupMovementButtons() {
        let buttonSize: CGFloat = 60
        let buttonSpacing: CGFloat = 20
        
        // Create an overlay for the buttons
        movementOverlay = UIView(frame: self.view.bounds)
        movementOverlay.backgroundColor = .clear
        movementOverlay.isUserInteractionEnabled = true
        self.view.addSubview(movementOverlay)
        
        // Add buttons as subviews
        let wButton = UIButton(frame: CGRect(x: self.view.frame.width / 2 - buttonSize / 2, y: self.view.frame.height - 200, width: buttonSize, height: buttonSize))
        wButton.backgroundColor = .blue
        wButton.setTitle("↑", for: .normal)
        wButton.addTarget(self, action: #selector(moveForward), for: .touchDown)
        wButton.addTarget(self, action: #selector(stopMoving), for: [.touchUpInside, .touchCancel])
        movementOverlay.addSubview(wButton)
        
        // Similar setup for A, S, D buttons
        let aButton = UIButton(frame: CGRect(x: wButton.frame.minX - buttonSize - buttonSpacing, y: wButton.frame.origin.y + buttonSize + buttonSpacing, width: buttonSize, height: buttonSize))
        aButton.backgroundColor = .blue
        aButton.setTitle("←", for: .normal)
        aButton.addTarget(self, action: #selector(moveLeft), for: .touchDown)
        aButton.addTarget(self, action: #selector(stopMoving), for: [.touchUpInside, .touchCancel])
        movementOverlay.addSubview(aButton)
        
        let sButton = UIButton(frame: CGRect(x: wButton.frame.minX, y: wButton.frame.origin.y + buttonSize + buttonSpacing, width: buttonSize, height: buttonSize))
        sButton.backgroundColor = .blue
        sButton.setTitle("↓", for: .normal)
        sButton.addTarget(self, action: #selector(moveBackward), for: .touchDown)
        sButton.addTarget(self, action: #selector(stopMoving), for: [.touchUpInside, .touchCancel])
        movementOverlay.addSubview(sButton)
        
        let dButton = UIButton(frame: CGRect(x: wButton.frame.maxX + buttonSpacing, y: wButton.frame.origin.y + buttonSize + buttonSpacing, width: buttonSize, height: buttonSize))
        dButton.backgroundColor = .blue
        dButton.setTitle("→", for: .normal)
        dButton.addTarget(self, action: #selector(moveRight), for: .touchDown)
        dButton.addTarget(self, action: #selector(stopMoving), for: [.touchUpInside, .touchCancel])
        movementOverlay.addSubview(dButton)
        
        // Ensure buttons are brought to the front
        self.view.bringSubviewToFront(movementOverlay)
    }
    
    // Button actions for movement
    @objc func moveForward() {
        direction.z = -1
        print("Moving forward")
    }
    
    @objc func moveBackward() {
        direction.z = 1
        print("Moving backward")
    }
    
    @objc func moveLeft() {
        direction.x = -1
        print("Moving left")
    }
    
    @objc func moveRight() {
        direction.x = 1
        print("Moving right")
    }
    
    @objc func stopMoving() {
        direction = SIMD3<Float>(0, 0, 0)
        print("Stopped moving")
    }
    
    @objc func update() {
        // Move player using manual control with the kinematic physics body
        let moveSpeed = movementSpeed * 0.1
        let move = SIMD3<Float>(direction.x * moveSpeed, 0, direction.z * moveSpeed)

        if move.x != 0 || move.z != 0 {
            print("Player moving to position x: \(move.x), z: \(move.z)")
        }

        // Manually update the position of the kinematic body
        playerNode.position.x += move.x
        playerNode.position.z += move.z
    }
    
    // Disable edge swipe system gestures
    func disableSystemGestures() {
        if let gestureRecognizers = self.view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer is UIScreenEdgePanGestureRecognizer {
                    recognizer.isEnabled = false
                }
            }
        }
    }
    
    // Disable autorotate and hide status bar
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
