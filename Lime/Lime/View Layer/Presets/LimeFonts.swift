//
//  LimeFonts.swift
//  Lime
//
//  Created by Andre Pham on 5/8/2023.
//

import Foundation
import UIKit

public func LimeFont(font: String, size: Double) -> UIFont {
    assert(UIFont(name: font, size: size) != nil, "Font missing: \(font)")
    return UIFont(name: font, size: size)!
}

enum LimeFonts {
    
    enum CircularStd: String {
        
        case Black = "CircularStd-Black"
        case BlackItalic = "CircularStd-BlackItalic"
        case Bold = "CircularStd-Bold"
        case BoldItalic = "CircularStd-BoldItalic"
        case Medium = "CircularStd-Medium"
        case MediumItalic = "CircularStd-Italic"
        
    }
    
    enum IBMPlexMono: String {
        
        case Bold = "IBMPlexMono-Bold"
        case BoldItalic = "IBMPlexMono-BoldItalic"
        case Medium = "IBMPlexMono-Medium"
        case MediumItalic = "IBMPlexMono-MediumItalic"
        case SemiBold = "IBMPlexMono-SemiBold"
        case SemiBoldItalic = "IBMPlexMono-SemiBoldItalic"
        
    }
    
    enum Poppins: String {
        
        case Bold = "Poppins-Bold"
        case BoldItalic = "Poppins-BoldItalic"
        case Medium = "Poppins-Medium"
        case MediumItalic = "Poppins-MediumItalic"
        case SemiBold = "Poppins-SemiBold"
        case SemiBoldItalic = "Poppins-SemiBoldItalic"
        
    }
    
    enum TiltWarp: String {
        
        case Regular = "TiltWarp-Regular"
        
    }
    
    enum Quicksand: String {
        
        case Light = "Quicksand-Light"
        case Regular = "Quicksand-Regular"
        case SemiBold = "Quicksand-SemiBold"
        
    }
    
}
