//
//  SettingsViewController.swift
//  Lime
//
//  Created by Andre Pham on 10/8/2023.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    private var root: LimeView { return LimeView(self.view) }
    private let stack = LimeVStack()
    private let mainTitle = LimeText()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.root
            .setBackgroundColor(to: LimeColors.backgroundFill)
            .addSubview(self.stack)
        
        self.stack
            .constrainAllSides(padding: 24)
            .addView(self.mainTitle)
            .addSpacer()
        
        self.mainTitle
            .setText(to: "Settings")
            .constrainHorizontal()
            .setFont(to: LimeFont(font: LimeFonts.CircularStd.Black.rawValue, size: 40))
    }
    
}
