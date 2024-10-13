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
    var entities = [Entity]()
    
    // Component storages
    var positionComponents = [UUID: PositionComponent]()
    var movementComponents = [UUID: MovementComponent]()
    var cameraComponents = [UUID: CameraComponent]()
    
    // Systems
    var movementSystem = MovementSystem()
    var cameraSystem = CameraSystem()
    
    // Player entity
    var player: Entity!
    
    // Button
    var movementOverlay: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupEntities()
        setupMovementButtons()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .default)
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
    
    func setupEntities() {
        // Create player entity
        player = Entity()
        entities.append(player)
        
        // Setup position component
        let initialPosition = SIMD3<Float>(0, 1.0, 0)
        positionComponents[player.id] = PositionComponent(position: initialPosition)
        
        // Setup movement component
        movementComponents[player.id] = MovementComponent(direction: SIMD3<Float>(0, 0, 0), speed: 2.0)
        
        // Setup camera component
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0.75, 0) // Eye-level
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        cameraComponents[player.id] = CameraComponent(cameraNode: cameraNode)
        
        // Set active camera
        sceneView.pointOfView = cameraNode
    }
    
    // Setting up the buttons, but now delegating to MovementSystem for logic
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
    
    // Delegate movement logic to MovementSystem
    @objc func moveForward() {
        movementSystem.updateMovement(playerId: player.id, movementComponents: &movementComponents, direction: SIMD3<Float>(0, 0, -1))
    }
    
    @objc func moveBackward() {
        movementSystem.updateMovement(playerId: player.id, movementComponents: &movementComponents, direction: SIMD3<Float>(0, 0, 1))
    }
    
    @objc func moveLeft() {
        movementSystem.updateMovement(playerId: player.id, movementComponents: &movementComponents, direction: SIMD3<Float>(-1, 0, 0))
    }
    
    @objc func moveRight() {
        movementSystem.updateMovement(playerId: player.id, movementComponents: &movementComponents, direction: SIMD3<Float>(1, 0, 0))
    }
    
    @objc func stopMoving() {
        movementSystem.stopMovement(playerId: player.id, movementComponents: &movementComponents)
    }
    
    @objc func rotateLeft() {
        // Access camera node through camera component
        if let cameraComponent = cameraComponents[player.id] {
            let rotationAmount: Float = .pi / 16
            cameraComponent.cameraNode.eulerAngles.y += rotationAmount
        }
    }
    
    @objc func rotateRight() {
        // Access camera node through camera component
        if let cameraComponent = cameraComponents[player.id] {
            let rotationAmount: Float = -.pi / 16
            cameraComponent.cameraNode.eulerAngles.y += rotationAmount
        }
    }
    
    @objc func update() {
        movementSystem.updatePositions(entities: entities, positions: &positionComponents, movements: movementComponents)
        cameraSystem.update(entities: entities, positions: positionComponents, cameras: cameraComponents)
    }
}
