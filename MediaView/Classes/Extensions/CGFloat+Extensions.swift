//
//  CGFloat+Extensions.swift
//  Pods
//
//  Created by Andrew Boryk on 6/28/17.
//
//

extension CGFloat {
    
    enum Buffer: CGFloat {
        case statusBar = 20
        case navigationBar = 44
        case tabBar = 49
    }
    
    /// Ratio for portrait view (16.0 / 9.0)
    static let portraitRatio: CGFloat = 16.0 / 9.0
    
    /// Ratio for portrait view (9.0 / 16.0)
    static let landscapeRatio: CGFloat = 9.0 / 16.0
    
    /// Ratio for a square view (1.0)
    static let squareRatio: CGFloat = 1.0
    
    /// Height of the status bar
    static let statusBarBuffer = Buffer.statusBar.rawValue
    
    /// Height of the navigation bar
    static let navigationBarBuffer = Buffer.navigationBar.rawValue
    
    /// Height of the status bar and the navigation bar combined
    static let statusAndNavigationBuffer = Buffer.statusBar.rawValue + Buffer.navigationBar.rawValue
    
    /// Height of the tab bar
    static let tabBarBuffer = Buffer.tabBar.rawValue
}
