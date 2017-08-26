//
//  MediaView.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/24/17.
//

import Foundation
import AVFoundation

class MediaView: UIImageView, UIGestureRecognizerDelegate, LabelDelegate, TrackViewDelegate {
    
    enum SwipeMode {
        case none
        case dismiss
        case minimize
        
        var movesWhenSwipe: Bool {
            switch self {
            case .dismiss, .minimize:
                return true
            default:
                return false
            }
        }
    }
    
    /// Delegate for the mediaView
    weak var delegate: MediaViewDelegate?
    
    /// Image completed loading onto ABMediaView
    typealias ImageCompletionBlock = (_ image: UIImage, _ error: Error?) -> Void
    
    /// Video completed loading onto ABMediaView
    typealias VideoDataCompletionBlock = (_ video: String, _ error: Error?) -> Void
    
    /// Determines if video is minimized
    public var isMinimized: Bool {
        return offset == maxViewOffsetY && swipeMode == .minimize
    }
    
    /// Keeps track of how much the video has been minimized
    private(set) public var offsetPercentage: CGFloat = 0.0 {
        didSet {
            if offsetPercentage < 0 {
                offsetPercentage = 0
            } else if offsetPercentage > 1 {
                offsetPercentage = 1
            }
        }
    }
    
    /// Determines whether the content's original size is full screen. If you are looking to make it so that when a mediaView is selected from another view, that it opens up in full screen, then set the property 'shouldDisplayFullScreen'
    private(set) public var isFullScreen = false
    
    /// Determines if the video is already loading
    private(set) public var isLoadingVideo = false
    
    /// Media which is displayed in the view
    var media = Media()
    
    // MARK: - Interface properties
    
