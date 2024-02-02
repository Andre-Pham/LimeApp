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
    private let scroll = LimeScrollView()
    private let stack = LimeVStack()
    private let mainTitle = LimeText()
    private let chiralitySetting = SettingsRowView<Bool>()
    private let smoothTransitionsSetting = SettingsRowView<Bool>()
    private let hidePromptSetting = SettingsRowView<Bool>()
    private let realisticHandsSetting = SettingsRowView<Bool>()
    private let buttonStack = LimeHStack()
    private let applyButton = LimeButton()
    private let cancelButton = LimeButton()
    private var resetActive = false
    private var buttonsActive: Bool {
        return self.buttonStack.superView != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.root
            .setBackgroundColor(to: LimeColors.backgroundFill)
            .addSubview(self.scroll)
        
        self.scroll
            .constrainHorizontal()
            .constrainVertical()
            .setVerticalBounce(to: true)
            .addView(self.stack)
        
        self.stack
            .constrainVertical(padding: 24, toContentLayoutGuide: true)
            .constrainHorizontal(padding: 20)
            .setSpacing(to: 24)
            .addView(self.mainTitle)
            .addView(self.chiralitySetting)
            .addView(self.smoothTransitionsSetting)
            .addView(self.hidePromptSetting)
            .addView(self.realisticHandsSetting)
            .addGap(size: 8)
            .addSpacer()
        
        self.mainTitle
            .setText(to: Strings("title.settings").local)
            .constrainHorizontal()
            .setFont(to: LimeFont(font: LimeFonts.PlusJakartaSans.ExtraBold.rawValue, size: 48))
            .setTextColor(to: LimeColors.textDark)
        
        self.chiralitySetting
            .constrainHorizontal()
            .setText(label: Strings("setting.chirality").local, subLabel: Strings("label.chiralitySetting").local)
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
                if !self.resetActive {
                    SettingsSession.inst.settings.setLeftHandedSetting(to: isToggled)
                    self.updateActionButtons()
                }
            })
        
        self.smoothTransitionsSetting
            .constrainHorizontal()
            .setText(label: Strings("setting.smoothTransitions").local, subLabel: Strings("label.smoothTransitionsSetting").local)
        self.smoothTransitionsSetting.toggle
            .addState(value: false, icon: "square.stack.3d.down.right")
            .addState(value: true, icon: "square.stack.3d.down.right.fill")
            .setOnChange({ isToggled in
                if isToggled {
                    self.smoothTransitionsSetting.toggle
                        .setBackgroundColor(to: LimeColors.primaryButtonFill)
                        .setForegroundColor(to: LimeColors.textPrimaryButton)
                } else {
                    self.smoothTransitionsSetting.toggle
                        .setBackgroundColor(to: LimeColors.secondaryButtonFill)
                        .setForegroundColor(to: LimeColors.textSecondaryButton)
                }
                if !self.resetActive {
                    SettingsSession.inst.settings.setSmoothTransitionsSetting(to: isToggled)
                    self.updateActionButtons()
                }
            })
        
        self.hidePromptSetting
            .constrainHorizontal()
            .setText(label: Strings("setting.hidePrompt").local, subLabel: Strings("label.hidePromptSetting").local)
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
                if !self.resetActive {
                    SettingsSession.inst.settings.setHidePromptSetting(to: isToggled)
                    self.updateActionButtons()
                }
            })
        
        self.realisticHandsSetting
            .constrainHorizontal()
            .setText(label: Strings("setting.realisticHands").local, subLabel: Strings("label.realisticHandsSetting").local)
        self.realisticHandsSetting.toggle
            .addState(value: false, icon: "sparkles")
            .addState(value: true, icon: "sparkles")
            .setOnChange({ isToggled in
                if isToggled {
                    self.realisticHandsSetting.toggle
                        .setBackgroundColor(to: LimeColors.primaryButtonFill)
                        .setForegroundColor(to: LimeColors.textPrimaryButton)
                } else {
                    self.realisticHandsSetting.toggle
                        .setBackgroundColor(to: LimeColors.secondaryButtonFill)
                        .setForegroundColor(to: LimeColors.textSecondaryButton)
                }
                if !self.resetActive {
                    SettingsSession.inst.settings.setUseRealisticHandModelSetting(to: isToggled)
                    self.updateActionButtons()
                }
            })
        
        self.buttonStack
            .setDistribution(to: .fillEqually)
            .setSpacing(to: 20)
            .addView(self.cancelButton)
            .addView(self.applyButton)
        
        self.applyButton
            .setColor(to: LimeColors.primaryButtonFill)
            .setLabel(to: Strings("button.apply").local)
            .setFont(to: LimeFont(font: LimeFonts.Poppins.Bold.rawValue, size: 18), color: LimeColors.textPrimaryButton)
            .setOnTap({
                SettingsSession.inst.applySettings()
                self.updateActionButtons()
            })
        
        self.cancelButton
            .setColor(to: LimeColors.secondaryButtonFill)
            .setLabel(to: Strings("button.cancel").local)
            .setFont(to: LimeFont(font: LimeFonts.Poppins.Bold.rawValue, size: 18), color: LimeColors.accent)
            .setOnTap({
                SettingsSession.inst.cancelChanges()
                self.reset()
            })
        
        self.matchTogglesToSettings()
    }
    
    private func reset() {
        self.resetActive = true
        UIView.animate(withDuration: 0.2, animations: {
            self.matchTogglesToSettings()
        })
        self.updateActionButtons()
        self.resetActive = false
    }
    
    private func matchTogglesToSettings() {
        self.chiralitySetting.toggle.setState(state: SettingsSession.inst.settings.leftHanded ? 1 : 0, trigger: true)
        self.smoothTransitionsSetting.toggle.setState(state: SettingsSession.inst.settings.smoothTransitions ? 1 : 0, trigger: true)
        self.hidePromptSetting.toggle.setState(state: SettingsSession.inst.settings.hidePrompt ? 1 : 0, trigger: true)
        self.realisticHandsSetting.toggle.setState(state: SettingsSession.inst.settings.realisticHandModel ? 1 : 0, trigger: true)
    }
    
    private func updateActionButtons() {
        if SettingsSession.inst.isEditing && !self.buttonsActive {
            self.addActionButtons()
        } else if !SettingsSession.inst.isEditing && self.buttonsActive {
            self.removeActionButtons()
        }
    }
    
    private func addActionButtons() {
        self.stack.insertView(self.buttonStack, at: self.stack.viewCount - 1)
        self.buttonStack.constrainHorizontal()
        self.buttonStack.animateEntrance(onCompletion: {
            self.scroll.scrollToBottomAnimated()
        })
    }
    
    private func removeActionButtons() {
        self.buttonStack.animateExit() {
            self.buttonStack.removeFromSuperView()
            self.scroll.layoutIfNeededAnimated()
        }
    }
    
}
