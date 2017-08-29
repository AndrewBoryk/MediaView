//
//  UIImage+GIF.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/28/17.
//

import Foundation
import CoreGraphics

extension UIImage {
    
    static func delayCentisecondsForImageAtIndex(source: CGImageSource, i: size_t) -> Int {
        var delayCentiseconds = 1
        guard let properties = CGImageSourceCopyProperties(source, nil) else {
            return delayCentiseconds
        }
        
        let gifProperties = unsafeBitCast(CFDictionaryGetValue(properties, unsafeBitCast(kCGImagePropertyGIFDictionary, to: UnsafeRawPointer.self)), to: CFDictionary.self)
        let number = unsafeBitCast(CFDictionaryGetValue(gifProperties, unsafeBitCast(kCGImagePropertyGIFUnclampedDelayTime, to: UnsafeRawPointer.self)), to: CFString.self)
        var numberValue = CFStringGetDoubleValue(number)
        
        if numberValue == 0 {
            numberValue = CFStringGetDoubleValue(unsafeBitCast(CFDictionaryGetValue(gifProperties, unsafeBitCast(kCGImagePropertyGIFDelayTime, to: UnsafeRawPointer.self)), to: CFString.self))
        }
        
        if numberValue > 0 {
            delayCentiseconds = Int(lrint(numberValue * 100))
        }
        
        return delayCentiseconds
        
    }
}
