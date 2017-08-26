//
//  CGRect+Extensions.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/26/17.
//

import Foundation

extension CGRect {
    
    init(origin: CGFloat, size: CGFloat) {
        self.init(x: origin, y: origin, width: size, height: size)
    }
}

extension CGSize {
    
    init(_ width: CGFloat, _ height: CGFloat) {
        self.init(width: width, height: height)
    }
    
    init(_ size: CGFloat) {
        self.init(size, size)
    }
}

extension CGPoint {
    
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }
    
    init(_ point: CGFloat) {
        self.init(point, point)
    }
}
