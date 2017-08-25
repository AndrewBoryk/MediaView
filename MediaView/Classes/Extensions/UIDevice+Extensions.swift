//
//  UIDevice+Extensions.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/24/17.
//

extension UIDevice {
    
    /// Derived by whether the width of the screen is less than the height of the screen
    static var isPortrait: Bool {
        return UIScreen.width < UIScreen.height
    }
    
    /// Derived by whether the height of the screen is less than the width of the screen
    static var isLandscape: Bool {
        return UIScreen.height < UIScreen.width
    }
}
