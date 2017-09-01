//
//  ViewController.swift
//  MediaView
//
//  Created by andrewboryk on 06/27/2017.
//  Copyright (c) 2017 andrewboryk. All rights reserved.
//

import UIKit
import MediaView

class ViewController: UIViewController {
    
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
        
        if let font = UIFont(name: "STHeitiTC-Medium", size: 12) {
            mediaView.trackFont = font
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mediaView.setVideo(url: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4", thumbnailUrl: "http://camendesign.com/code/video_for_everybody/poster.jpg")
        mediaView.setTitle("Big Buck Bunny")
    }
}

