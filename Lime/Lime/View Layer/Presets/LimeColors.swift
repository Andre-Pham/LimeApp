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
    
    static let accent = UIColor(hexString: "#FF666F") //UIColor(named: "Assets#FF666F#E24549")!
    static let component = UIColor(hexString: "#E4E5EA") //UIColor(named: "Assets#E4E5EA#454552")!
    static let warning = UIColor(hexString: "#E03131") //UIColor(named: "Assets#E03131#E03131")!
    
    // MARK: - Fill
    
    static let sceneFill = UIColor(hexString: "#F2F2F5") //UIColor(named: "Assets#F2F2F5#646470")!
    static let backgroundFill = UIColor(hexString: "#FFFFFF") //UIColor(named: "Assets#FFFFFF#17171C")!
    static let primaryButtonFill = Self.accent
    static let secondaryButtonFill = Self.component
    static let toolbarFill = Self.backgroundFill
    
    // MARK: - Text
    
    static let textDark = UIColor(hexString: "#000000") //UIColor(named: "Assets#000000#FFFFFF")!
    static let textSemiDark = UIColor(hexString: "#B2B3C2") //UIColor(named: "Assets#B2B3C2#818182")!
    static let textPrimaryButton = UIColor(hexString: "#FFFFFF") //UIColor(named: "Assets#FFFFFF")!
    static let textSecondaryButton = Self.textDark
    
    
}
