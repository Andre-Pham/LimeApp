//
//  SettingsRowView.swift
//  Lime
//
//  Created by Andre Pham on 11/8/2023.
//

import Foundation
import UIKit

class SettingsRowView<T>: LimeUIView {
    
    private let container = LimeView()
    private let rowStack = LimeHStack()
    private let divider = LimeView()
    private let textStack = LimeVStack()
    private let label = LimeText()
    private let subLabel = LimeText()
    public let toggle = LimeChipMultiState<T>()
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        self.container
            .addSubview(self.rowStack)
            .addSubview(self.divider)
        
        self.rowStack
            .constrainAllSides()
            .addView(self.textStack)
            .addSpacer()
            .addView(self.toggle)
        
        self.divider
            .setBackgroundColor(to: LimeColors.component)
            .setHeightConstraint(to: 1.4)
            .constrainToUnderneath(padding: 12)
            .constrainLeft()
            .constrainRight(padding: 12)
        
        self.textStack
            .addView(self.label)
            .addSpacer()
            .addView(self.subLabel)
        
        self.label
            .setFont(to: LimeFont(font: LimeFonts.Poppins.SemiBold.rawValue, size: 18))
            .constrainHorizontal()
        
        self.subLabel
            .setFont(to: LimeFont(font: LimeFonts.Poppins.SemiBold.rawValue, size: 14))
            .setTextColor(to: LimeColors.textSemiDark)
            .constrainHorizontal()
    }
    
    func setText(label: String, subLabel: String) {
        self.label.setText(to: label)
        self.subLabel.setText(to: subLabel)
    }
    
}
