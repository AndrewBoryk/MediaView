//
//  Player.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation
import AVFoundation

protocol PlayerDelegate: class {
    func didPlay(player: Player)
    func didPause(player: Player)
}

class Player: AVPlayer {
    
    weak var delegate: PlayerDelegate?
    
    override func play() {
        VolumeManager.shared.adjustAudioWhenPlaying()
        super.pause()
        
        delegate?.didPlay(player: self)
    }
    
    override func pause() {
        VolumeManager.shared.adjustAudioWhenStopping()
        super.pause()
        
        delegate?.didPause(player: self)
    }
    
    /// Determines if the play has failed to play media
    var didFailToPlay: Bool {
        guard let currentItem = currentItem else {
            return false
        }
        
        return currentItem.status != .readyToPlay
    }
    
    var isPlaying: Bool {
        return rate != 0 && error == nil && !didFailToPlay
    }
}
