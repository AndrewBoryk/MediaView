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
        
        mediaView.setVideo(url: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", thumbnailUrl: "http://camendesign.com/code/video_for_everybody/poster.jpg")
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
        
    }
    
    func didFailToPlayMedia(for mediaView: MediaView) {
        
    }
    
    func didPauseMedia(for mediaView: MediaView) {
        
    }
    
    func didFinishPlayableMedia(for mediaView: MediaView, withLoop didLoop: Bool) {
        
    }
    
    func willPresent(mediaView: MediaView) {
        
    }
    
    func didPresent(mediaView: MediaView) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func willDismiss(mediaView: MediaView) {
        
    }
    
    func didDismiss(mediaView: MediaView) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    func willChangeMinimization(for mediaView: MediaView) {
        
    }
    
    func didChangeMinimization(for mediaView: MediaView) {
        
    }
    
    func willEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool) {
        
    }
    
    func didEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool) {
        if isMinimized {
            UIApplication.shared.statusBarStyle = .default
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    func mediaView(_ mediaView: MediaView, didSetImage image: UIImage) {
        
    }
    
    func willChangeDismissing(for mediaView: MediaView) {
        
    }
    
    func didChangeDismissing(for mediaView: MediaView) {
        
    }
    
    func willEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool) {
        if didDismiss {
            UIApplication.shared.statusBarStyle = .default
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    func didEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool) {
        if didDismiss {
            UIApplication.shared.statusBarStyle = .default
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
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

