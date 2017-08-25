//
//  UIScreen+Extensions.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/24/17.
//

extension UIScreen {
    
    /// Bounds of the main screen
    static var rect: CGRect {
        return UIScreen.main.bounds
    }
    
    /// Width of the main screen
    static var width: CGFloat {
        return UIScreen.rect.width
    }
    
    /// Height of the main screen
    static var height: CGFloat {
        return UIScreen.rect.height
    }
}
