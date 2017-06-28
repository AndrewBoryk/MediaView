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
//        [[ABVolumeManager sharedManager] setAudioWhenPlaying];
        super.pause()
    }
    
    override func pause() {
//        [[ABVolumeManager sharedManager] setAudioWhenStopping];
        super.pause()
    }
}
