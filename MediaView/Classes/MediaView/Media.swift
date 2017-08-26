//
//  Media.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/26/17.
//

import Foundation

class Media {
    
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
}
