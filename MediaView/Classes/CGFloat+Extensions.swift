//
//  CGFloat+Extensions.swift
//  Pods
//
//  Created by Andrew Boryk on 6/28/17.
//
//

import Foundation

extension CGFloat {
    
    enum Buffer: CGFloat {
        case statusBar = 20
        case navigationBar = 44
        case statusBarAndNavigation = 64
        case tabBar = 49
    }
    
    static let portraitRatio: CGFloat = 16.0/9.0
    static let landscapeRatio: CGFloat = 9.0/16.0
    static let squareRatio: CGFloat = 1.0
    
    static let statusBarBuffer = Buffer.statusBar.rawValue
    static let navigationBarBuffer = Buffer.statusBar.rawValue
    static let statusBarAndNavigationBuffer = Buffer.statusBar.rawValue
    static let tabBarBuffer = Buffer.statusBar.rawValue
}
