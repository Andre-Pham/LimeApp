//
//  LimeColors.swift
//  Lime
//
//  Created by Andre Pham on 4/8/2023.
//

import Foundation
import UIKit

enum LimeColors {
    
    // MARK: - Identity
    
    static let accent = UIColor(named: "Assets#FF666F#FF666F")!
    static let component = UIColor(named: "Assets#E4E5EA#E4E5EA")!
    static let warning = UIColor(named: "Assets#E03131#E03131")!
    
    // MARK: - Fill
    
    static let sceneFill = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.00)
    static let backgroundFill = UIColor(named: "Assets#FFFFFF#000000")!
    static let primaryButtonFill = Self.accent
    static let secondaryButtonFill = Self.component
    static let toolbarFill = Self.backgroundFill
    
    // MARK: - Text
    
    static let textDark = UIColor(named: "Assets#000000#FFFFFF")!
    static let textSemiDark = UIColor(named: "Assets#B2B3C2#818182")!
    static let textPrimaryButton = UIColor(named: "Assets#FFFFFF#000000")!
    static let textSecondaryButton = UIColor(named: "Assets#000000#FFFFFF")!
    
    
}
