//
//  MediaView+Media.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/28/17.
//

import Foundation

public extension MediaView {
    
    // MARK: - Image
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
            if !isLongPressing || isFullScreen {
                image = cache
            }
            
            completion?(cache)
        } else {
            CacheManager.shared.loadImage(urlString: url, completion: { (image, error) in
                self.media.imageCache = image
                self.image = image
            })
        }
        
        toggleTrackDisplay()
    }
    
    // MARK: - Video
    public func setVideo(url: String) {
        media.videoURL = url
        track.reset()
        setPlayIndicatorView()
        
        if shouldPreloadPlayableMedia || CacheManager.shared.shouldPreloadPlayableMedia {
            CacheManager.shared.preloadVideo(url: url, isFromDirectory: isFileFromDirectory)
        }
        
        toggleTrackDisplay()
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
        setGIF(data: thumbnailGIFData)
    }
    
    public func setVideo(url: String, thumbnailGIFUrl: String) {
        setVideo(url: url)
        setGIF(url: thumbnailGIFUrl)
    }
    
    // MARK: - Audio
    public func setAudio(url: String) {
        media.audioURL = url
        track.reset()
        setPlayIndicatorView()
        
        if shouldPreloadPlayableMedia || CacheManager.shared.shouldPreloadPlayableMedia {
            CacheManager.shared.preloadAudio(url: url, isFromDirectory: isFileFromDirectory)
        }
        
        toggleTrackDisplay()
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
        setAudio(url: url)
        setGIF(data: thumbnailGIFData)
    }
    
    public func setAudio(url: String, thumbnailGIFUrl: String) {
        setAudio(url: url)
        setGIF(url: thumbnailGIFUrl)
    }
    
    // MARK: - GIF
    private func setPreviewGIF(data: Data) {
        setGIF(data: data, isPreview: true)
    }
    
    private func setPreviewGIF(url: String) {
        setGIF(url: url, isPreview: true)
    }
    
    public func setGIF(data: Data) {
        setGIF(data: data, isPreview: false)
    }
    
    public func setGIF(url: String) {
        setGIF(url: url, isPreview: false)
    }
    
    internal func setGIF(data: Data, isPreview: Bool = false) {
        media.gifData = data
        
        if !imageViewNotReused {
            image = nil
        }
        
        if let cachedGIF = media.gifCache {
            if (isPreview && isLongPressing && !isFullScreen) || isFullScreen {
                image = cachedGIF
            }
        } else {
            CacheManager.shared.loadGIF(data: data, completion: { (gif, error) in
                if let gif = gif {
                    self.media.gifCache = gif
                    
                    if isPreview && self.isLongPressing && !self.isFullScreen {
                        self.image = gif
                    }
                }
            })
        }
        
        toggleTrackDisplay()
    }
    
    internal func setGIF(url: String, isPreview: Bool = false) {
        media.gifURL = url
        
        if !imageViewNotReused {
            image = nil
        }
        
        if let cachedGIF = media.gifCache {
            if (isPreview && isLongPressing && !isFullScreen) || isFullScreen {
                image = cachedGIF
            }
        } else if let gifURL = URL(string: url) {
            CacheManager.shared.loadGIF(url: gifURL, completion: { (gif, error) in
                if let gif = gif {
                    self.media.gifCache = gif
                    
                    if isPreview && self.isLongPressing && !self.isFullScreen {
                        self.image = gif
                    }
                }
            })
        }
        
        toggleTrackDisplay()
    }
}
