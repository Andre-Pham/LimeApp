//
//  SpellTextFont.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import Foundation
import SwiftUI

enum SpellTextFont {
    
    case title
    case bodyBold
    case bodyRegular
    case bodyLight
    
    private var name: String {
        switch self {
        case .title:
            return "TiltWarp-Regular"
        case .bodyBold:
            return "Quicksand-SemiBold"
        case .bodyRegular:
            return "Quicksand-Regular"
        case .bodyLight:
            return "Quicksand-Light"
        }
    }
    
    func value(size: SpellTextSize, scaling: Font.TextStyle = .body) -> Font {
        //let test = UIFont(name: "TiltWarp-Regular-VariableFont_XROT,YROT", size: UIFont.labelFontSize)!
        return Font.custom(self.name, size: size.value, relativeTo: scaling)
    }
    
}
