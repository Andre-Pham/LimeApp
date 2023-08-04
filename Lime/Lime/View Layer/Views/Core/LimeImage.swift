//
//  LimeImage.swift
//  Lime
//
//  Created by Andre Pham on 14/6/2023.
//

import Foundation
import UIKit

class LimeImage: LimeUIView {
    
    private let imageView = UIImageView()
    public var view: UIView {
        return self.imageView
    }
    public var imageSize: CGSize {
        return self.imageView.image?.size ?? CGSize()
    }
    
    override init() {
        super.init()
        self.imageView.contentMode = .scaleAspectFill
    }
    
    @discardableResult
    func setImage(_ image: CGImage) -> Self {
        self.imageView.image = UIImage(cgImage: image)
        return self
    }
    
}
