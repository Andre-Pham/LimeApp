//
//  TopSafeAreaInsetFill.swift
//  Spell
//
//  Created by Andre Pham on 8/3/2023.
//

import SwiftUI

struct TopSafeAreaInsetFill: View {
    let screenGeometry: GeometryProxy
    
    var body: some View {
        VStack {
            SpellColors.backgroundFill
                .frame(
                    width: self.screenGeometry.size.width,
                    height: self.screenGeometry.safeAreaInsets.top,
                    alignment: .top
                )
                .ignoresSafeArea()

            Spacer()
        }
    }
}

struct TopSafeAreaInsetFill_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()
            
            GeometryReader { geo in
                TopSafeAreaInsetFill(screenGeometry: geo)
            }
        }
    }
}
