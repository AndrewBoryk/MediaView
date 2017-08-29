//
//  CacheManager.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation
import AVFoundation

/// Image completed loading onto ABMediaView
typealias ImageCompletionBlock = (_ image: UIImage?, _ error: Error?) -> Void

/// Media completed loading onto ABMediaView
typealias MediaDataCompletionBlock = (_ video: String?, _ error: Error?) -> Void

class CacheManager {
    
    /// Different types of directory items
    enum DirectoryItem {
        case video
        case audio
        case all
        case temp
    }
    
    enum Cache {
        case image
        case video
        case audio
        case gif
        
        var cache: NSCache<NSString, AnyObject> {
            switch self {
            case .image:
                return CacheManager.shared.imageCache
            case .video:
                return CacheManager.shared.videoCache
            case .audio:
                return CacheManager.shared.audioCache
            case .gif:
                return CacheManager.shared.gifCache
            }
        }
        
        var queue: NSCache<NSString, AnyObject> {
            switch self {
            case .image:
                return CacheManager.shared.imageQueue
            case .video:
                return CacheManager.shared.videoQueue
            case .audio:
                return CacheManager.shared.audioQueue
            case .gif:
                return CacheManager.shared.gifQueue
            }
        }
        
        func getObject(for key: String) -> Any? {
            switch self {
            case .image, .gif:
                return self.cache.object(forKey: key.NS) as? UIImage
            case .audio, .video:
                if let filePath = URL(string: key)?.absoluteString {
                    if self == .video, let location = CacheManager.file(forCache: .video, filePath: filePath) {
                        return location
                    } else if self == .audio, let location = CacheManager.file(forCache: .audio, filePath: filePath) {
                        return location
                    }
                }
                
                guard let value = self.cache.object(forKey: key.NS) as? String else {
                    return nil
                }
                
                return value
            }
        }
        
        func set(object: Any, forKey key: String) {
            switch self {
            case .image, .gif:
                if let value = object as? UIImage {
                    self.cache.setObject(value, forKey: key.NS)
                }
            case .audio, .video:
                if let value = object as? String {
                    self.cache.setObject(value.NS, forKey: key.NS)
                }
            }
        }
        
        func removeObject(forKey key: String) {
            self.cache.removeObject(forKey: key.NS)
        }
        
        func isQueued(_ key: String) -> Bool {
            return self.queue.object(forKey: key.NS) as? String != nil
        }
        
        func setQueued(_ key: String) {
            if !self.isQueued(key) {
                self.queue.setObject(key.NS, forKey: key.NS)
            }
        }
        
        func dequeue(_ key: String) {
            self.queue.removeObject(forKey: key.NS)
        }
    }
    
    static let shared = CacheManager()
    
    /// Cache for images
    private var imageCache = NSCache<NSString, AnyObject>()
    
    /// Cache for videos
    private var videoCache = NSCache<NSString, AnyObject>()
    
    /// Cache for audio
    private var audioCache = NSCache<NSString, AnyObject>()
    
    /// Cache for GIFs
    private var gifCache = NSCache<NSString, AnyObject>()
    
    /// Queue for loading images
    private var imageQueue = NSCache<NSString, AnyObject>()
    
    /// Queue for loading videos
    private var videoQueue = NSCache<NSString, AnyObject>()
    
    /// Queue for loading audio
    private var audioQueue = NSCache<NSString, AnyObject>()
    
    /// Queue for loading GIFs
    private var gifQueue = NSCache<NSString, AnyObject>()
    
    /// Whether media like videos and audio should be preloaded before manual play or autoplay begins
    var shouldPreloadPlayableMedia = false
    
    /// Determines whether media should be cached to the directory
    var cacheMediaWhenDownloaded = false {
        didSet {
            if !cacheMediaWhenDownloaded {
                CacheManager.shared.reset(cache: .image)
            }
        }
    }
    
    /// Automate caching for media (default: false)
    var shouldCacheStreamedMedia = false
    
