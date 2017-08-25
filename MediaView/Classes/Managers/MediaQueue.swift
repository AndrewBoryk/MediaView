//
//  MediaQueue.swift
//  Pods
//
//  Created by Andrew Boryk on 6/30/17.
//
//

import Foundation

class MediaQueue {
    
    /// Shared Manager, which keeps track of mediaViews
    static let shared = MediaQueue()
    
    /// Queue which holds an array of mediaViews to be displayed
    private var mediaViewQueue = [MediaView]()
    
}
