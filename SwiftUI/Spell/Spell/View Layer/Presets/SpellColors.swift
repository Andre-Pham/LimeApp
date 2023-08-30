//
//  SpellColors.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import Foundation
import SwiftUI

enum SpellColors {
    
    // MARK: - Identity
    
    static let accent = Color("Assets#FF666F#FF666F")
    static let component = Color("Assets#E4E5EA#E4E5EA")
    
    // MARK: - Fill
    
    static let backgroundFill = Color("Assets#FFFFFF#000000")
    static let primaryButtonFill = Self.accent
    static let secondaryButtonFill = Self.component
    static let toolbarFill = Self.backgroundFill
    
    // MARK: - Text
    
    static let bodyText = Color("Assets#000000#FFFFFF")
    static let primaryButtonText = Color("Assets#FFFFFF#000000")
    static let secondaryButtonText = Color("Assets#000000#FFFFFF")
    static let tabBarText = Color("Assets#000000#FFFFFF")
    
    
}
