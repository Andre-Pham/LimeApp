//
//  ViewRouter.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import Foundation

class ViewRouter: ObservableObject {
    
    enum Page {
        case generateScene
        case generateText
        case info
        case settings
    }
    
    @Published private(set) var currentPage: Page = .generateScene
    
    func switchPage(to page: Page) {
        self.currentPage = page
    }
    
}
