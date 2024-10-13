//
//  MovementSystem.swift
//  MovementMechanics
//
//  Created by Nathanael Abel on 12/10/24.
//

import SceneKit
import simd

class MovementSystem {
    
    // Handle player movement input and update direction in MovementComponent
    func updateMovement(playerId: UUID, movementComponents: inout [UUID: MovementComponent], direction: SIMD3<Float>) {
        guard var movementComponent = movementComponents[playerId] else { return }
        
        // Update the movement direction based on input
        movementComponent.direction = direction
        movementComponents[playerId] = movementComponent
    }
    
    // Stop the player's movement by resetting direction
    func stopMovement(playerId: UUID, movementComponents: inout [UUID: MovementComponent]) {
        guard var movementComponent = movementComponents[playerId] else { return }
        
        // Set direction to zero to stop movement
        movementComponent.direction = SIMD3<Float>(0, 0, 0)
        movementComponents[playerId] = movementComponent
    }
    
    // Process all entities and update their positions based on movement direction and speed
    func updatePositions(entities: [Entity], positions: inout [UUID: PositionComponent], movements: [UUID: MovementComponent]) {
        for entity in entities {
            guard let movementComponent = movements[entity.id], var positionComponent = positions[entity.id] else { continue }
            
            // Calculate new position based on the movement direction and speed
            let movementOffset = movementComponent.direction * movementComponent.speed * 0.1
            positionComponent.position += movementOffset
            
            // Update the position component with the new position
            positions[entity.id] = positionComponent
        }
    }
}
