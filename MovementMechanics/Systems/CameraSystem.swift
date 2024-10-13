//
//  CameraSystem.swift
//  MovementMechanics
//
//  Created by Nathanael Abel on 14/10/24.
//

import SceneKit

class CameraSystem {
    func update(entities: [Entity], positions: [UUID: PositionComponent], cameras: [UUID: CameraComponent]) {
        for entity in entities {
            guard let position = positions[entity.id], let cameraComponent = cameras[entity.id] else { continue }
            
            let cameraNode = cameraComponent.cameraNode
            cameraNode.position = SCNVector3(position.position.x, position.position.y + 0.75, position.position.z)
        }
    }
}
