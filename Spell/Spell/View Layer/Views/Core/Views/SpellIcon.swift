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
    var scale: Double = 1.0
    /// False if the frame should remain the same irrespective of the provided scale
    var scaleFrame: Bool = false
    
    var body: some View {
        self.image
            .resizable()
            .scaledToFill()
            .frame(width: self.sideLength.rawValue*self.scale, height: self.sideLength.rawValue*self.scale)
            .padding(self.scaleFrame ? 1.0 : (self.sideLength.rawValue - self.sideLength.rawValue*self.scale)/2)
    }
}

struct SpellIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 50) {
            SpellIcon(image: Image(systemName: "trash.fill"))
            
            SpellIcon(image: Image(systemName: "trash.fill"), scale: 2.0)
        }
    }
}
