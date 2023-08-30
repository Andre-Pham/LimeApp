//
//  SceneView.swift
//  Spell
//
//  Created by Andre Pham on 8/3/2023.
//

import Foundation
import SwiftUI

struct SceneView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = SceneViewController
    private let viewController: SceneViewController
    
    init(_ viewController: SceneViewController) {
        self.viewController = viewController
    }
    
    func makeUIViewController(context: Context) -> SceneViewController {
        return self.viewController
    }
    
    func updateUIViewController(_ uiViewController: SceneViewController, context: Context) {
        // Do nothing
    }
    
}
