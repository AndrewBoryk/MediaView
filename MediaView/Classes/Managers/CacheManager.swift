//
//  CacheManager.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation

class CacheManager {
    
    /// Different types of directory items
    enum DirectoryItem {
        case video
        case audio
        case all
        case temp
    }
    
    static let shared = CacheManager()
    
    /// Whether media like videos and audio should be preloaded before manual play or autoplay begins
    var shouldPreloadPlayableMedia = false
    
    /// Download the video
    func preloadVideo(url: String, isFromDirectory: Bool = false) {
        if isFromDirectory {
            // FIXME: Load video from fileWithPath
            // Inside -> Cache video
        } else {
            // FIXME: Load video from internet
            // Inside -> Cache video
        }
    }
    
    /// Download the audio
    func preloadAudio(url: String, isFromDirectory: Bool = false) {
        if url.contains("ipod-library://") {
            // FIXME: Load audio from music library
        } else if isFromDirectory {
            // FIXME: Load audio from fileWithPath
            // Inside -> Cache audio
        } else {
            // FIXME: Load audio from internet
            // Inside -> Cache audio
        }
    }
}
