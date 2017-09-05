//
//  TimeInterval+Extensions.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/25/17.
//

import Foundation

extension TimeInterval {
    
    /// Converts the time interval into a string
    public var timeString: String {
        guard isFinite && !isNaN else {
            return "0:00"
        }
        
        let minutes = Int(self / 60)
        let seconds = Int(self) % 60
        
        if minutes == 0 {
            return "0:\(String(format: "%02d", seconds))"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
    
    /// TimeInterval as a CGFloat
    public var float: CGFloat {
        return CGFloat(self)
    }
}