    /// Track which shows the progress of the video being played
    lazy var track: TrackView = {
        let track = TrackView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60.0))
        track.translatesAutoresizingMaskIntoConstraints = false
        track.themeColor = themeColor
        track.delegate = self
        track.isHidden = false
        
        swipeRecognizer.require(toFail: track.scrubRecognizer)
        swipeRecognizer.require(toFail: track.tapRecognizer)
        
        return track
    }()
    
    /// Gradient dark overlay on top of the mediaView which UI can be placed on top of
    var topOverlay: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.superviewHeight, height: 80))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.topOverlay(frame: imageView.bounds)
        imageView.alpha = 0
        
        return imageView
    }()
    
    /// Label at the top of the mediaView, displayed within the topOverlay. Designated for a title, but other text can be inserted
    private lazy var titleLabel = Label(width: topOverlay.frame.width, delegate: self)
    
    /// Label at the top of the mediaView, displayed within the topOverlay. Designated for details
    private lazy var detailsLabel = Label(width: topOverlay.frame.width, delegate: self)
    
    // MARK: - Customizable Properties
    /// If all media is sourced from the same location, then the ABCacheManager will search the Directory for files with the same name when getting cached objects, since they all have the same remote location
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
    
    /// Determines what action will be taken when user swipes on fullscreen mediaView
    var swipeMode: SwipeMode = .none
    
    /// Determines whether the video occupies the full screen when displayed
    var shouldDisplayFullscreen = false
    
    /// Toggle functionality for remaining time to show on right track label rather than showing total time
    var shouldDisplayRemainingTime = false
    
    /// Toggle functionality for hiding the close button from the fullscreen view. If minimizing is disabled, this functionality is not allowed.
    var shouldHideCloseButton = false {
        didSet {
            handleCloseButtonDisplay()
        }
    }
    
    /// Toggle functionality to not have a play button visible
    var shouldHidePlayButton = false
    
    /// Toggle functionality to have the mediaView autoplay the video associated with it after presentation
    var shouldAutoPlayAfterPresentation = true
    
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
    
    /// Change font for track labels
    var trackFont: UIFont = .systemFont(ofSize: 14) {
        didSet {
            track.trackFont = trackFont
        }
    }
    
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
        return media.videoURL != nil
    }
    
    /// Determines whether the view has a audio
    private var hasAudio: Bool {
        return media.audioURL != nil
    }
    
    /// Determines whether the view has media (video or audio)
    private var hasMedia: Bool {
        return hasVideo || hasAudio
    }
    
    /// Determines whether the view is already playing video
    private var isPlayingVideo: Bool {
        if (didFailToPlayMedia) {
            return false
        }
        
        if let player = player {
            if (((player.rate != 0) && (player.error == nil)) || isLoadingVideo) {
                return true
            }
        }
        
        return false
    }
    
    /// Determines whether the user can press and hold the image thumbnail for GIF
    var pressShowsGIF = false
    
    /// Determines whether user is long pressing thumbnail
    private var isLongPressing = false
    
    /// File being played is from directory
    var isFileFromDirectory = false
    
    /// The width of the view when minimized
    private var minViewWidth: CGFloat {
        return UIScreen.superviewWidth * minimizedWidthRatio
    }
    
    /// The height of the view when minimized
    private var minViewHeight: CGFloat {
        return minViewWidth * minimizedAspectRatio
    }
    
    /// The maximum amount of y offset for the mediaView when minimizing
    private var maxViewOffsetY: CGFloat {
        return UIScreen.superviewWidth - minViewHeight + bottomBuffer + 12
    }
    
    /// The maximum amount of x offset for the mediaView when minimizing
    private var maxViewOffsetX: CGFloat {
        return UIScreen.superviewWidth - minViewWidth - 12
    }
    
    private var minimizedFrame: CGRect {
        return CGRect(x: maxViewOffsetX, y: maxViewOffsetY, width: minViewWidth, height: minViewHeight)
    }
    
    /// Height constraint of the top overlay
    private lazy var topOverlayHeight: NSLayoutConstraint = {
        let height = 50 + (UIDevice.isLandscape ? 0 : topBuffer)
        let constraint = NSLayoutConstraint(item: track, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        
        return constraint
    }()
    
    /// Space between the titleLabel and the superview
    private lazy var titleTopOffset: CGFloat = {
        return 8.0 + topBuffer - (UIDevice.isLandscape ? topBuffer : 0)
    }()
    
    /// Constraint for the space between the titleLabel and the superview
    private lazy var titleTopOffsetConstraint: NSLayoutConstraint = {
        let offset = titleTopOffset + (detailsLabel.isEmpty ? 8.0 : 0)
        return NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: offset)
    }()
    
    /// Space between the detailsLabel and the superview
    private lazy var detailsTopOffset: NSLayoutConstraint = {
        let offset = titleTopOffset + 18
        return NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: offset)
    }()
    
    /// Play button imageView which shows in the center of the video or audio, notifies the user that a video or audio can be played
    private lazy var playIndicatorView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.center = center
        imageView.sizeToFit()
        imageView.alpha = 0
        
        return imageView
    }()
    
    /// Closes the mediaView when in fullscreen mode
    private var closeButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: 0, size: 50))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.close, for: .normal)
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        button.alpha = 0
        
        return button
    }()
    
    /// ABPlayer which will handle video playback
    private var player: Player?
    
    /// AVPlayerLayer which will display video
    private var playerLayer: AVPlayerLayer?
    
    /// Original superview for presenting mediaview
    private var originalSuperview: UIView?
    
    // MARK: - Gesture Properties
    
    /// Recognizer to record user swiping
    private lazy var swipeRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe), delegate: self)
        gesture.isEnabled = isFullScreen
        
        return gesture
    }()
    
    /// Recognizer to record a user swiping right to dismiss a minimize video
    private var dismissRecognizer: UIPanGestureRecognizer?
    
    /// Recognizer which keeps track of whether the user taps the view to play or pause the video
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapFromRecognizer), delegate: self)
    
    /// Recognizer for when the thumbnail experiences a long press
    private lazy var gifLongPressRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        gesture.minimumPressDuration = 0.25
        gesture.delegate = self
        gesture.delaysTouchesBegan = false
        gesture.require(toFail: tapRecognizer)
        
        return gesture
    }()
    
    // MARK: - Variable Properties
    /// Position of the swipe vertically
    private var swipePosition: CGPoint = .zero {
        didSet {
            xSwipePosition = swipePosition.x
            ySwipePosition = swipePosition.y
        }
    }
    
    /// Position of the swipe vertically
    private var ySwipePosition: CGFloat = 0.0
    
    /// Position of the swipe horizontally
    private var xSwipePosition: CGFloat = 0.0
    
    /// Variable tracking offset of video
    private var offset: CGFloat {
        return frame.origin.y
    }
    
    /// Number of seconds in the buffer
    private var bufferTime: CGFloat = 0.0
    
    /// Determines if the play has failed to play media
    private var didFailToPlayMedia: Bool = false
    
    /// Alpha level of the mediaViews border when it is not fullscreen
    private var borderAlpha: CGFloat = 0 {
        didSet {
            layer.borderColor = UIColor(rgb: 0x95a5a6).withAlphaComponent(borderAlpha).cgColor;
            layer.shadowOpacity = Float(borderAlpha);
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePlayerFrame()
        
        if hasMedia {
            track.updateSubviews()
        }
        
        let dividend = UIDevice.isPortrait ? frame.width : frame.height
        let playSize = 30 + (30 * (dividend / UIScreen.superviewWidth))
        
        playIndicatorView.frame.size = CGSize(playSize)
        playIndicatorView.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        closeButton.frame.origin = CGPoint(x: 0, y: 0 + (UIDevice.isPortrait ? 0 : topBuffer))
        closeButton.frame.size = CGSize(50)
    }
    
    // MARK: - Private Methods
    
    //    func copy(with zone: NSZone? = nil) -> Any {
    //        let copy = MediaView(
    //
    //    }
    
    private func commonInitializer() {
        isUserInteractionEnabled = true
        backgroundColor = UIColor(rgb: 0xEFEFF4)
        
        layer.borderWidth = 1.0
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.0
        layer.shadowRadius = 1.0
        
        if let contains = gestureRecognizers?.contains(swipeRecognizer), !contains {
            gestureRecognizers?.append(swipeRecognizer)
        }
        
        if let contains = gestureRecognizers?.contains(tapRecognizer), !contains {
            addGestureRecognizer(tapRecognizer)
        }
        
        if let contains = gestureRecognizers?.contains(gifLongPressRecognizer), !contains {
            addGestureRecognizer(gifLongPressRecognizer)
        }
        
        if !subviews.contains(topOverlay) {
            addSubview(topOverlay)
            
            updateTopOverlayHeight()
            topOverlay.addConstraint(topOverlayHeight)
            addConstraints([.trailing, .leading, .top], toView: topOverlay)
            topOverlay.layoutIfNeeded()
        }
        
        if !subviews.contains(closeButton) {
            addSubview(closeButton)
            bringSubview(toFront: closeButton)
        }
        
        if !subviews.contains(playIndicatorView) {
            addSubview(playIndicatorView)
            bringSubview(toFront: playIndicatorView)
        }
        
        if !subviews.contains(track) {
            addSubview(track)
            
            addConstraints([.trailing, .leading, .bottom], toView: track)
            addConstraint(NSLayoutConstraint(item: track, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60))
            track.layoutIfNeeded()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)), name: .mediaViewWillRotateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)), name: .mediaViewDidRotateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustSubviews), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustSubviews), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseVideoEnteringBackground), name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    /// Selector to play the video from the playRecognizer
    @objc private func handleTapFromRecognizer() {
        if isMinimized {
            isUserInteractionEnabled = false
            
            delegate?.willEndMinimizing(for: self, atMinimizedState: false)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
                self.setFullScreenView()
            }, completion: { _ in
                self.track.isUserInteractionEnabled = self.isMinimized
                self.isUserInteractionEnabled = true
                self.delegate?.didEndMinimizing(for: self, atMinimizedState: false)
            })
        } else {
            if shouldDisplayFullscreen && !isFullScreen {
                // FIXME: MediaQueue presentMediaView self.copy
            } else {
                if let player = player {
                    if player.isPlaying {
                        
                    } else if !isLoadingVideo {
                        
                    } else {
                        
                    }
                } else if !isLoadingVideo {
                    // FIXME: Load video with play: true
                } else {
                    stopVideoAnimate()
                }
            }
        }
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
        playerLayer?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height);
    }
    
    @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        guard isFullScreen else {
            return
        }
        
        switch gesture.state {
        case .began:
            stopVideoAnimate()
            
            track.isUserInteractionEnabled = false
            tapRecognizer.isEnabled = false
            closeButton.isUserInteractionEnabled = false
            
            track.hideTrackAndInvalidate()
            
            swipePosition = gesture.location(in: self)
        case .changed:
            switch swipeMode {
            case .dismiss:
                handleDismissal(using: gesture)
            case .minimize:
                if isMinimized {
                    if frame.origin.x > maxViewOffsetX {
                        handleMinimizedDismissal(using: gesture)
                    } else {
                        if gesture.velocity(in: self).isDownToTheRight {
                            handleMinimizedDismissal(using: gesture)
                        } else {
                            handleMinimization(using: gesture)
                        }
                    }
                } else {
                    handleMinimization(using: gesture)
                }
            default:
                break
            }
        case .cancelled, .failed, .ended:
            switch swipeMode {
            case .dismiss:
                isUserInteractionEnabled = false
                
                let velocity = gesture.velocity(in: self)
                let shouldDismiss = (offsetPercentage > 0.25 && offsetPercentage < 0.35 && velocity.y > 300) || offsetPercentage >= 0.35
                
                delegate?.willEndDismissing(for: self, withDismissal: shouldDismiss)
                
                if shouldDismiss {
                    // FIXME: dismissMediaViewAnimated
                    // inside ->
                    self.delegate?.didEndDismissing(for: self, withDismissal: true)
                } else {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.frame = UIScreen.rect
                        self.layoutSubviews()
                    }, completion: { _ in
                        self.setViewAfterSwipe()
                        
                        self.delegate?.didEndDismissing(for: self, withDismissal: false)
                    })
                }
            case .minimize:
                isUserInteractionEnabled = false
                
                if alpha < 0.6 {
                    // FIXME: dismissMediaViewAnimated
                } else {
                    let shouldMinimize = offsetPercentage >= 0.4
                    delegate?.willEndMinimizing(for: self, atMinimizedState: shouldMinimize)
                    
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
                        shouldMinimize ? self.setMinimizedView() : self.setFullScreenView()
                        
                        self.alpha = 1
                        self.layoutSubviews()
                    }, completion: { _ in
                        self.setViewAfterSwipe()
                        
                        self.delegate?.didEndMinimizing(for: self, atMinimizedState: shouldMinimize)
                        
                        if self.isLoadingVideo {
                            self.loadVideoAnimate()
                        }
                    })
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    private func handleDismissal(using gesture: UIPanGestureRecognizer) {
        guard isFullScreen else {
            return
        }
        
        delegate?.willChangeDismissing(for: self)
        
        let location = gesture.location(in: self)
        let difference = location.y - ySwipePosition
        let temporaryOffset = offset + difference
        offsetPercentage = temporaryOffset / UIScreen.superviewHeight
        
        delegate?.mediaView(self, didChangeOffset: offsetPercentage)
        
        borderAlpha = 0
        frame.size = CGSize(UIScreen.superviewWidth, UIScreen.superviewHeight)
        frame.origin.x = 0
        
        let testOrigin = offsetPercentage * UIScreen.superviewHeight
        
        switch testOrigin {
        case UIScreen.superviewHeight...:
            frame.origin.y = UIScreen.superviewHeight
        case ...0:
            frame.origin.y = 0
        default:
            frame.origin.y = testOrigin
        }
        
        layoutSubviews()
        delegate?.didChangeDismissing(for: self)
        swipePosition = location
    }
    
    private func handleMinimization(using gesture: UIPanGestureRecognizer) {
        guard isFullScreen else {
            return
        }
        
        delegate?.willChangeMinimization(for: self)
        
        let location = gesture.location(in: self)
        let difference = location.y - ySwipePosition
        let temporaryOffset = offset + difference
        offsetPercentage = temporaryOffset / maxViewOffsetY
        
        delegate?.mediaView(self, didChangeOffset: offsetPercentage)
        
        let testOrigin = offsetPercentage * maxViewOffsetY
        
        switch testOrigin {
        case maxViewOffsetY...:
            setMinimizedView()
        case ...0:
            setFullScreenView()
        default:
            frame.origin.y = testOrigin
            frame.size.width = UIScreen.superviewWidth - (offsetPercentage * (UIScreen.superviewWidth - minViewWidth))
            frame.size.height = UIScreen.superviewHeight - (offsetPercentage * (UIScreen.superviewHeight - minViewHeight))
            frame.origin.x = UIScreen.superviewWidth - frame.width - (offsetPercentage * 12)
            borderAlpha = offsetPercentage
            
            let offsetAlpha = 1 - offsetPercentage
            setPlayIndicatorView(alpha: offsetAlpha)
            
            closeButton.alpha = shouldHideCloseButton && swipeMode == .minimize && UIDevice.isPortrait ? 0 : 1
            let overlayAlpha = isPlayingVideo || titleLabel.isEmpty ? 0 : offsetAlpha
            setTopOverlayAlpha(overlayAlpha)
        }
        
        layoutSubviews()
        delegate?.didChangeMinimization(for: self)
        swipePosition = location
    }
    
    private func handleMinimizedDismissal(using gesture: UIPanGestureRecognizer) {
        guard isFullScreen else {
            return
        }
        
        let location = gesture.location(in: self)
        let difference = location.x - xSwipePosition
        let temporaryOffset = frame.origin.x + difference
        let offsetRatio = (temporaryOffset - maxViewOffsetX) / (minViewWidth - 12)
        
        switch offsetRatio {
        case 1...:
            frame.origin = CGPoint(UIScreen.superviewWidth, maxViewOffsetY)
            alpha = 0
        case ..<0:
            frame.origin = CGPoint(maxViewOffsetX, maxViewOffsetY)
            alpha = 1
        default:
            frame.origin.x += difference
            frame.origin.y = maxViewOffsetY
            alpha = 1 - offsetRatio
        }
        
        layoutSubviews()
        swipePosition = location
    }
    
    private func setMinimizedView() {
        frame = minimizedFrame
        playIndicatorView.alpha = 0
        closeButton.alpha = 0
        setTopOverlayAlpha(0)
        borderAlpha = 1.0
    }
    
    private func setFullScreenView() {
        frame = UIScreen.rect
        layer.cornerRadius = 0
        borderAlpha = 0
        
        setPlayIndicatorView()
        handleCloseButtonDisplay()
        handleTopOverlayDisplay()
    }
    
    private func setPlayIndicatorView(alpha: CGFloat = 1) {
        if hasMedia && (!isPlayingVideo || isLoadingVideo) {
            playIndicatorView.alpha = 1
        }
    }
    
    private func setViewAfterSwipe() {
        tapRecognizer.isEnabled = true
        closeButton.isUserInteractionEnabled = true
        track.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
    }
    
    @objc private func handleLongPress() {
        
    }
    
    @objc private func closeAction() {
        if isFullScreen {
            // FIXME: dismissMediaViewAnimated
        } else {
            closeButton.alpha = 0
        }
    }
    
    @objc private func orientationChanged(_ notification: Notification) {
        // When rotation is enabled, then the positioning of the imageview which holds the AVPlayerLayer must be adjusted to accomodate this change.
        adjustSubviews()
        
        if isFullScreen {
            isUserInteractionEnabled = true
            track.isUserInteractionEnabled = true
            
            setPlayIndicatorView()
            handleCloseButtonDisplay()
            handleTopOverlayDisplay()
            
            if isLoadingVideo {
                stopVideoAnimate()
                loadVideoAnimate()
            }
        }
        
        updatePlayerFrame()
        updateTitleLabelOffsets()
        updateDetailsLabelOffsets()
        updateTopOverlayHeight()
        
        if hasMedia {
            track.updateSubviews()
        }
        
        layoutIfNeeded()
    }
    
    func updateTitleLabelOffsets() {
        if titleLabel.constraints.contains(titleTopOffsetConstraint) {
            layoutIfNeeded()
            titleTopOffsetConstraint.constant = titleTopOffset + (detailsLabel.isEmpty ? 8.0 : 0)
            layoutIfNeeded()
        }
    }
    
    func updateDetailsLabelOffsets() {
        if !detailsLabel.isEmpty, detailsLabel.constraints.contains(detailsTopOffset) {
            layoutIfNeeded()
            detailsTopOffset.constant = titleTopOffset + 18.0
            layoutIfNeeded()
        }
    }
    
    @objc private func adjustSubviews() {
        if isFullScreen {
            swipeRecognizer.isEnabled = UIDevice.isPortrait && swipeMode.movesWhenSwipe
            layer.cornerRadius = 0.0
            borderAlpha = 0.0
            frame = CGRect(x: 0, y: 0, width: UIScreen.superviewWidth, height: UIScreen.superviewHeight)
        }
        
        layoutSubviews()
    }
    
    @objc private func pauseVideoEnteringBackground() {
        if hasMedia, let player = player, player.isPlaying {
            stopVideoAnimate()
            isLoadingVideo = false
            
            UIView.animate(withDuration: 0.15, animations: {() -> Void in
                self.playIndicatorView.alpha = 1.0
            })
            
            player.pause()
            handleTopOverlayDisplay()
            delegate?.didPauseVideo(for: self)
        }
    }
    
    func handleCloseButtonDisplay() {
        closeButton.alpha = (isFullScreen && !shouldHideCloseButton && swipeMode != .minimize && UIDevice.isLandscape) ? 1 : 0
    }
    
    func handleTopOverlayDisplay() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
            let missingTopOverlayContent = self.titleLabel.isEmpty || self.isPlayingVideo
            let isVisible = !missingTopOverlayContent && self.isFullScreen
            let alphaLevel: CGFloat = isVisible ? 1 : 0
            
            self.setTopOverlayAlpha(alphaLevel)
        })
    }
    
    private func setTopOverlayAlpha(_ alphaLevel: CGFloat) {
        topOverlay.alpha = alphaLevel
        titleLabel.alpha = alphaLevel
        detailsLabel.alpha = alphaLevel
    }
    
    private func updateTopOverlayHeight() {
        self.layoutIfNeeded()
        topOverlayHeight.constant = 50 + (UIDevice.isLandscape ? 0 : topBuffer)
        self.layoutIfNeeded()
    }
    
    /// Mark: - Initializers
    private init(mediaView: MediaView) {
        super.init(frame: .zero)
        commonInitializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitializer()
    }
    
    // MARK: - LabelDelegate
    func didTouchUpInside(label: Label) {
        
    }
    
    // MARK: - TrackViewDelegate
    func seekTo(time: TimeInterval, track: TrackView) {
        
    }
}
