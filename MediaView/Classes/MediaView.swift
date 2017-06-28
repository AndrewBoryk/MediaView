//
//  MediaView.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import UIKit
import AVFoundation

@objc protocol MediaViewDelegate: NSObjectProtocol {
    
    /// A listener to know what percentage that the view has minimized, at a value from 0 to 1
    @objc optional func mediaView(_ mediaView: MediaView, didChangeOffset offsetPercentage: Float)
    
    /// When the mediaView begins playing a video
    @objc optional func didPlayVideo(for mediaView: MediaView)
    
    /// When the mediaView fails to play a video
    @objc optional func didFailToPlayVideo(for mediaView: MediaView)
    
    /// When the mediaView pauses a video
    @objc optional func didPauseVideo(for mediaView: MediaView)
    
    /// When the mediaView finishes playing a video, and whether it looped
    @objc optional func didFinishVideo(for mediaView: MediaView, withLoop didLoop: Bool)
    
    /// Called when the mediaView has begun the presentation process
    @objc optional func willPresent(mediaView: MediaView)
    
    /// Called when the mediaView has been presented
    @objc optional func didPresent(mediaView: MediaView)
    
    /// Called when the mediaView has begun the dismissal process
    @objc optional func willDismiss(mediaView: MediaView)
    
    /// Called when the mediaView has completed the dismissal process. Useful if not looking to utilize the dismissal completion block
    @objc optional func didDismiss(mediaView: MediaView)
    
    /// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
    @objc optional func wChangeMinimization(for mediaView: MediaView)
    
    /// Called when the mediaView is in the process of minimizing, and has made a change in frame
    @objc optional func didChangeMinimization(for mediaView: MediaView)
    
    /// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
    @objc optional func willEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool)
    
    /// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
    @objc optional func didEndMinimizing(for mediaView: MediaView, atMinimizedState isMinimized: Bool)
    
    /// Called when the 'image' value of the UIImageView has been set
    @objc optional func mediaView(_ mediaView: MediaView, didSetImage image: UIImage)
    
    /// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
    @objc optional func willChangeDismissing(for mediaView: MediaView)
    
    /// Called when the mediaView is in the process of minimizing, and has made a change in frame
    @objc optional func didChangeDismissing(for mediaView: MediaView)
    
    /// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
    @objc optional func willEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool)
    
    /// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
    @objc optional func didEndDismissing(for mediaView: MediaView, withDismissal didDismiss: Bool)
    
    /// Called when the mediaView has completed downloading the image from the web
    @objc optional func mediaView(_ mediaView: MediaView, didDownloadImage image: UIImage)
    
    /// Called when the mediaView has completed downloading the video from the web
    @objc optional func mediaView(_ mediaView: MediaView, didDownloadVideo video: URL)
    
    /// Called when the mediaView has completed downloading the audio from the web
    @objc optional func mediaView(_ mediaView: MediaView, didDownloadAudio audio: URL)
    
    /// Called when the mediaView has completed downloading the gif from the web
    @objc optional func mediaView(_ mediaView: MediaView, didDownloadGif gif: UIImage)
    
    /// Called when the user taps the title label
    @objc optional func handleTitleSelection(in mediaView: MediaView)
    
    /// Called when the user taps the details label
    @objc optional func handleDetailsSelection(in mediaView: MediaView)
}

class MediaView: UIImageView, UIGestureRecognizerDelegate {
    
    /// Delegate for the mediaView
    weak var delegate: MediaViewDelegate?
    
    /// Image completed loading onto ABMediaView
    typealias ImageCompletionBlock = (_ image: UIImage, _ error: Error?) -> Void
    
    /// Video completed loading onto ABMediaView
    typealias VideoDataCompletionBlock = (_ video: String, _ error: Error?) -> Void
    
    /// Determines if video is minimized
    private(set) public var isMinimized = false
    
    /// Keeps track of how much the video has been minimized
    private(set) public var offsetPercentage: CGFloat = 0.0
    
    /// Determines whether the content's original size is full screen. If you are looking to make it so that when a mediaView is selected from another view, that it opens up in full screen, then set the property 'shouldDisplayFullScreen'
    private(set) public var isFullscreen = false
    
    /// Determines if the video is already loading
    private(set) public var isLoadingVideo = false
    
    /// Queue which holds an array of mediaViews to be displayed
    var mediaViewQueue = [MediaView]()
    
    /// Media view that is currently presented by the manager
    var currentMediaView: MediaView?
    
    /// Main window which the mediaView will be added to
    var mainWindow: UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    // MARK: - Data Properties
    /// URL endpoint for image
    var imageURL: String?
    
    /// Image cached after loading
    var imageCache: UIImage?
    
    /// URL endpoint for video
    var videoURL: String?
    
    /// Video location on disk that was cached after loading
    var videoCache: URL?
    
    /// URL endpoint for audio
    var audioURL: String?
    
