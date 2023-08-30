//
//  CameraView.swift
//  Spell
//
//  Created by Andre Pham on 12/4/2023.
//

import Foundation
import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = CameraViewController
    private let viewController: CameraViewController
    
    init(_ viewController: CameraViewController) {
        self.viewController = viewController
    }
    
    func makeUIViewController(context: Context) -> CameraViewController {
        return self.viewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Do nothing
    }
    
}
