//
//  TabBarIconView.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import SwiftUI

struct TabBarIconView: View {
    @ObservedObject var viewRouter: ViewRouter
    let correspondingPage: ViewRouter.Page
    let icon: SpellIcon
    let selectedIcon: SpellIcon
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                VStack {
                    Group {
                        if self.viewRouter.currentPage == self.correspondingPage {
                            self.selectedIcon
                                .foregroundColor(.black)
                        } else {
                            self.icon
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 24)
                        
                    
                    SpellText(text: self.text, font: .bodyBold, size: .tabBar)
                    
                    Spacer()
                }
                .onTapGesture {
                    self.viewRouter.switchPage(to: self.correspondingPage)
                }
            }
            
            Spacer()
        }
    }
}

struct TabBarIconView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarIconView(
            viewRouter: ViewRouter(),
            correspondingPage: .generateScene,
            icon: SpellIcon(image: Image(systemName: "trash")),
            selectedIcon: SpellIcon(image: Image(systemName: "trash.fill")),
            text: "Page"
        )
    }
}
