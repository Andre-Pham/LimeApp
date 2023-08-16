//
//  Environment.swift
//  Lime
//
//  Created by Andre Pham on 4/8/2023.
//

import Foundation
import UIKit

class Environment {
    
    public static let inst = Environment()
    
    private var safeAreaInsets: UIEdgeInsets? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        return windowScene.windows.first?.safeAreaInsets
    }
    
    public var topSafeAreaHeight: CGFloat {
        return self.safeAreaInsets?.top ?? 0.0
    }
    
    public var bottomSafeAreaHeight: CGFloat {
        return self.safeAreaInsets?.bottom ?? 0.0
    }
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    public var deviceIsTiny: Bool {
        return isLessOrEqual(self.screenHeight, 667)
    }
    
    private init() { }
    
}