    /// Audio location on disk that was cached after loading
    var audioCache: URL?
    
    /// URL endpoint for gif
    var gifURL: String?
    
    /// Data for gif
    var gifData: Data?
    
    /// Gif cached after loading
    var gifCache: UIImage?
    
    // MARK: - Interface properties
    /// Track which shows the progress of the video being played
    var track = TrackView()
    
    /// Gradient dark overlay on top of the mediaView which UI can be placed on top of
    var topOverlay = UIImageView()
    
    /// Label at the top of the mediaView, displayed within the topOverlay. Designated for a title, but other text can be inserted
    var titleLabel = Label()
    
    /// Label at the top of the mediaView, displayed within the topOverlay. Designated for details
    var detailsLabel = Label()
    
    // MARK: - Customizable Properties
    /// If all media is sourced from the same location, then the ABCacheManager will search the Directory for files with the same name when getting cached objects, since they all have the same remote location
    // FIXME: Update
    var isAllMediaFromSameLocation = false
    
    /// Download video and audio before playing
    var shouldPreloadVideoAndAudio = false
    
    /// Automate caching for media
    var shouldCacheMedia = false
    
    /// Theme color which will show on the play button and progress track for videos
    var themeColor = UIColor.cyan
    
    /// Determines whether the video playerLayer should be set to aspect fit mode
    var videoAspectFit = false
    
    /// Determines whether the progress track should be shown for video
    var shouldShowTrack = false
    
    /// Determines if the video should be looped when it reaches completion
    var allowLooping = false
    
    /// Determines whether or not the mediaView is being used in a reusable view
    var imageViewNotReused = false
    
    /// Determines whether the mediaView can be minimized into the bottom right corner, and then dismissed by swiping right on the minimized version
    var isMinimizable = false
    
    /// Determines whether the mediaView can be dismissed by swiping down on the view, this setting would override isMinimizable
    var isDismissable = false
    
    /// Determines whether the video occupies the full screen when displayed
    var shouldDisplayFullscreen = false
    
    /// Toggle functionality for remaining time to show on right track label rather than showing total time
    var shouldDisplayRemainingTime = false
    
    /// Toggle functionality for hiding the close button from the fullscreen view. If minimizing is disabled, this functionality is not allowed.
    var shouldHideCloseButton = false
    
    /// Toggle functionality to not have a play button visible
    var shouldHidePlayButton = false
    
    /// Toggle functionality to have the mediaView autoplay the video associated with it after presentation
    var shouldAutoPlayAfterPresentation = false
    
    /// Change font for track labels
    // FIXME: Update
    var trackFont: UIFont?
    
    /// Custom image can be set for the play button (video)
    var customPlayButton: UIImage?
    
    /// Custom image can be set for the play button (music)
    var customMusicButton: UIImage?
    
    /// Custom image can be set for when media fails to play
    var customFailButton: UIImage?
    
    /// Timer for animating the playIndicatorView, to show that the video is loading
    private var animateTimer: Timer?
    
    /// Setting this value to true will allow you to have the fullscreen popup originate from the frame of the original view, without having to set the originRect yourself
    var shouldPresentFromOriginRect = false
    
    /// Rect that specifies where the mediaView's frame will originate from when presenting, and needs to be converted into its position in the mainWindow
    var originRect: CGRect?
    
    /// Rect that specifies where the mediaView's frame will originate from when presenting, and is already converted into its position in the mainWindow
    var originRectConverted: CGRect?
    
    /// By default, there is a buffer of 12px on the bottom of the view, and more space can be added by adjusting this bottom buffer. This is useful in order to have the mediaView show above UITabBars, UIToolbars, and other views that need reserved space on the bottom of the screen.
    var bottomBuffer: CGFloat = 0.0 {
        didSet {
            if bottomBuffer < 0 {
                bottomBuffer = 0
            } else if bottomBuffer > 120 {
                bottomBuffer = 120
            }
        }
    }
    
    /// Ratio that the minimized view will be shruken to, can be set to a custom value or one of the available ABMediaViewRatioPresets. (Height/Width)
    var minimizedAspectRatio: CGFloat = .landscapeRatio {
        didSet {
            if minimizedAspectRatio <= 0 {
                minimizedAspectRatio = .landscapeRatio
            }
        }
    }
    
    /// Ratio of the screen's width that the mediaView's minimized view will stretch across.
    var minimizedWidthRatio: CGFloat = 0.5 {
        didSet {
            if minimizedWidthRatio < 0.25 {
                minimizedWidthRatio = 0.25
            }
        }
    }
    
    /// Ability to offset the subviews at the top of the screen to avoid hiding other views (ie. UIStatusBar)
    var topBuffer: CGFloat = 0.0 {
        didSet {
            if topBuffer < 0 {
                topBuffer = 0
            } else if topBuffer > 64 {
                topBuffer = 64
            }
            
            // FIXME: Add rest
        }
    }
    
