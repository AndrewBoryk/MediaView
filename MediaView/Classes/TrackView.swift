//
//  TrackView.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation

class TrackView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInitialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInitialization()
    }
    
    private func commonInitialization() {
        
    }
}
