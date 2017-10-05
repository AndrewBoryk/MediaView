//
//  CGRect+Extensions.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/26/17.
//

import Foundation

extension CGRect {
    
    static let offscreenRect = CGRect(x: 0, y: UIScreen.superviewHeight, width: UIScreen.superviewWidth, height: UIScreen.superviewHeight)
    
    init(width: CGFloat, height: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: height)
    }
    
    init(size: CGFloat) {
        self.init(origin: 0, size: size)
    }
    
    init(origin: CGFloat, size: CGFloat) {
        self.init(x: origin, y: origin, width: size, height: size)
    }
    
    func log() {
        print("x: \(origin.x) y: \(origin.y) width: \(width) height: \(height)")
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
    
    var isDownToTheRight: Bool {
        return y >= 0 && fabsf(Float(y)) < Float(x)
    }
}