    /// Download the video
    func preloadVideo(url: String, isFromDirectory: Bool = false) {
        if isFromDirectory {
            loadVideo(url: URL(fileURLWithPath: url))
        } else {
            loadVideo(urlString: url)
        }
    }
    
    /// Download the audio
    func preloadAudio(url: String, isFromDirectory: Bool = false) {
        if url.contains("ipod-library://") {
            // FIXME: Load audio from music library
        } else if isFromDirectory {
            loadAudio(url: URL(fileURLWithPath: url))
        } else {
            loadAudio(urlString: url)
        }
    }
    
    func loadImage(urlString: String, completion: ImageCompletionBlock? = nil) {
        DispatchQueue.main.async {
            guard let url = URL(string: urlString) else {
                completion?(nil, nil)
                return
            }
            
            self.loadImage(url: url, completion: completion)
        }
    }
    
    func loadImage(url: URL, completion: ImageCompletionBlock? = nil) {
        DispatchQueue.main.async {
            let urlString = url.absoluteString
            if let image = Cache.image.getObject(for: urlString) as? UIImage {
                Cache.image.dequeue(urlString)
                completion?(image, nil)
            } else if Cache.image.isQueued(urlString) {
                completion?(nil, nil)
            } else {
                Cache.image.setQueued(urlString)
                
                let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            if self.cacheMediaWhenDownloaded {
                                Cache.image.set(object: image, forKey: urlString)
                            }
                            
                            completion?(image, nil)
                        }
                    }
                    
                    Cache.image.dequeue(urlString)
                })
                
                task.resume()
            }
        }
    }
    
    func loadVideo(urlString: String, completion: MediaDataCompletionBlock? = nil) {
        DispatchQueue.main.async {
            guard let url = URL(string: urlString) else {
                completion?(nil, nil)
                return
            }
            
            self.loadVideo(url: url, completion: completion)
        }
    }
    
    func loadVideo(url: URL, completion: MediaDataCompletionBlock? = nil) {
        DispatchQueue.main.async {
            self.loadMedia(url: url, cache: .video, completion: completion)
        }
    }
    
    func loadAudio(urlString: String, completion: MediaDataCompletionBlock? = nil) {
        DispatchQueue.main.async {
            guard let url = URL(string: urlString) else {
                completion?(nil, nil)
                return
            }
            
            self.loadAudio(url: url, completion: completion)
        }
    }
    
    func loadAudio(url: URL, completion: MediaDataCompletionBlock? = nil) {
        DispatchQueue.main.async {
            self.loadMedia(url: url, cache: .audio, completion: completion)
        }
    }
    
    func loadMedia(url: URL, cache: Cache, completion: MediaDataCompletionBlock? = nil) {
        DispatchQueue.main.async {
            let urlString = url.absoluteString
            if let media = cache.getObject(for: urlString) as? String {
                cache.dequeue(urlString)
                completion?(media, nil)
            } else if cache.isQueued(urlString) {
                completion?(nil, nil)
            } else {
                cache.setQueued(urlString)
                
                CacheManager.detectIf(url: url, isType: cache) { isValid in
                    guard isValid,
                        let data = try? Data(contentsOf: url) else {
                        completeRequest(for: urlString, cachedPath: nil)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        guard let fileURL = CacheManager.fileURL(for: cache, url: url),
                            let _ = try? data.write(to: fileURL, options: .atomic) else {
                            completeRequest(for: urlString, cachedPath: nil)
                            return
                        }
                        
                        cache.set(object: fileURL.absoluteString, forKey: urlString)
                        completeRequest(for: urlString, cachedPath: fileURL.absoluteString)
                    }
                }
            }
        }
        
        func completeRequest(for urlString: String, cachedPath: String?) {
            cache.dequeue(urlString)
            completion?(cachedPath, nil)
        }
    }
    
    static func cache(url: String, cache: Cache, asset: AVAsset) {
        switch cache {
        case .video:
            guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality),
                let fileURL = URL(string: url),
                let filePath = CacheManager.fileURL(for: cache, url: fileURL) else {
                return
            }
            
            exporter.outputURL = filePath
            exporter.shouldOptimizeForNetworkUse = true
            exporter.outputFileType = .mp4
            
            exporter.exportAsynchronously {
                switch exporter.status {
                case .failed, .cancelled, .unknown:
                    break
                case .completed:
                    if let exportedURL = exporter.outputURL {
                        cache.set(object: exportedURL, forKey: url)
                    }
                default:
                    break
                }
            }
        default:
            return
        }
    }
    
    private static func detectIf(url: URL, isType cache: Cache, completion: @escaping ((_ isValid: Bool) -> Void)) {
        NSURLConnection.sendAsynchronousRequest(URLRequest(url: url), queue: .main) { (response, data, error) in
            guard error == nil,
                let data = data,
                data.count > 0,
                let httpResponse = response as? HTTPURLResponse,
                let contentType = httpResponse.allHeaderFields["content-type"] as? String else {
                completion(false)
                return
            }
            
            switch cache {
            case .image where contentType.contains("image/"):
                completion(true)
            case .video where contentType.contains("video/"):
                completion(true)
            case .audio where contentType.contains("audio/"):
                completion(true)
            case .gif where contentType.contains("image/gif"):
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    private static func fileURL(for cache: Cache, url: URL) -> URL? {
        do {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let ending = cache == .video ? "Video" : "Audio"
            let directoryPath = "\(paths.first ?? "")/ABMedia/\(ending)"
            
            if !FileManager.default.fileExists(atPath: directoryPath) {
                try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: false, attributes: nil)
            }
            
            // Create folder
            let uniqueFileName = url.lastPathComponent
            let filePath = "\(directoryPath)/\(uniqueFileName)"
            
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }
            
            return URL(fileURLWithPath: filePath)
        } catch {
            return nil
        }
    }
    
    static func file(forCache cache: DirectoryItem, filePath: String) -> String? {
        var component = ""
        
        switch cache {
        case .video:
            component = "Audio/"
        case .audio:
            component = "Video/"
        default:
            break
        }
        
        let url = URL(fileURLWithPath: NSHomeDirectory())
        let path = url.appendingPathComponent(component)
        let filePath: String = "Documents/ABMedia/\(path)\(filePath)"
        
        if FileManager.default.fileExists(atPath: filePath) {
            return URL(fileURLWithPath: filePath).absoluteString
        }
        
        return nil
    }
    
    static func clear(directory: DirectoryItem) {
        var component = "Documents/ABMedia/"
        
        switch directory {
        case .video:
            CacheManager.shared.reset(cache: .video)
            component = "\(component)Video/"
        case .audio:
            CacheManager.shared.reset(cache: .audio)
            component = "\(component)Audio/"
        case .temp:
            component = "tmp/"
        case .all:
            CacheManager.shared.reset(cache: .video)
            CacheManager.shared.reset(cache: .audio)
        }
        
        let url = URL(fileURLWithPath: NSHomeDirectory())
        let path = url.appendingPathComponent(component)
        
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: path.absoluteString) {
            for fileComponent in contents {
                let fullPath = path.appendingPathComponent(fileComponent).absoluteString
                try? FileManager.default.removeItem(atPath: fullPath)
            }
        }
    }
    
    func reset(cache: Cache) {
        switch cache {
        case .image:
            imageCache = NSCache<NSString, AnyObject>()
            imageQueue = NSCache<NSString, AnyObject>()
        case .video:
            videoCache = NSCache<NSString, AnyObject>()
            videoQueue = NSCache<NSString, AnyObject>()
        case .audio:
            audioCache = NSCache<NSString, AnyObject>()
            audioQueue = NSCache<NSString, AnyObject>()
        case .gif:
            gifCache = NSCache<NSString, AnyObject>()
            gifQueue = NSCache<NSString, AnyObject>()
        }
    }
    
    func reset() {
        reset(cache: .image)
        reset(cache: .video)
        reset(cache: .audio)
        reset(cache: .gif)
    }
}
