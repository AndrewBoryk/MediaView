//
//  MediaView+Media.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/28/17.
//

import Foundation

extension MediaView {
    
    /// Image completed loading onto ABMediaView
    typealias ImageCompletionBlock = (_ image: UIImage?, _ error: Error?) -> Void
    
    /// Video completed loading onto ABMediaView
    typealias VideoDataCompletionBlock = (_ video: String?, _ error: Error?) -> Void
    
    public override var image: UIImage? {
        didSet {
            if let image = image {
                delegate?.mediaView(self, didSetImage: image)
            }
        }
    }
    
    public func setImage(url: String, completion: ((_ image: UIImage) -> Void)? = nil) {
        media.imageURL = url
        
        if !imageViewNotReused {
            image = nil
        }
        
        // FIXME: Add fetch image from cache
        if let cache = image {
            media.imageCache = cache
        }
        
        if let cache = media.imageCache {
            if !isLongPressing && isFullScreen {
                image = cache
            }
            
            completion?(cache)
        } else {
            // FIXME: Download image and cache is needed
        }
    }
    
    public func setVideo(url: String) {
        media.videoURL = url
        track.reset()
        setPlayIndicatorView()
        
        if shouldPreloadPlayableMedia || CacheManager.shared.shouldPreloadPlayableMedia {
            CacheManager.shared.preloadVideo(url: url, isFromDirectory: isFileFromDirectory)
        }
    }
    
    public func setVideo(url: String, thumbnail: UIImage) {
        image = thumbnail
        setVideo(url: url)
    }
    
    public func setVideo(url: String, thumbnailUrl: String) {
        setImage(url: thumbnailUrl)
        setVideo(url: url)
    }
    
    public func setVideo(url: String, thumbnail: UIImage, previewGIFData: Data) {
        setVideo(url: url, thumbnail: thumbnail)
        setPreviewGIF(data: previewGIFData)
    }
    
    public func setVideo(url: String, thumbnail: UIImage, previewGIFUrl: String) {
        setVideo(url: url, thumbnail: thumbnail)
        setPreviewGIF(url: previewGIFUrl)
    }
    
    public func setVideo(url: String, thumbnailUrl: String, previewGIFData: Data) {
        setVideo(url: url, thumbnailUrl: thumbnailUrl)
        setPreviewGIF(data: previewGIFData)
    }
    
    public func setVideo(url: String, thumbnailUrl: String, previewGIFUrl: String) {
        setVideo(url: url, thumbnailUrl: thumbnailUrl)
        setPreviewGIF(url: previewGIFUrl)
    }
    
    public func setVideo(url: String, thumbnailGIFData: Data) {
        setVideo(url: url)
        setThumbnailGIF(data: thumbnailGIFData)
    }
    
    public func setVideo(url: String, thumbnailGIFUrl: String) {
        setVideo(url: url)
        setThumbnailGIF(url: thumbnailGIFUrl)
    }
    
    public func setAudio(url: String) {
        media.audioURL = url
        track.reset()
        setPlayIndicatorView()
        
        if shouldPreloadPlayableMedia || CacheManager.shared.shouldPreloadPlayableMedia {
            CacheManager.shared.preloadAudio(url: url, isFromDirectory: isFileFromDirectory)
        }
    }
    
    public func setAudio(url: String, thumbnail: UIImage) {
        image = thumbnail
        setAudio(url: url)
    }
    
    public func setAudio(url: String, thumbnailUrl: String) {
        setImage(url: thumbnailUrl)
        setAudio(url: url)
    }
    
    public func setAudio(url: String, thumbnailGIFData: Data) {
        setThumbnailGIF(data: thumbnailGIFData)
        setAudio(url: url)
    }
    
    public func setAudio(url: String, thumbnailGIFUrl: String) {
        setThumbnailGIF(url: thumbnailGIFUrl)
        setAudio(url: url)
    }
    
    private func setPreviewGIF(data: Data) {
        
    }
    
    private func setPreviewGIF(url: String) {
        
    }
    
    private func setThumbnailGIF(data: Data) {
        
    }
    
    private func setThumbnailGIF(url: String) {
        
    }
    
}
