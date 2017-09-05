//
//  Player.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation
import AVFoundation
import CoreMedia

protocol PlayerDelegate: class {
    func didPlay(player: Player)
    func didPause(player: Player)
    func didFail(player: Player)
    func didBecomeReadyToPlay(player: Player)
    func didProgress(to time: TimeInterval, item: AVPlayerItem)
    func didBuffer(to time: TimeInterval, item: AVPlayerItem)
    func playbackLikelyToKeepUp(for player: Player)
    func bufferDidBecomeNotEmpty(for player: Player)
    func bufferDidBecomeEmpty(for player: Player)
    func cacheMedia(for asset: AVAsset)
}

class Player: AVPlayer {
    
    weak var delegate: PlayerDelegate?
    
    private var observers = [NSKeyValueObservation?]()
    
    override func play() {
        VolumeManager.shared.adjustAudioWhenPlaying()
        super.play()
        
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
    
    func addObservers() {
        removeObservers()
        
        guard let currentItem = currentItem else {
            return
        }
        
        observers.append(currentItem.observe(\.status, options: .new) { (sender, _) in
            switch sender.status {
            case .failed, .unknown:
                self.delegate?.didFail(player: self)
                self.removeObservers()
            case .readyToPlay:
                self.delegate?.didBecomeReadyToPlay(player: self)
            }
        })
        
        observers.append(currentItem.observe(\.loadedTimeRanges, options: .new) { (sender, _) in
            var bufferTime: TimeInterval = 0
            
            for time in currentItem.loadedTimeRanges {
                let buffer = TimeInterval(CMTimeGetSeconds(time.timeRangeValue.duration))
                
                if buffer > bufferTime {
                    bufferTime = buffer
                }
            }
            
            let duration = TimeInterval(CMTimeGetSeconds(currentItem.duration))
            self.delegate?.didBuffer(to: bufferTime, item: currentItem)
            
            if bufferTime == duration, CacheManager.shared.shouldCacheStreamedMedia {
                self.delegate?.cacheMedia(for: currentItem.asset)
            }
        })
        
        observers.append(currentItem.observe(\.isPlaybackBufferEmpty, options: .new) { (sender, _) in
            self.delegate?.bufferDidBecomeEmpty(for: self)
        })
        
        observers.append(currentItem.observe(\.isPlaybackLikelyToKeepUp, options: .new) { (sender, _) in
            self.delegate?.playbackLikelyToKeepUp(for: self)
        })
        
        observers.append(currentItem.observe(\.isPlaybackBufferFull, options: .new) { (sender, _) in
            self.delegate?.bufferDidBecomeNotEmpty(for: self)
        })
        
        addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) { time in
            self.delegate?.didProgress(to: TimeInterval(CMTimeGetSeconds(time)), item: currentItem)
        }
    }
    
    func removeObservers() {
        observers = []
    }
}
