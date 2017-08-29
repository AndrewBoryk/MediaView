//
//  MediaView+Media.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/28/17.
//

import Foundation

extension MediaView {
    
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
        
        if let cache = CacheManager.Cache.image.getObject(for: url) as? UIImage {
            media.imageCache = cache
        }
        
        if let cache = media.imageCache {
            if !isLongPressing && isFullScreen {
                image = cache
            }
            
            completion?(cache)
        } else {
            CacheManager.shared.loadImage(urlString: url, completion: { (image, error) in
                self.image = image
            })
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
