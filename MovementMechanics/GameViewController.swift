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
    
    var sceneView: SCNView!
    var scene: SCNScene!
    var cameraNode: SCNNode!
    var playerNode: SCNNode!
    var movementSpeed: Float = 2.0
    var direction = SIMD3<Float>(0, 0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        addPlayer()
        setupMovementButtons()
        
        // Start updating movement
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .default)
        
        // Disable edge system gestures (for devices with no home button)
        disableSystemGestures()
    }
    
    // Set up the SceneKit scene and the SCNView
    func setupScene() {
        sceneView = self.view as? SCNView
        sceneView.allowsCameraControl = false
        sceneView.scene = SCNScene(named: "art.scnassets/MainScene.scn")
        sceneView.scene?.physicsWorld.gravity = SCNVector3(0, -9.8, 0) // Apply gravity
        scene = sceneView.scene
    }
    
    // Add player as a box with a camera node in front of it for first-person view
    func addPlayer() {
        // Create a box to represent the player
        let boxGeometry = SCNBox(width: 0.5, height: 1.8, length: 0.5, chamferRadius: 0)
        playerNode = SCNNode(geometry: boxGeometry)
        playerNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: boxGeometry, options: nil))
        playerNode.physicsBody?.isAffectedByGravity = true
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
        
        // W Button (Move Forward)
        let wButton = UIButton(frame: CGRect(x: self.view.frame.width / 2 - buttonSize / 2, y: self.view.frame.height - 200, width: buttonSize, height: buttonSize))
        wButton.backgroundColor = .blue
        wButton.setTitle("↑", for: .normal)
        wButton.addTarget(self, action: #selector(moveForward), for: .touchDown)
        wButton.addTarget(self, action: #selector(stopMoving), for: [.touchUpInside, .touchCancel])
        self.view.addSubview(wButton)
        
        // A Button (Move Left)
        let aButton = UIButton(frame: CGRect(x: wButton.frame.minX - buttonSize - buttonSpacing, y: wButton.frame.origin.y + buttonSize + buttonSpacing, width: buttonSize, height: buttonSize))
        aButton.backgroundColor = .blue
        aButton.setTitle("←", for: .normal)
        aButton.addTarget(self, action: #selector(moveLeft), for: .touchDown)
        aButton.addTarget(self, action: #selector(stopMoving), for: [.touchUpInside, .touchCancel])
        self.view.addSubview(aButton)
        
        // S Button (Move Backward)
        let sButton = UIButton(frame: CGRect(x: wButton.frame.minX, y: wButton.frame.origin.y + buttonSize + buttonSpacing, width: buttonSize, height: buttonSize))
        sButton.backgroundColor = .blue
        sButton.setTitle("↓", for: .normal)
        sButton.addTarget(self, action: #selector(moveBackward), for: .touchDown)
        sButton.addTarget(self, action: #selector(stopMoving), for: [.touchUpInside, .touchCancel])
        self.view.addSubview(sButton)
        
        // D Button (Move Right)
        let dButton = UIButton(frame: CGRect(x: wButton.frame.maxX + buttonSpacing, y: wButton.frame.origin.y + buttonSize + buttonSpacing, width: buttonSize, height: buttonSize))
        dButton.backgroundColor = .blue
        dButton.setTitle("→", for: .normal)
        dButton.addTarget(self, action: #selector(moveRight), for: .touchDown)
        dButton.addTarget(self, action: #selector(stopMoving), for: [.touchUpInside, .touchCancel])
        self.view.addSubview(dButton)
    }
    
    // Button actions for movement
    @objc func moveForward() {
        direction.z = -1
    }
    
    @objc func moveBackward() {
        direction.z = 1
    }
    
    @objc func moveLeft() {
        direction.x = -1
    }
    
    @objc func moveRight() {
        direction.x = 1
    }
    
    @objc func stopMoving() {
        direction = SIMD3<Float>(0, 0, 0)
    }
    
    // Update method to move the player smoothly
    @objc func update() {
        let moveSpeed = movementSpeed * 0.1
        let move = SIMD3<Float>(direction.x * moveSpeed, 0, direction.z * moveSpeed)
        
        playerNode.position.x += move.x
        playerNode.position.z += move.z
    }
    
    // Disable edge swipe system gestures
    func disableSystemGestures() {
        let gestureRecognizer = UIScreenEdgePanGestureRecognizer()
        gestureRecognizer.isEnabled = false
        self.view.gestureRecognizers?.forEach { $0.require(toFail: gestureRecognizer) }
    }
    
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
