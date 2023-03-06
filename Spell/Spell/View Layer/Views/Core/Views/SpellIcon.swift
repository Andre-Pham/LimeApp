//
//  SpellIcon.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import SwiftUI

enum SpellIconSize: CGFloat {
    case large = 34
    case standard = 20
}

struct SpellIcon: View {
    let image: Image
    var sideLength: SpellIconSize = .standard
    
    var body: some View {
        self.image
            .resizable()
            .scaledToFill()
            .frame(width: self.sideLength.rawValue, height: self.sideLength.rawValue)
    }
}

struct SpellIcon_Previews: PreviewProvider {
    static var previews: some View {
        SpellIcon(image: Image(systemName: "trash.fill"))
    }
}
