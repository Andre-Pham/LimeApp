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
    /// - Valid position
    case rightHand
    /// Animated left hand model
    /// - Invalid bounding box
    /// - Valid position
    case leftHand
    
    var name: String {
        switch self {
        case .root:
            return SceneController.ROOT_NODE_NAME
        case .camera:
            return SceneCamera.NAME
        case .hands:
            return "\(SceneModel.NAME_PREFIX)-alphabet.dae"
        case .rightHand:
            return "WorkGlove_R"
        case .leftHand:
            return "WorkGlove_L"
        }
    }
    
}
