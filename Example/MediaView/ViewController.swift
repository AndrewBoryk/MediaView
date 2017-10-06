//
//  ViewController.swift
//  MediaView
//
//  Created by andrewboryk on 06/27/2017.
//  Copyright (c) 2017 andrewboryk. All rights reserved.
//

import UIKit
import MediaView

class ViewController: UIViewController, MediaViewDelegate {

    @IBOutlet weak var mediaView: MediaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaView.swipeMode = .minimize
        mediaView.shouldDisplayFullscreen = true
        mediaView.shouldPresentFromOriginRect = true
        mediaView.shouldAutoPlayAfterPresentation = true
        MediaView.audioTypeWhenPlay = .playWhenSilent
        MediaView.audioTypeWhenStop = .standard
        mediaView.minimizedAspectRatio = .landscapeRatio
        mediaView.backgroundColor = .black
        mediaView.themeColor = .red
        mediaView.shouldShowTrack = true
        mediaView.allowLooping = true
        mediaView.shouldDisplayRemainingTime = true
        mediaView.contentMode = .scaleAspectFit
        mediaView.imageViewNotReused = true
        mediaView.topBuffer = .statusBarBuffer
        mediaView.delegate = self
        
        if let font = UIFont(name: "STHeitiTC-Medium", size: 12) {
            mediaView.trackFont = font
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mediaView.setGIF(url: "http://static1.squarespace.com/static/552a5cc4e4b059a56a050501/565f6b57e4b0d9b44ab87107/566024f5e4b0354e5b79dd24/1449141991793/NYCGifathon12.gif")
//        mediaView.setVideo(url: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", thumbnailUrl: "http://camendesign.com/code/video_for_everybody/poster.jpg")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            Notification.post(.mediaViewWillRotateNotification)
        }) { _ in
            Notification.post(.mediaViewDidRotateNotification)
        }
    }
    
    func mediaView(_ mediaView: MediaView, didChangeOffset offsetPercentage: CGFloat) {
        if !UIApplication.shared.isStatusBarHidden {
            if offsetPercentage < (.statusBarBuffer / UIScreen.superviewHeight) * 0.66 {
                UIApplication.shared.statusBarStyle = .lightContent
            } else {
                UIApplication.shared.statusBarStyle = .default
            }
        }
    }
    
    func didPlayMedia(for mediaView: MediaView) {
        // MediaView did play media (video or audio)
    }
    
    func didFailToPlayMedia(for mediaView: MediaView) {
        // MediaView did fail to play media
    }
    
    func didPauseMedia(for mediaView: MediaView) {
        // MediaView's playabale media was paused
    }
    
    func didFinishPlayableMedia(for mediaView: MediaView, withLoop didLoop: Bool) {
        // Playable media (video or audio) did finish playing til the end, and specifies whether the video will loop
    }
    
    func willPresent(mediaView: MediaView) {
        // Called before the MediaView has finished presenting
    }
    
    func didPresent(mediaView: MediaView) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func willDismiss(mediaView: MediaView) {
        // Called before the MediaView has finished dismissing
    }
    
    func didDismiss(mediaView: MediaView) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    func willChangeMinimization(for mediaView: MediaView) {
        // MediaView's frame will change when minimizing
    }
    
    func didChangeMinimization(for mediaView: MediaView) {
        // MediaView's frame did change when minimizing
    }
    
    func willEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool) {
        // MediaView will end minimizing gesture
    }
    
    func didEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool) {
        if isMinimized {
            UIApplication.shared.statusBarStyle = .default
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    func mediaView(_ mediaView: MediaView, didSetImage image: UIImage) {
        // MediaView did set .image value
    }
    
    func willChangeDismissing(for mediaView: MediaView) {
        // MediaView's frame will change when dismissing
    }
    
    func didChangeDismissing(for mediaView: MediaView) {
        // MediaView's frame did change when dismissing
    }
    
    func willEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool) {
        // MediaView will end dismissing gesture
    }
    
    func didEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool) {
        if didDismiss {
            UIApplication.shared.statusBarStyle = .default
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    func mediaView(_ mediaView: MediaView, didDownloadImage image: UIImage) {
        // Image was downloaded from the web
    }
    
    func mediaView(_ mediaView: MediaView, didDownloadVideo video: URL) {
        // Video was downloaded from the web
    }
    
    func mediaView(_ mediaView: MediaView, didDownloadAudio audio: URL) {
        // Audio was downloaded from the web
    }
    
    func mediaView(_ mediaView: MediaView, didDownloadGif gif: UIImage) {
        // Gif was downloaded from the web
    }
    
    func handleTitleSelection(in mediaView: MediaView) {
        // Title was selected, you can perform an action like linking to a profile or external source
    }
    
    func handleDetailsSelection(in mediaView: MediaView) {
        // Detail label was selected, you can perform an action like linking to the full post or a group
    }
}

