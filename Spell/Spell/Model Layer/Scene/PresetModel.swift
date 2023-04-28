//
//  PresetModel.swift
//  Spell
//
//  Created by Andre Pham on 27/4/2023.
//

import Foundation

enum PresetModel {
    
    case hands
    
    var name: String {
        switch self {
        case .hands:
            return "\(SceneModel.NAME_PREFIX)-alphabet.dae"
        }
    }
    
}
