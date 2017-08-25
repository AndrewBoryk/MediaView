//
//  UILabel+Extensions.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/24/17.
//

import QuartzCore

extension UILabel {
    
    func addShadow() {
        self.layer.masksToBounds = false
        self.shadowColor = UIColor.black.withAlphaComponent(0.32)
        self.shadowOffset = CGSize(width: 0, height: 1)
    }
}
