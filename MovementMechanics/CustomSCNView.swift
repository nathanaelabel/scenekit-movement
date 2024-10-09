//
//  CustomSCNView.swift
//  MovementMechanics
//
//  Created by Nathanael Abel on 09/10/24.
//

import SceneKit

class CustomSCNView: SCNView {
    override var canBecomeFocused: Bool {
        // Prevents focus-based navigation
        return false
    }
}
