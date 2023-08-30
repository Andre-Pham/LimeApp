//
//  TabBarViewController.swift
//  Lime
//
//  Created by Andre Pham on 4/8/2023.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    /// The height of the tab bar - nil indicates to use the default
    private var tabBarHeightOverride: Double? = nil
    /// The default tab bar height, usually 49.0, set in viewDidLoad
    private var defaultTabBarHeight: Double = 49.0
    /// The tab bar item icons
    private static let itemIcons = ["cube.transparent", "hand.wave", "info.circle", "gearshape"]
    /// The selected tab bar item icons
    private static let selectedItemIcons = ["cube.transparent.fill", "hand.wave.fill", "info.circle.fill", "gearshape.fill"]
    
    private let sceneViewController = SceneViewController()
    private let settingsViewController = SettingsViewController()
    
    private var root: LimeView { return LimeView(self.view) }
    private let tabBarStack = LimeHStack()
    private let item1Button = LimeTabBarButton()
    private let item2Button = LimeTabBarButton()
    private let item3Button = LimeTabBarButton()
    private let item4Button = LimeTabBarButton()
    private var itemButtons: [LimeTabBarButton] {
        return [self.item1Button, self.item2Button, self.item3Button, self.item4Button]
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
    
    let g = GreenViewController()
    let r = RedViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultTabBarHeight = self.tabBar.frame.size.height
        
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
        
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = LimeColors.backgroundFill
        
        self.setViewControllers([self.sceneViewController, g, r, self.settingsViewController], animated: false)
        
        self.root
            .addSubview(self.tabBarStack)
        
        self.tabBarStack
            .setBackgroundColor(to: LimeColors.backgroundFill)
            .constrainBottom()
            .matchWidthConstraint()
            .setHeightConstraint(to: self.tabBarHeightOverride ?? self.defaultTabBarHeight)
            .setDistribution(to: .fillEqually)
            .addView(self.item1Button)
            .addView(self.item2Button)
            .addView(self.item3Button)
            .addView(self.item4Button)
        
        let tabBarItemLabels = [
            Strings("tabBar.generate3D").local,
            Strings("tabBar.generateText").local,
            Strings("tabBar.info").local,
            Strings("tabBar.settings").local
        ]
        
        for (index, itemButton) in self.itemButtons.enumerated() {
            let label = LimeText()
            
            itemButton
                .setIcon(to: Self.itemIcons[index])
                .setColor(to: LimeColors.backgroundFill)
                .setIconColor(to: LimeColors.textDark)
                .constrainVertical()
                .addSubview(label)
                .setOnTap({
                    // Very occasionally if you switch fast enough you can skip an update if you only update the selected item icon
                    // To avoid this we just refresh all of them
                    for itemButtonIndex in self.itemButtons.indices {
                        guard itemButtonIndex != index else {
                            continue
                        }
                        self.itemButtons[itemButtonIndex]
                            .setIcon(to: Self.itemIcons[itemButtonIndex])
                            .setIconColor(to: LimeColors.textDark)
                    }
                    self.selectedIndex = index
                    itemButton
                        .setIcon(to: Self.selectedItemIcons[index])
                        .setIconColor(to: LimeColors.textDark)
                })
            
            label
                .setText(to: tabBarItemLabels[index])
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
        
        self.item1Button
            .setIcon(to: Self.selectedItemIcons[0])
            .setIconColor(to: LimeColors.textDark)
    }
    
}

class LimeTabBarButton: LimeUIView {
    
    private let container = LimeView()
    private let button = LimeControl()
    private let imageView = LimeImage()
    private var onTap: (() -> Void)? = nil
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .setBackgroundColor(to: LimeColors.secondaryButtonFill)
            .addSubview(self.button)
            .addSubview(self.imageView)
        
        self.button
            .constrainAllSides()
            .setOnRelease({
                self.onTapCallback()
            })
        
        self.imageView
            .constrainCenterVertical()
            .constrainCenterHorizontal()
            .setColor(to: LimeColors.textSecondaryButton)
    }
    
    @discardableResult
    func setIcon(to icon: String) -> Self {
        if let image = UIImage(named: icon) {
            let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .light, scale: .small)
            self.imageView.setImage(image.withConfiguration(configuration))
        } else if let image = UIImage(systemName: icon) {
            let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .light, scale: .small)
            self.imageView.setImage(image.withConfiguration(configuration))
        }
        return self
    }
    
    @discardableResult
    func setColor(to color: UIColor) -> Self {
        self.container.setBackgroundColor(to: color)
        return self
    }
    
    @discardableResult
    func setIconColor(to color: UIColor) -> Self {
        self.imageView.setColor(to: color)
        return self
    }
    
    @discardableResult
    func setOnTap(_ callback: (() -> Void)?) -> Self {
        self.onTap = callback
        return self
    }
    
    private func onTapCallback() {
        self.onTap?()
    }
    
}


class GreenViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.green
        
        // Create UIView
        let myView = UIView()
        myView.backgroundColor = .red
        
        // Disable autoresizing mask into constraints for myView
        myView.translatesAutoresizingMaskIntoConstraints = false

        // Add the UIView to the parent view
        view.addSubview(myView)
        
        // Create Constraints
        NSLayoutConstraint.activate([
            // Match width of myView to parent view
            myView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Attach myView to bottom of parent view
            myView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Set constant height for myView
            myView.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        if true {
            // Create UIView
            let myView = UIView()
            myView.backgroundColor = .red
            
            // Disable autoresizing mask into constraints for myView
            myView.translatesAutoresizingMaskIntoConstraints = false

            // Add the UIView to the parent view
            view.addSubview(myView)
            
            // Create Constraints
            NSLayoutConstraint.activate([
                // Match width of myView to parent view
                myView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                myView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                // Attach myView to bottom of parent view
                myView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                
                // Set constant height for myView
                myView.heightAnchor.constraint(equalToConstant: 5)
            ])
        }
    }
}

class RedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
    }
}