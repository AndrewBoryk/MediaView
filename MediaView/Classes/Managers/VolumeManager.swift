//
//  VolumeManager.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation
import AVFoundation

public class VolumeManager {
    
    public enum AudioType: String {
        case standard = "AVAudioSessionCategorySoloAmbient"
        case playWhenSilent = "AVAudioSessionCategoryPlayback"
        
    }
    
    /// Shared instance of VolumeManager
    public static let shared = VolumeManager()
    
    /// Specifies how audio session will be when media plays
    public var audioTypeWhenPlay: AudioType = .standard
    
    /// Specifies how audio session will be when media stops
    public var audioTypeWhenStop: AudioType = .standard
    
    /// Shared instance of AVAudioSession
    private var session = AVAudioSession.sharedInstance()
    
    /// Current audio type setting for the mediaView
    private var currentAudioType: AudioType {
        get { return AudioType(rawValue: session.category) ?? .standard }
        set { _ = try? session.setCategory(newValue.rawValue, with: .mixWithOthers) }
    }
    
    // MARK: - Public
    
    /// Adjust audio to specified audioType when mediaView begins playing
    public func adjustAudioWhenPlaying() {
        currentAudioType = audioTypeWhenPlay
    }
    
    /// Adjust audio to specified audioType when mediaView stops playing
    public func adjustAudioWhenStopping() {
        currentAudioType = audioTypeWhenStop
    }
}
