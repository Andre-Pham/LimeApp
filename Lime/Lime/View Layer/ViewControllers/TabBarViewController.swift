//
//  TabBarViewController.swift
//  Lime
//
//  Created by Andre Pham on 4/8/2023.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Layout Properties
    
    /// The height of the tab bar - nil indicates to use the default
    private var tabBarHeightOverride: Double? = nil
    /// The default tab bar height, usually 49.0, set in viewDidLoad
    private var defaultTabBarHeight: Double = 49.0
    
    // MARK: - Preset Views
    
    private var root: LimeView { return LimeView(self.view) }
    private let tabBarStack = LimeHStack()
    
    // MARK: - Tab Bar Properties
    
    private var tabBarOptions = [LimeTabBarOption]()
    private var itemIcons: [String] {
        return self.tabBarOptions.map({ $0.icon })
    }
    private var selectedItemIcons: [String] {
        return self.tabBarOptions.map({ $0.selectedIcon })
    }
    private var tabBarItemLabels: [String] {
        return self.tabBarOptions.map({ $0.label })
    }
    private var allViewControllers: [UIViewController] {
        return self.tabBarOptions.map({ $0.viewController })
    }
    public var tabBarButtons: [LimeTabBarButton] {
        return self.tabBarOptions.map({ $0.button })
    }
    
    // MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.defaultTabBarHeight = self.tabBar.frame.size.height
        
        self.tabBarOptions.append(LimeTabBarOption(
            icon: "cube.transparent",
            selectedIcon: "cube.transparent.fill",
            label: Strings("tabBar.generation").local,
            viewController: SceneViewController()
        ))
        if !Environment.inst.deviceIsMac {
            self.tabBarOptions.append(LimeTabBarOption(
                icon: "camera",
                selectedIcon: "camera.fill",
                label: Strings("tabBar.recognition").local,
                viewController: RecognitionViewController()
            ))
        }
        self.tabBarOptions.append(LimeTabBarOption(
            icon: "gearshape",
            selectedIcon: "gearshape.fill",
            label: Strings("tabBar.settings").local,
            viewController: SettingsViewController()
        ))
        
        if Environment.inst.bottomSafeAreaHeight < 24 {
            // If there's very little safe area, the text becomes cramped in proximity to the home indicator
            // To resolve this, we set a height override
            self.tabBarHeightOverride = 42.0
        }
        
        if Environment.inst.deviceIsTiny {
            // Tiny devices have a very tiny default tab bar height - not nearly enough room
            // We set a height override to compensate
            self.tabBarHeightOverride = 64.0
        }
        
        if Environment.inst.deviceIsMac {
            // If we're running on mac, this size is best
            self.tabBarHeightOverride = 64.0
        }
        
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = LimeColors.backgroundFill
        
        self.setViewControllers(self.allViewControllers, animated: false)
        
        self.root
            .addSubview(self.tabBarStack)
        
        self.tabBarStack
            .setBackgroundColor(to: LimeColors.backgroundFill)
            .constrainBottom()
            .matchWidthConstraint()
            .setHeightConstraint(to: self.tabBarHeightOverride ?? self.defaultTabBarHeight)
            .setDistribution(to: .fillEqually)
        
        for itemButton in self.tabBarButtons {
            self.tabBarStack.addView(itemButton)
        }
        
        for (index, itemButton) in self.tabBarButtons.enumerated() {
            let label = LimeText()
            
            itemButton
                .setIcon(to: self.itemIcons[index])
                .setColor(to: LimeColors.backgroundFill)
                .setIconColor(to: LimeColors.textDark)
                .constrainVertical()
                .addSubview(label)
                .setOnTap({
                    self.tabBarOptionSelected(index: index)
                })
            
            label
                .setText(to: self.tabBarItemLabels[index])
                .setFont(to: LimeFont(font: LimeFonts.Quicksand.SemiBold.rawValue, size: 10))
                .setTextColor(to: LimeColors.textDark)
                .setSize(to: 10)
                .setTextAlignment(to: .center)
                .constrainHorizontal()
                .setHeightConstraint(to: 20)
                .constrainCenterVertical()
                .constrainCenterHorizontal()
                .setTransformation(to: CGAffineTransform(translationX: 0.0, y: 24.0))
        }
        
        if !self.tabBarButtons.isEmpty {
            self.tabBarButtons[0]
                .setIcon(to: self.selectedItemIcons[0])
                .setIconColor(to: LimeColors.textDark)
        } else {
            assertionFailure("Tab bar is defined without any options")
        }
    }
    
    private func tabBarOptionSelected(index: Int) {
        // Very occasionally if you switch fast enough you can skip an update if you only update the selected item icon
        // To avoid this we just refresh all of them
        for itemButtonIndex in self.tabBarButtons.indices {
            guard itemButtonIndex != index else {
                continue
            }
            self.tabBarButtons[itemButtonIndex]
                .setIcon(to: self.itemIcons[itemButtonIndex])
                .setIconColor(to: LimeColors.textDark)
        }
        self.selectedIndex = index
        self.tabBarButtons[index]
            .setIcon(to: self.selectedItemIcons[index])
            .setIconColor(to: LimeColors.textDark)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // If the user presses just above the button, there is technically enough room to select the native tab bar button (changing the view controller) without touching/activating the LimeTabBarButton
        // If this occurs, we still need to update our tab bar
        self.tabBarOptionSelected(index: self.selectedIndex)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let height = self.tabBarHeightOverride {
            var tabFrame = self.tabBar.frame
            tabFrame.size.height = Environment.inst.bottomSafeAreaHeight + height
            self.tabBar.frame = tabFrame
            let sub = (Environment.inst.bottomSafeAreaHeight + height) - self.defaultTabBarHeight + self.tabBar.frame.size.height
            if height >= 45.0 { // A weird quirk, but tested on large device size range (iPads, iPhones, iPhone SE, etc.)
                for viewController in self.viewControllers ?? [] {
                    guard let controllerView = viewController.view else {
                        continue
                    }
                    controllerView.translatesAutoresizingMaskIntoConstraints = false
                    for constraint in controllerView.constraints {
                        if constraint.firstAttribute == .width && constraint.firstItem as? UIView == controllerView {
                            // Remove any width constraints
                            controllerView.removeConstraint(constraint)
                        }
                        if constraint.firstAttribute == .height && constraint.firstItem as? UIView == controllerView {
                            // Remove any height constraints
                            controllerView.removeConstraint(constraint)
                        }
                    }
                    controllerView.widthAnchor.constraint(
                        equalToConstant: Environment.inst.screenWidth
                    ).isActive = true
                    controllerView.heightAnchor.constraint(
                        equalToConstant: Environment.inst.screenHeight - sub
                    ).isActive = true
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let height = self.tabBarHeightOverride {
            additionalSafeAreaInsets = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: (Environment.inst.bottomSafeAreaHeight + height) - self.defaultTabBarHeight,
                right: 0
            )
        }
    }
    
}
