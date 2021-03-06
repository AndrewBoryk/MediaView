//
//  Media.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/26/17.
//

import Foundation

@objcMembers
class Media: NSObject {
    
    /// URL endpoint for image
    var imageURL: String?
    
    /// Image cached after loading
    var imageCache: UIImage?
    
    /// URL endpoint for video
    var videoURL: String?
    
    /// Video location on disk that was cached after loading
    var videoCache: URL?
    
    /// URL endpoint for audio
    var audioURL: String?
    
    /// Audio location on disk that was cached after loading
    var audioCache: URL?
    
    /// URL endpoint for gif
    var gifURL: String?
    
    /// Data for gif
    var gifData: Data?
    
    /// Gif cached after loading
    var gifCache: UIImage?
    
    /// Whether the media has a video
    var hasVideo: Bool {
        return videoURL != nil
    }
    
    /// Whether the media has audio
    var hasAudio: Bool {
        return audioURL != nil
    }
    
    /// Whether the media has video or audio
    var hasPlayableMedia: Bool {
        return hasVideo || hasAudio
    }
}
