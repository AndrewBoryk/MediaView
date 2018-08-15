//
//  MediaViewDelegate.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/26/17.
//

import Foundation

@objc
public protocol MediaViewDelegate: class {
    
    /// A listener to know what percentage that the view has minimized, at a value from 0 to 1
    @objc optional func mediaView(_ mediaView: MediaView, didChangeOffset offsetPercentage: CGFloat)
    
    /// When the mediaView begins playing a video
    @objc optional func didPlayMedia(for mediaView: MediaView)
    
    /// When the mediaView fails to play a video
    @objc optional func didFailToPlayMedia(for mediaView: MediaView)
    
    /// When the mediaView pauses a video
    @objc optional func didPauseMedia(for mediaView: MediaView)
    
    /// When the mediaView finishes playing a video, and whether it looped
    @objc optional func didFinishPlayableMedia(for mediaView: MediaView, withLoop didLoop: Bool)
    
    /// Called when the mediaView has begun the presentation process
    @objc optional func willPresent(mediaView: MediaView)
    
    /// Called when the mediaView has been presented
    @objc optional func didPresent(mediaView: MediaView)
    
    /// Called when the mediaView has begun the dismissal process
    @objc optional func willDismiss(mediaView: MediaView)
    
    /// Called when the mediaView has completed the dismissal process. Useful if not looking to utilize the dismissal completion block
    @objc optional func didDismiss(mediaView: MediaView)
    
    /// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
    @objc optional func willChangeMinimization(for mediaView: MediaView)
    
    /// Called when the mediaView is in the process of minimizing, and has made a change in frame
    @objc optional func didChangeMinimization(for mediaView: MediaView)
    
    /// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
    @objc optional func willEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool)
    
    /// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
    @objc optional func didEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool)
    
    /// Called when the 'image' value of the UIImageView has been set
    @objc optional func mediaView(_ mediaView: MediaView, didSetImage image: UIImage)
    
    /// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
    @objc optional func willChangeDismissing(for mediaView: MediaView)
    
    /// Called when the mediaView is in the process of minimizing, and has made a change in frame
    @objc optional func didChangeDismissing(for mediaView: MediaView)
    
    /// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
    @objc optional func willEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool)
    
    /// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
    @objc optional func didEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool)
    
    /// Called when the mediaView has completed downloading the image from the web
    @objc optional func mediaView(_ mediaView: MediaView, didDownloadImage image: UIImage)
    
    /// Called when the mediaView has completed downloading the video from the web
    @objc optional func mediaView(_ mediaView: MediaView, didDownloadVideo video: URL)
    
    /// Called when the mediaView has completed downloading the audio from the web
    @objc optional func mediaView(_ mediaView: MediaView, didDownloadAudio audio: URL)
    
    /// Called when the mediaView has completed downloading the gif from the web
    @objc optional func mediaView(_ mediaView: MediaView, didDownloadGif gif: UIImage)
    
    /// Called when the user taps the title label
    @objc optional func handleTitleSelection(in mediaView: MediaView)
    
    /// Called when the user taps the details label
    @objc optional func handleDetailsSelection(in mediaView: MediaView)
}

extension MediaViewDelegate {
    
    public func mediaView(_ mediaView: MediaView, didChangeOffset offsetPercentage: CGFloat) { }
    
    public func didPlayMedia(for mediaView: MediaView) { }
    
    public func didFailToPlayMedia(for mediaView: MediaView) { }
    
    public func didPauseMedia(for mediaView: MediaView) { }
    
    public func didFinishPlayableMedia(for mediaView: MediaView, withLoop didLoop: Bool) { }
    
    public func willPresent(mediaView: MediaView) { }
    
    public func didPresent(mediaView: MediaView) { }
    
    public func willDismiss(mediaView: MediaView) { }
    
    public func didDismiss(mediaView: MediaView) { }
    
    public func willChangeMinimization(for mediaView: MediaView) { }
    
    public func didChangeMinimization(for mediaView: MediaView) { }
    
    public func willEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool) { }
    
    public func didEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool) { }
    
    public func mediaView(_ mediaView: MediaView, didSetImage image: UIImage) { }
    
    public func willChangeDismissing(for mediaView: MediaView) { }
    
    public func didChangeDismissing(for mediaView: MediaView) { }
    
    public func willEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool) { }
    
    public func didEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool) { }
    
    public func mediaView(_ mediaView: MediaView, didDownloadImage image: UIImage) { }
    
    public func mediaView(_ mediaView: MediaView, didDownloadVideo video: URL) { }
    
    public func mediaView(_ mediaView: MediaView, didDownloadAudio audio: URL) { }
    
    public func mediaView(_ mediaView: MediaView, didDownloadGif gif: UIImage) { }
    
    public func handleTitleSelection(in mediaView: MediaView) { }
    
    public func handleDetailsSelection(in mediaView: MediaView) { }
}
