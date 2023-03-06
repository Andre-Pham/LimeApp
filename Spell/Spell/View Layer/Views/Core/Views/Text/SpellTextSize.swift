//
//  SpellTextSize.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import Foundation

enum SpellTextSize {
    
    case title1
    case title2
    case title3
    case title4
    case title5
    
    case tabBar
    
    var value: CGFloat {
        switch self {
        case .title1: return 70
        case .title2: return 50
        case .title3: return 35
        case .title4: return 25
        case .title5: return 20
            
        case .tabBar: return 9
        }
    }
    
}
