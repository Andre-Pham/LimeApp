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
    
    // MARK: - Fill
    
    static let sceneFill = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.00)
    static let backgroundFill = UIColor(named: "Assets#FFFFFF#000000")!
    static let primaryButtonFill = Self.accent
    static let secondaryButtonFill = Self.component
    static let toolbarFill = Self.backgroundFill
    
    // MARK: - Text
    
    static let bodyText = UIColor(named: "Assets#000000#FFFFFF")!
    static let primaryButtonText = UIColor(named: "Assets#FFFFFF#000000")!
    static let secondaryButtonText = UIColor(named: "Assets#000000#FFFFFF")!
    static let tabBarText = UIColor(named: "Assets#000000#FFFFFF")!
    
    
}
