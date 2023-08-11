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
    private let chiralitySetting = SettingsRowView<Bool>()
    private let interpolateSetting = SettingsRowView<Bool>()
    private let hidePromptSetting = SettingsRowView<Bool>()
    private let buttonStack = LimeHStack()
    private let applyButton = LimeButton()
    private let cancelButton = LimeButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.root
            .setBackgroundColor(to: LimeColors.backgroundFill)
            .addSubview(self.stack)
        
        self.stack
            .constrainVertical(padding: 24)
            .constrainHorizontal(padding: 20)
            .setSpacing(to: 24)
            .addView(self.mainTitle)
            .addView(self.chiralitySetting)
            .addView(self.interpolateSetting)
            .addView(self.hidePromptSetting)
            .addView(self.buttonStack)
            .addSpacer()
        
        self.mainTitle
            .setText(to: "Settings")
            .constrainHorizontal()
            .setFont(to: LimeFont(font: LimeFonts.CircularStd.Black.rawValue, size: 48))
            .setTextColor(to: LimeColors.textDark)
        
        self.chiralitySetting
            .constrainHorizontal()
            .setText(label: "Left Handed Signs", subLabel: "Use left-handed Auslan signs")
        self.chiralitySetting.toggle
            .addState(value: false, icon: "hand.wave")
            .addState(value: true, icon: "hand.wave.fill")
            .setOnChange({ isToggled in
                if isToggled {
                    self.chiralitySetting.toggle
                        .setBackgroundColor(to: LimeColors.primaryButtonFill)
                        .setForegroundColor(to: LimeColors.textPrimaryButton)
                } else {
                    self.chiralitySetting.toggle
                        .setBackgroundColor(to: LimeColors.secondaryButtonFill)
                        .setForegroundColor(to: LimeColors.textSecondaryButton)
                }
            })
        
        self.interpolateSetting
            .constrainHorizontal()
            .setText(label: "Interpolate", subLabel: "Animate a transition between performed signs")
        self.interpolateSetting.toggle
            .addState(value: false, icon: "square.stack.3d.down.right")
            .addState(value: true, icon: "square.stack.3d.down.right.fill")
            .setOnChange({ isToggled in
                if isToggled {
                    self.interpolateSetting.toggle
                        .setBackgroundColor(to: LimeColors.primaryButtonFill)
                        .setForegroundColor(to: LimeColors.textPrimaryButton)
                } else {
                    self.interpolateSetting.toggle
                        .setBackgroundColor(to: LimeColors.secondaryButtonFill)
                        .setForegroundColor(to: LimeColors.textSecondaryButton)
                }
            })
        
        self.hidePromptSetting
            .constrainHorizontal()
            .setText(label: "Hide Prompt", subLabel: "Hide the letters being performed (above model)")
        self.hidePromptSetting.toggle
            .addState(value: false, icon: "a.square")
            .addState(value: true, icon: "a.square.fill")
            .setOnChange({ isToggled in
                if isToggled {
                    self.hidePromptSetting.toggle
                        .setBackgroundColor(to: LimeColors.primaryButtonFill)
                        .setForegroundColor(to: LimeColors.textPrimaryButton)
                } else {
                    self.hidePromptSetting.toggle
                        .setBackgroundColor(to: LimeColors.secondaryButtonFill)
                        .setForegroundColor(to: LimeColors.textSecondaryButton)
                }
            })
        
        // TODO: When the user makes changes, do a addViewAnimated sorta thing with
        // TODO: the button stack so that when changes are made, the cancel/apply
        // TODO: buttons are animated in
        
        self.buttonStack
            .constrainHorizontal()
            .setDistribution(to: .fillEqually)
            .setSpacing(to: 20)
            .addView(self.cancelButton)
            .addView(self.applyButton)
        
        self.applyButton
            .setColor(to: LimeColors.primaryButtonFill)
            .setLabel(to: "Apply Changes")
            .setFont(to: LimeFont(font: LimeFonts.Poppins.Bold.rawValue, size: 18), color: LimeColors.textPrimaryButton)
        
        self.cancelButton
            .setColor(to: LimeColors.secondaryButtonFill)
            .setLabel(to: "Cancel Changes")
            .setFont(to: LimeFont(font: LimeFonts.Poppins.Bold.rawValue, size: 18), color: LimeColors.warning)
    }
    
}
