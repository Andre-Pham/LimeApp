//
//  LimeTabBar.swift
//  Lime
//
//  Created by Andre Pham on 28/9/2023.
//

import Foundation
import UIKit

class LimeTabBarOption {
    
    public let icon: String
    public let selectedIcon: String
    public let label: String
    public let viewController: UIViewController
    public let button = LimeTabBarButton()
    
    init(icon: String, selectedIcon: String, label: String, viewController: UIViewController) {
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.label = label
        self.viewController = viewController
    }
    
}
