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
    
    enum Cache {
        case image
        case video
        case audio
        case gif
        
        var cache: NSCache<NSString, AnyObject> {
            switch self {
            case .image:
                return CacheManager.shared.imageCache
            case .video:
                return CacheManager.shared.videoCache
            case .audio:
                return CacheManager.shared.audioCache
            case .gif:
                return CacheManager.shared.gifCache
            }
        }
        
        func getObject(for key: NSString) -> Any? {
            switch self {
            case .image, .gif:
                return self.cache.object(forKey: key) as? UIImage
            case .audio, .video:
                guard let value = self.cache.object(forKey: key) as? NSString else {
                    return nil
                }
                
                return "\(value)"
            }
        }
    }
    
    static let shared = CacheManager()
    
    private let imageCache = NSCache<NSString, AnyObject>()
    
    private let videoCache = NSCache<NSString, AnyObject>()
    
    private let audioCache = NSCache<NSString, AnyObject>()
    
    private let gifCache = NSCache<NSString, AnyObject>()
    
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
