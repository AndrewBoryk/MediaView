//
//  TapGesture.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/24/17.
//

import Foundation

class TapGesture: UITapGestureRecognizer {
    
    init(target: Any?, action: Selector?, taps: Int = 1, delegate: UIGestureRecognizerDelegate? = nil) {
        super.init(target: target, action: action)
        self.numberOfTapsRequired = taps
        self.delegate = delegate
    }
}
