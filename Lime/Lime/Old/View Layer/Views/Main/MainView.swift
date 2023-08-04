//
//  MainView.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import SwiftUI

struct MainView: View {
    // Any object shared between tab views should be defined here
    @StateObject private var viewRouter = ViewRouter()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                SpellColors.backgroundFill
                    .ignoresSafeArea()

                TabBarView()
                    .environmentObject(self.viewRouter)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
