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
    
    static let accent = UIColor(named: "Assets#EC6572")!
    static let component = UIColor(named: "Assets#E4E5EA#454552")!
    static let warning = UIColor(named: "Assets#CB4343")!
    
    // MARK: - Fill
    
    static let sceneFill = UIColor(named: "Assets#F2F2F5#646474")!
    static let backgroundFill = UIColor(named: "Assets#FFFFFF#201F25")!
    static let primaryButtonFill = Self.accent
    static let secondaryButtonFill = Self.component
    static let toolbarFill = Self.backgroundFill
    
    // MARK: - Text
    
    static let textDark = UIColor(named: "Assets#000000#FFFFFF")!
    static let textSemiDark = UIColor(named: "Assets#B2B3C2#767489")!
    static let textPrimaryButton = UIColor(named: "Assets#FFFFFF")!
    static let textSecondaryButton = Self.textDark
    
    
}
