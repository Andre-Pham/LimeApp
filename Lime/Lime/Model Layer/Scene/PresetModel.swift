//
//  PresetModel.swift
//  Spell
//
//  Created by Andre Pham on 27/4/2023.
//

import Foundation

enum PresetModel: String {
    
    /// Alphabet formatted match groupings of letters whilst reciting
    case a; case b; case c; case d; case e; case f; case g;
    case h; case i; case j; case k; case l; case m; case n; case o; case p;
    case q; case r; case s;
    case t; case u; case v;
    case w; case x;
    case y; case z;
    
    var name: String {
        switch self {
        case .a, .b, .c, .d, .e, .f, .g, .h, .i, .j, .k, .l, .m, .n, .o, .p, .q, .r, .s, .t, .u, .v, .w, .x, .y, .z:
            return "\(SceneModel.NAME_PREFIX)-\(self.rawValue).dae"
        }
    }
    
}
