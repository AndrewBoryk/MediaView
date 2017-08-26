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
    
    /// Media view that is currently presented by the manager
    var current: MediaView?
    
    /// Queue which holds an array of mediaViews to be displayed
    private var mediaViewQueue = [MediaView]()
    
    /// Main window which the mediaView will be added to
    private var mainWindow: UIWindow? {
        return UIApplication.shared.keyWindow
    }
}
