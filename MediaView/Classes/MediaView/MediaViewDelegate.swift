//
//  MediaViewDelegate.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/26/17.
//

import Foundation

protocol MediaViewDelegate: class {
    
    /// A listener to know what percentage that the view has minimized, at a value from 0 to 1
    func mediaView(_ mediaView: MediaView, didChangeOffset offsetPercentage: Float)
    
    /// When the mediaView begins playing a video
    func didPlayVideo(for mediaView: MediaView)
    
    /// When the mediaView fails to play a video
    func didFailToPlayVideo(for mediaView: MediaView)
    
    /// When the mediaView pauses a video
    func didPauseVideo(for mediaView: MediaView)
    
    /// When the mediaView finishes playing a video, and whether it looped
    func didFinishVideo(for mediaView: MediaView, withLoop didLoop: Bool)
    
    /// Called when the mediaView has begun the presentation process
    func willPresent(mediaView: MediaView)
    
    /// Called when the mediaView has been presented
    func didPresent(mediaView: MediaView)
    
    /// Called when the mediaView has begun the dismissal process
    func willDismiss(mediaView: MediaView)
    
    /// Called when the mediaView has completed the dismissal process. Useful if not looking to utilize the dismissal completion block
    func didDismiss(mediaView: MediaView)
    
    /// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
    func willChangeMinimization(for mediaView: MediaView)
    
    /// Called when the mediaView is in the process of minimizing, and has made a change in frame
    func didChangeMinimization(for mediaView: MediaView)
    
    /// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
    func willEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool)
    
    /// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
    func didEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool)
    
    /// Called when the 'image' value of the UIImageView has been set
    func mediaView(_ mediaView: MediaView, didSetImage image: UIImage)
    
    /// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
    func willChangeDismissing(for mediaView: MediaView)
    
    /// Called when the mediaView is in the process of minimizing, and has made a change in frame
    func didChangeDismissing(for mediaView: MediaView)
    
    /// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
    func willEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool)
    
    /// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
    func didEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool)
    
    /// Called when the mediaView has completed downloading the image from the web
    func mediaView(_ mediaView: MediaView, didDownloadImage image: UIImage)
    
    /// Called when the mediaView has completed downloading the video from the web
    func mediaView(_ mediaView: MediaView, didDownloadVideo video: URL)
    
    /// Called when the mediaView has completed downloading the audio from the web
    func mediaView(_ mediaView: MediaView, didDownloadAudio audio: URL)
    
    /// Called when the mediaView has completed downloading the gif from the web
    func mediaView(_ mediaView: MediaView, didDownloadGif gif: UIImage)
    
    /// Called when the user taps the title label
    func handleTitleSelection(in mediaView: MediaView)
    
    /// Called when the user taps the details label
    func handleDetailsSelection(in mediaView: MediaView)
}

extension MediaView: MediaViewDelegate {
    func mediaView(_ mediaView: MediaView, didChangeOffset offsetPercentage: Float) {
        
    }
    
    func didPlayVideo(for mediaView: MediaView) {
        
    }
    
    func didFailToPlayVideo(for mediaView: MediaView) {
        
    }
    
    func didPauseVideo(for mediaView: MediaView) {
        
    }
    
    func didFinishVideo(for mediaView: MediaView, withLoop didLoop: Bool) {
        
    }
    
    func willPresent(mediaView: MediaView) {
        
    }
    
    func didPresent(mediaView: MediaView) {
        
    }
    
    func willDismiss(mediaView: MediaView) {
        
    }
    
    func didDismiss(mediaView: MediaView) {
        
    }
    
    func willChangeMinimization(for mediaView: MediaView) {
        
    }
    
    func didChangeMinimization(for mediaView: MediaView) {
        
    }
    
    func willEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool) {
        
    }
    
    func didEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool) {
        
    }
    
    func mediaView(_ mediaView: MediaView, didSetImage image: UIImage) {
        
    }
    
    func willChangeDismissing(for mediaView: MediaView) {
        
    }
    
    func didChangeDismissing(for mediaView: MediaView) {
        
    }
    
    func willEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool) {
        
    }
    
    func didEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool) {
        
    }
    
    func mediaView(_ mediaView: MediaView, didDownloadImage image: UIImage) {
        
    }
    
    func mediaView(_ mediaView: MediaView, didDownloadVideo video: URL) {
        
    }
    
    func mediaView(_ mediaView: MediaView, didDownloadAudio audio: URL) {
        
    }
    
    func mediaView(_ mediaView: MediaView, didDownloadGif gif: UIImage) {
        
    }
    
    func handleTitleSelection(in mediaView: MediaView) {
        
    }
    
    func handleDetailsSelection(in mediaView: MediaView) {
        
    }
}
