//
//  Player.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation
import AVFoundation

class Player: AVPlayer {
    
    override func play() {
        VolumeManager.shared.adjustAudioWhenPlaying()
        super.pause()
    }
    
    override func pause() {
        VolumeManager.shared.adjustAudioWhenStopping()
        super.pause()
    }
    
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