    /// Determines whether the view has a video
    private var hasVideo: Bool {
        return videoURL != nil
    }
    
    /// Determines whether the view has a audio
    private var hasAudio: Bool {
        return audioURL != nil
    }
    
 
    /// Determines whether the view has media (video or audio)
    private var hasMedia: Bool {
        return hasVideo || hasAudio
    }
    
    /// Determines whether the view is already playing video
    private var isPlayingVideo: Bool {
        if (didFailToPlayMedia) {
            return false;
        }
        
        if let player = player {
            if (((player.rate != 0) && (player.error == nil)) || isLoadingVideo) {
                return true;
            }
        }
        
        return false;
    }
    
    /// Determines whether the user can press and hold the image thumbnail for GIF
    var pressShowsGIF: Bool = false
    
    /// Determines whether user is long pressing thumbnail
    private var isLongPressing: Bool = false
    
    /// File being played is from directory
    var isFileFromDirectory: Bool = false
    
    /// Width of the mainWindow
    var superviewWidth: CGFloat {
        let screenRect: CGRect = UIScreen.main.bounds
        let width: CGFloat = screenRect.size.width
        let height: CGFloat = screenRect.size.height
        
        return width > height ? width : height
    }
    
    /// Height of the mainWindow
    var superviewHeight: CGFloat {
        let screenRect: CGRect = UIScreen.main.bounds
        let width: CGFloat = screenRect.size.width
        let height: CGFloat = screenRect.size.height
        
        return width < height ? width : height
    }
    
    /// The width of the view when minimized
    private var minViewWidth: CGFloat {
        return superviewWidth * minimizedWidthRatio
    }
    
    /// The height of the view when minimized
    private var minViewHeight: CGFloat {
        return minViewWidth * minimizedAspectRatio
    }
    
    /// The maximum amount of y offset for the mediaView
    private var maxViewOffset: CGFloat {
        return superviewWidth - minViewHeight + bottomBuffer + 12
    }
    
    /// Height constraint of the top overlay
    private var topOverlayHeight: NSLayoutConstraint?
    
    /// Space between the titleLabel and the superview
    private var titleTopOffset: NSLayoutConstraint?
    
    /// Space between the detailsLabel and the superview
    private var detailsTopOffset: NSLayoutConstraint?
    
    /// Play button imageView which shows in the center of the video or audio, notifies the user that a video or audio can be played
    private var playIndicatorView: UIImageView?
    
    /// Closes the mediaView when in fullscreen mode
    private var closeButton: UIButton?
    
    /// ABPlayer which will handle video playback
    private var player: Player?
    
    /// AVPlayerLayer which will display video
    private var playerLayer: AVPlayerLayer?
    
    /// Original superview for presenting mediaview
    private var originalSuperview: UIView?
    
    // MARK: - Gesture Properties
    
    /// Recognizer to record user swiping
    private var swipeRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe))
        recognizer.delegate = self as? UIGestureRecognizerDelegate
        recognizer.delaysTouchesBegan = true
        recognizer.cancelsTouchesInView = true
        recognizer.maximumNumberOfTouches = 1
        recognizer.isEnabled = false
        
        return recognizer
    }()
    
    /// Recognizer to record a user swiping right to dismiss a minimize video
    private var dismissRecognizer: UIPanGestureRecognizer?
    
    /// Recognizer which keeps track of whether the user taps the view to play or pause the video
    private var tapRecognizer: UITapGestureRecognizer?
    
    /// Recognizer for when the thumbnail experiences a long press
    private var gifLongPressRecognizer: UILongPressGestureRecognizer?
    
    // MARK: - Variable Properties
    /// Position of the swipe vertically
    private var ySwipePosition: CGFloat = 0.0
    
    /// Position of the swipe horizontally
    private var xSwipePosition: CGFloat = 0.0
    
    /// Variable tracking offset of video
    private var offset: CGFloat = 0.0
    
    /// Number of seconds in the buffer
    private var bufferTime: CGFloat = 0.0
    
    /// Determines if the play has failed to play media
    private var didFailToPlayMedia: Bool = false
    
    // MARK: - Private Methods
    /// Remove observers for player
    private func removeObservers() {
    
    }
    
    /// Selector to play the video from the playRecognizer
    private func handleTapFromRecognizer() {

    }
    
    /// Loads the video, saves to disk, and decides whether to play the video
    func loadVideo(withPlay play: Bool, withCompletion completion: VideoDataCompletionBlock) {

    }
    
    /// Show that the video is loading with animation
    private func loadVideoAnimate() {

    }
    
    /// Stop video loading animation
    private func stopVideoAnimate() {

    }
    
    /// Update the frame of the playerLayer
 
    private func updatePlayerFrame() {
    
    }
    
    @objc private func handleSwipe() {
        
    }

    private init(mediaView: MediaView) {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Shared Manager, which keeps track of mediaViews
    class func sharedManager() -> MediaView? {
        return nil
    }
}
