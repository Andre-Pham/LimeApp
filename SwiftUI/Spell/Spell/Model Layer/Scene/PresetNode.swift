//
//  NodePresets.swift
//  Spell
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
    /// - Valid bounding box
    /// - Invalid position
    case hands
    /// Animated right hand model
    /// - Invalid bounding box
    /// - Static position
    case rightHand
    /// Animated left hand model
    /// - Invalid bounding box
    /// - Static position
    case leftHand
    
    var name: String {
        switch self {
        case .root:
            return SceneController.ROOT_NODE_NAME
        case .camera:
            return SceneCamera.NAME
        case .hands:
            return "Hands2"
        case .rightHand:
            return "hand-R"
        case .leftHand:
            return "hand-L"
        }
    }
    
}
