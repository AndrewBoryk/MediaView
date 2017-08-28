//
//  UIWindow+Extensions.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/27/17.
//

import Foundation

extension UIWindow {
    
    /// Main window for the application
    static var main: UIWindow = {
        guard let window = UIApplication.shared.keyWindow else {
            fatalError("No Window was found?")
        }
        
        return window
    }()
}
