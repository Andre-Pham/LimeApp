//
//  NodePresets.swift
//  Lime
//
//  Created by Andre Pham on 18/4/2023.
//

import Foundation

enum PresetNode {
    
    /// Scene root node
    case root
    /// Scene camera
    case camera
    /// Animated hands model
    /// - Valid geometry
    /// - Valid material
    /// - Valid bounding box
    case hands
    
    var name: String {
        switch self {
        case .root:
            return SceneController.ROOT_NODE_NAME
        case .camera:
            return SceneCamera.NAME
        case .hands:
            return "Hands2"
        }
    }
    
}
