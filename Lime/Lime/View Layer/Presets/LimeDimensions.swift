//
//  LimeDimensions.swift
//  Lime
//
//  Created by Andre Pham on 4/8/2023.
//

import Foundation

enum LimeDimensions {
    
    /// Corner radius of background views such as background color
    static let backgroundCornerRadius = 30.0
    /// Corner radius of foreground views such as buttons
    static let foregroundCornerRadius = 20.0
    /// The width for chip views
    static let chipWidth = 60.0
    /// The height for chip views
    static let chipHeight = 48.0
    /// The horizontal padding for content placed in chips
    static let chipPaddingHorizontal = 17.0
    /// The vertical padding for content placed in chips
    static let chipPaddingVertical = 14.0
    /// The horizontal external padding for the toolbar
    static let toolbarPaddingHorizontal = 15.0
    /// The bottom external padding for the toolbar
    static let toolbarPaddingBottom = 15.0
    /// The padding around the content inside the toolbar
    static let toolbarInnerPadding = 15.0
    /// The spacing between everything within the toolbar
    static let toolbarSpacing = 10.0
    /// The height of text inputs
    static let textInputHeight = Self.chipHeight
    /// The padding around the quiz prompt
    static let quizPromptPadding = 30.0
    /// The external top padding for any view that floats (hangs) from the top
    static let floatingCardTopPadding = 50.0
    
}
