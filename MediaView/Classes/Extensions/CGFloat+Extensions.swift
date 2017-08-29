//
//  CGFloat+Extensions.swift
//  Pods
//
//  Created by Andrew Boryk on 6/28/17.
//
//

public extension CGFloat {
    
    enum Buffer: CGFloat {
        case statusBar = 20
        case navigationBar = 44
        case tabBar = 49
    }
    
    /// Ratio for portrait view (16.0 / 9.0)
    public static let portraitRatio: CGFloat = 16.0 / 9.0
    
    /// Ratio for portrait view (9.0 / 16.0)
    public static let landscapeRatio: CGFloat = 9.0 / 16.0
    
    /// Ratio for a square view (1.0)
    public static let squareRatio: CGFloat = 1.0
    
    /// Height of the status bar
    public static let statusBarBuffer = Buffer.statusBar.rawValue
    
    /// Height of the navigation bar
    public static let navigationBarBuffer = Buffer.navigationBar.rawValue
    
    /// Height of the status bar and the navigation bar combined
    public static let statusAndNavigationBuffer = Buffer.statusBar.rawValue + Buffer.navigationBar.rawValue
    
    /// Height of the tab bar
    public static let tabBarBuffer = Buffer.tabBar.rawValue
    
    /// CGFloat as a TimeInterval
    public var time: TimeInterval {
        return TimeInterval(self)
    }
    
    public mutating func clamp(lower: CGFloat? = nil, upper: CGFloat? = nil) {
        if let lower = lower, self < lower {
            self = lower
        } else if let upper = upper, self > upper {
            self = upper
        }
    }
}
