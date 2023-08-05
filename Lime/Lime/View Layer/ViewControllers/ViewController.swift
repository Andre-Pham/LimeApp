//
//  ViewController.swift
//  Lime
//
//  Created by Andre Pham on 4/8/2023.
//

import UIKit

class ViewController: UITabBarController {
    
    /// The height of the tab bar - nil indicates to use the default
    private static let TAB_BAR_HEIGHT: Double? = nil
    /// 49 is the default height of UITabBar
    private static let DEFAULT_TAB_BAR_HEIGHT = 49.0
    /// The tab bar item icons
    private static let itemIcons = ["cube.transparent", "hand.wave", "info.circle", "gearshape"]
    /// The selected tab bar item icons
    private static let selectedItemIcons = ["cube.transparent.fill", "hand.wave.fill", "info.circle.fill", "gearshape.fill"]
    
    private let sceneViewController = SceneViewController()
    
    private var root: LimeView { return LimeView(self.view) }
    private let tabBarStack = LimeHStack()
    private let item1Button = LimeIconButton()
    private let item2Button = LimeIconButton()
    private let item3Button = LimeIconButton()
    private let item4Button = LimeIconButton()
    private var itemButtons: [LimeIconButton] {
        return [self.item1Button, self.item2Button, self.item3Button, self.item4Button]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let height = Self.TAB_BAR_HEIGHT {
            var tabFrame = self.tabBar.frame
            tabFrame.size.height = Environment.inst.bottomSafeAreaHeight + height
            tabFrame.origin.y = view.frame.size.height - (Environment.inst.bottomSafeAreaHeight + height)
            self.tabBar.frame = tabFrame
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let height = Self.TAB_BAR_HEIGHT {
            additionalSafeAreaInsets = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: (Environment.inst.bottomSafeAreaHeight + height) - Self.DEFAULT_TAB_BAR_HEIGHT,
                right: 0
            )
        }
    }
    
    let g = GreenViewController()
    let r = RedViewController()
    let b = BlueViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = UIColor.white
        
        self.setViewControllers([self.sceneViewController, g, r, b], animated: false)
        
        self.root
            .addSubview(self.tabBarStack)
        
        self.tabBarStack
            .setBackgroundColor(to: .white)
            .constrainBottom()
            .matchWidthConstraint()
            .setHeightConstraint(to: Self.TAB_BAR_HEIGHT ?? Self.DEFAULT_TAB_BAR_HEIGHT)
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
                .setIconSize(to: .mini)
                .setColor(to: .white)
                .setIconColor(to: .black)
                .constrainVertical()
                .addSubview(label)
                .setOnTap({
                    self.getActiveItemButton().setIcon(to: Self.itemIcons[self.selectedIndex])
                    self.selectedIndex = index
                    itemButton.setIcon(to: Self.selectedItemIcons[index])
                })
            
            label
                .setText(to: tabBarItemLabels[index])
                .setFont(to: LimeFont(font: LimeFonts.IBMPlexMono.Medium.rawValue, size: 10))
                .setSize(to: 10)
                .setTextAlignment(to: .center)
                .constrainHorizontal()
                .constrainToUnderneath(padding: -6)
        }
        
        self.item1Button
            .setIcon(to: Self.selectedItemIcons[0])
    }
    
    func getActiveItemButton() -> LimeIconButton {
        switch self.selectedIndex {
        case 0:
            return self.item1Button
        case 1:
            return self.item2Button
        case 2:
            return self.item3Button
        case 3:
            return self.item4Button
        default:
            fatalError("Not enough item buttons implemented to support selected index \(self.selectedIndex)")
        }
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
            myView.heightAnchor.constraint(equalToConstant: 50)
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
                myView.heightAnchor.constraint(equalToConstant: 50)
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

class BlueViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blue
    }
}
