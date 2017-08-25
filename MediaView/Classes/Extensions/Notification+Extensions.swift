//
//  Notification+Extensions.swift
//  Pods
//
//  Created by Andrew Boryk on 6/28/17.
//
//

extension Notification.Name {
    
    /// Notification for when the mediaView will rotate between landscape and portrait
    static let mediaViewWillRotateNotification = Notification.Name(rawValue: "mediaViewWillRotateNotification")
    
    /// Notification for when the mediaView will rotate between portrait and landscape
    static let mediaViewDidRotateNotification = Notification.Name(rawValue: "mediaViewDidRotateNotification")
}

public extension Notification {
    
    public var value: Any? {
        return userInfo?["value"]
    }
    
    public static func post(_ name: Notification.Name, sender: Any? = nil, value: Any? = nil) {
        var userInfo = [AnyHashable: Any]()
        if let value = value {
            userInfo["value"] = value
        }
        
        NotificationCenter.default.post(name: name, object: sender, userInfo: userInfo)
    }
    
    public static func addObserver(_ observer: Any, name: Notification.Name, selector: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
    }
}
