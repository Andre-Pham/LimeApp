//
//  Generate3DView.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import SwiftUI

struct Generate3DView: View {
    var body: some View {
        ZStack {
            Color.gray
            
            Text("Generate3DView")
            
            VStack {
                Spacer()
                
                Toolbar3DView()
                    .padding(.horizontal, 15)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct Generate3DView_Previews: PreviewProvider {
    static var previews: some View {
        Generate3DView()
    }
}
