//
//  TabBarView.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject private var viewRouter: ViewRouter
    private static let tabBarHeight = 50.0
    
    var body: some View {
        ZStack {
            ZStack {
                GenerateSceneView()
                    .opacity(self.viewRouter.currentPage == .generateScene ? 1 : 0)

                GenerateTextView()
                    .opacity(self.viewRouter.currentPage == .generateText ? 1 : 0)

                InfoView()
                    .opacity(self.viewRouter.currentPage == .info ? 1 : 0)

                SettingsView()
                    .opacity(self.viewRouter.currentPage == .settings ? 1 : 0)
            }
            .padding(.bottom, Self.tabBarHeight)
            
            VStack(spacing: 0) {
                Spacer()
                
                HStack(spacing: 0) {
                    TabBarIconView(
                        viewRouter: self.viewRouter,
                        correspondingPage: .generateScene,
                        icon: SpellIcon(image: Image(systemName: "cube.transparent")),
                        selectedIcon: SpellIcon(image: Image(systemName: "cube.transparent.fill")),
                        text: Strings("tabBar.generate3D").local
                    )
                    
                    TabBarIconView(
                        viewRouter: self.viewRouter,
                        correspondingPage: .generateText,
                        icon: SpellIcon(image: Image(systemName: "hand.wave")),
                        selectedIcon: SpellIcon(image: Image(systemName: "hand.wave.fill")),
                        text: Strings("tabBar.generateText").local
                    )
                    
                    TabBarIconView(
                        viewRouter: self.viewRouter,
                        correspondingPage: .info,
                        icon: SpellIcon(image: Image(systemName: "info.circle")),
                        selectedIcon: SpellIcon(image: Image(systemName: "info.circle.fill")),
                        text: Strings("tabBar.info").local
                    )
                    
                    TabBarIconView(
                        viewRouter: self.viewRouter,
                        correspondingPage: .settings,
                        icon: SpellIcon(image: Image(systemName: "gearshape")),
                        selectedIcon: SpellIcon(image: Image(systemName: "gearshape.fill")),
                        text: Strings("tabBar.settings").local
                    )
                }
                .padding(.top, 4)
                .frame(height: Self.tabBarHeight)
                .background(SpellColors.backgroundFill)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            .environmentObject(ViewRouter())
    }
}
