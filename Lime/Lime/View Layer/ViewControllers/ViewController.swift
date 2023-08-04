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
        
        tabBar.isTranslucent = false
        
        g.title = "green"
        
        r.title = "red"
        
        b.title = "blue"
        
        self.setViewControllers([g, r, b], animated: false)
        
        self.tabBar.backgroundColor = UIColor.gray
        
        
//        UITabBar.appearance().tintColor = UIColor.black
//        UITabBar.appearance().unselectedItemTintColor = UIColor.black
//
//        guard let items = self.tabBar.items else { return }
//        let images = ["cube.transparent", "hand.wave", "info.circle", "gearshape"]
//        let selectedImages = ["cube.transparent.fill", "hand.wave.fill", "info.circle.fill", "gearshape.fill"]
//        for (index, item) in items.enumerated() {
//            item.image = UIImage(systemName: images[index])
//            item.selectedImage = UIImage(systemName: selectedImages[index])
//        }
        
        self.root
            .addSubview(self.tabBarStack)
        
        self.tabBarStack
            .setBackgroundColor(to: .white)
            .constrainBottom(respectSafeArea: true)
            .constrainHorizontal(padding: 36, respectSafeArea: false)
            .setHeightConstraint(to: Self.TAB_BAR_HEIGHT ?? Self.DEFAULT_TAB_BAR_HEIGHT)
            .setDistribution(to: .equalSpacing)
            .addView(self.item1Button)
            .addView(self.item2Button)
            .addView(self.item3Button)
            .addView(self.item4Button)
        
        for (index, itemButton) in self.itemButtons.enumerated() {
            itemButton
                .setIcon(to: Self.itemIcons[index])
                .setColor(to: .white)
                .setIconColor(to: .black)
                .setHeightConstraint(to: 40)
                .setWidthConstraint(to: 70)
                .setOnTap({
                    self.getActiveItemButton().setIcon(to: Self.itemIcons[self.selectedIndex])
                    self.selectedIndex = index
                    itemButton.setIcon(to: Self.selectedItemIcons[index])
                })
        }
        
        
        
//        let yourCustomView = UIView()
//        yourCustomView.backgroundColor = .orange
//        let screenHeight = UIScreen.main.bounds.size.height
//        let viewHeight: CGFloat = 100
//        let bottomSafeAreaInset = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0
//        yourCustomView.frame = CGRect(x: 0, y: screenHeight - viewHeight - bottomSafeAreaInset, width: UIScreen.main.bounds.size.width, height: viewHeight)
//
//        let yourButton = UIButton(type: .system)
//        let buttonWidth: CGFloat = 100
//        let buttonHeight: CGFloat = 50
//        let buttonX: CGFloat = (yourCustomView.bounds.width - buttonWidth) / 2
//        let buttonY: CGFloat = (yourCustomView.bounds.height - buttonHeight) / 2
//        yourButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
//        yourButton.setTitle("Switch Tab", for: .normal)
//        yourButton.addTarget(self, action: #selector(switchTab), for: .touchUpInside)
//        yourCustomView.addSubview(yourButton)
//
//        self.view.addSubview(yourCustomView)
        
        // HERE'S THE STRAT
        // 1. Setup the tab bar as normal (without icons or text)
        // 2. Add on top my own tab bar ui
        // 3. Add buttons to my own tab bar ui
        // 4. have the buttons programmatically switch between tab bars


    }
    
    func getActiveItemButton() -> LimeIconButton {
        switch self.selectedIndex {
        case 0:
            return self.item1Button
        case 1:
            return self.item2Button
        case 2:
            return self.item3Button
        case 4:
            return self.item4Button
        default:
            fatalError("Not enough item buttons implemented to support selected index \(self.selectedIndex)")
        }
    }
    
    @objc func switchTab() {
        self.selectedIndex = 2
//        tabBarController?.selectedIndex = 2 // Change this to the index of the tab you want to switch to
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
