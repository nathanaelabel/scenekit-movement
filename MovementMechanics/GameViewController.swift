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
    var movementOverlay: UIView!
    var movementSpeed: Float = 2.0
    var direction = SIMD3<Float>(0, 0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        addPlayer()
        sceneView.pointOfView = cameraNode
        setupMovementButtons()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .default)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        forceDisableSystemGestures()
    }
    
    func setupScene() {
        sceneView = CustomSCNView(frame: self.view.frame)
        sceneView.allowsCameraControl = false
        sceneView.scene = SCNScene(named: "art.scnassets/MainScene.scn")
        sceneView.scene?.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        scene = sceneView.scene
        
        sceneView.gestureRecognizers?.forEach(sceneView.removeGestureRecognizer)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    func forceDisableSystemGestures() {
        if let gestureRecognizers = self.view.window?.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer is UIScreenEdgePanGestureRecognizer || recognizer is UIPanGestureRecognizer {
                    recognizer.isEnabled = false
                }
            }
        }
    }
    
    func addPlayer() {
        let boxGeometry = SCNBox(width: 0.5, height: 1.8, length: 0.5, chamferRadius: 0)
        playerNode = SCNNode(geometry: boxGeometry)
        
        let physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: boxGeometry, options: nil))
        playerNode.physicsBody = physicsBody
        playerNode.position = SCNVector3(0, 1.0, 0)
        
        scene.rootNode.addChildNode(playerNode)
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0.75, 0)
        playerNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
    }
    
    func setupMovementButtons() {
        let buttonSize: CGFloat = 60
        let buttonSpacing: CGFloat = 20
        
        movementOverlay = UIView(frame: self.view.bounds)
        movementOverlay.backgroundColor = .clear
        movementOverlay.isUserInteractionEnabled = true
        self.view.addSubview(movementOverlay)
        
        let wButton = UIButton(frame: CGRect(x: self.view.frame.width / 2 - buttonSize / 2, y: self.view.frame.height - 200, width: buttonSize, height: buttonSize))
        wButton.backgroundColor = .blue
        wButton.setTitle("↑", for: .normal)
        wButton.addTarget(self, action: #selector(moveForward), for: .touchDown)
        wButton.addTarget(self, action: #selector(stopMoving), for: [.touchUpInside, .touchCancel])
        movementOverlay.addSubview(wButton)
        
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
        
        let rotateLeftButton = UIButton(frame: CGRect(x: aButton.frame.minX - buttonSize - buttonSpacing, y: aButton.frame.origin.y, width: buttonSize, height: buttonSize))
        rotateLeftButton.backgroundColor = .green
        rotateLeftButton.setTitle("↺", for: .normal)
        rotateLeftButton.addTarget(self, action: #selector(rotateLeft), for: .touchDown)
        movementOverlay.addSubview(rotateLeftButton)
        
        let rotateRightButton = UIButton(frame: CGRect(x: dButton.frame.maxX + buttonSpacing, y: dButton.frame.origin.y, width: buttonSize, height: buttonSize))
        rotateRightButton.backgroundColor = .green
        rotateRightButton.setTitle("↻", for: .normal)
        rotateRightButton.addTarget(self, action: #selector(rotateRight), for: .touchDown)
        movementOverlay.addSubview(rotateRightButton)
        
        self.view.bringSubviewToFront(movementOverlay)
    }
    
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
    
    @objc func rotateLeft() {
        let rotationAmount: Float = .pi / 16
        playerNode.eulerAngles.y += rotationAmount
    }
    
    @objc func rotateRight() {
        let rotationAmount: Float = -.pi / 16
        playerNode.eulerAngles.y += rotationAmount
    }
    
    @objc func stopMoving() {
        direction = SIMD3<Float>(0, 0, 0)
    }
    
    // Update player and camera every frame
    @objc func update() {
        let moveSpeed = movementSpeed * 0.1
        let move = SIMD3<Float>(direction.x * moveSpeed, 0, direction.z * moveSpeed)
        
        playerNode.position.x += move.x
        playerNode.position.z += move.z
        
        // Sync the camera's position and rotation with the player node
        cameraNode.position = SCNVector3(playerNode.position.x, playerNode.position.y + 0.75, playerNode.position.z)
        cameraNode.eulerAngles.y = playerNode.eulerAngles.y
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
