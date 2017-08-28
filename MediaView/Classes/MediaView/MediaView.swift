//
//  MediaView.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/24/17.
//

import Foundation
import AVFoundation

class MediaView: UIImageView, UIGestureRecognizerDelegate, LabelDelegate, TrackViewDelegate, PlayerDelegate {
    
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
            offsetPercentage.clamp(lower: 0, upper: 1)
        }
    }
    
    /// Determines whether the content's original size is full screen. If you are looking to make it so that when a mediaView is selected from another view, that it opens up in full screen, then set the property 'shouldDisplayFullScreen'
    private(set) public var isFullScreen = false {
        didSet {
            swipeRecognizer.isEnabled = swipeMode.movesWhenSwipe && isFullScreen
        }
    }
    
    /// Determines if the video is already loading
    public var isLoadingVideo: Bool {
        guard let player = player else {
            return false
        }
        
        return !player.isPlaying
    }
    
    /// Media which is displayed in the view
    var media = Media()
    
    // MARK: - Interface properties
    
    /// Track which shows the progress of the video being played
    internal lazy var track: TrackView = {
        let track = TrackView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60.0))
        track.translatesAutoresizingMaskIntoConstraints = false
        track.themeColor = themeColor
        track.delegate = self
        track.isHidden = !shouldShowTrack
        
        tapRecognizer.require(toFail: track.scrubRecognizer)
        tapRecognizer.require(toFail: track.tapRecognizer)
        
        swipeRecognizer.require(toFail: track.scrubRecognizer)
        swipeRecognizer.require(toFail: track.tapRecognizer)
        
        return track
    }()
    
    /// Gradient dark overlay on top of the mediaView which UI can be placed on top of
    private var topOverlay: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.superviewHeight, height: 80))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.topOverlay(frame: imageView.bounds)
        imageView.alpha = 0
        
        return imageView
    }()
    
    /// Label at the top of the mediaView, displayed within the topOverlay. Designated for a title, but other text can be inserted
    private lazy var titleLabel = Label(width: topOverlay.frame.width, delegate: self, kind: .title)
    
    /// Label at the top of the mediaView, displayed within the topOverlay. Designated for details
    private lazy var detailsLabel = Label(width: topOverlay.frame.width, delegate: self, kind: .description)
    
    // MARK: - Customizable Properties
    /// If all media is sourced from the same location, then the ABCacheManager will search the Directory for files with the same name when getting cached objects, since they all have the same remote location
    var isAllMediaFromSameLocation = false
    
    /// Download video and audio before playing (default: false)
    var shouldPreloadPlayableMedia = false
    
    /// Automate caching for media (default: false)
    var shouldCacheMedia = false
    
    /// Theme color which will show on the play button and progress track for videos (default: UIColor.cyan)
    var themeColor = UIColor.cyan {
        didSet {
            track.themeColor = themeColor
            playIndicatorView.image = playIndicatorImage
        }
    }
    
    /// Determines whether the video playerLayer should be set to aspect fit mode (default: false)
    var videoAspectFit = false {
        didSet {
            playerLayer?.videoGravity = videoGravity
        }
    }
    
    /// Determines whether the progress track should be shown for video (default: false)
    var shouldShowTrack = false {
        didSet {
            track.isHidden = !shouldShowTrack
        }
    }
    
    /// Determines if the video should be looped when it reaches completion (default: false)
    var allowLooping = false
    
    /// Determines whether or not the mediaView is being used in a reusable view (default: false)
    var imageViewNotReused = false
    
    /// Determines what action will be taken when user swipes on fullscreen mediaView (default: .none)
    var swipeMode: SwipeMode = .none {
        didSet {
            swipeRecognizer.isEnabled = UIScreen.isPortrait && swipeMode.movesWhenSwipe
        }
    }
    
    /// Determines whether the video occupies the full screen when displayed (default: false)
    var shouldDisplayFullscreen = false
    
    /// Toggle functionality for remaining time to show on right track label rather than showing total time (default: false)
    var shouldDisplayRemainingTime = false {
        didSet {
            track.showTimeRemaining = shouldDisplayRemainingTime
        }
    }
    
    /// Toggle functionality for hiding the close button from the fullscreen view. If minimizing is disabled, this functionality is not allowed. (default: false)
    var shouldHideCloseButton = false {
        didSet {
            handleCloseButtonDisplay()
        }
    }
    
    /// Toggle functionality to not have a play button visible (default: false)
    var shouldHidePlayButton = false {
        didSet {
            guard hasPlayableMedia, let player = player, !(shouldHidePlayButton && playIndicatorView.alpha != 0) else {
                playIndicatorView.alpha = 0
                return
            }
            
            if isLoadingVideo {
                loadVideoAnimate()
            } else {
                playIndicatorView.alpha = (!player.isPlaying || player.didFailToPlay) ? 1 : 0
            }
        }
    }
    
    /// Toggle functionality to have the mediaView autoplay the video associated with it after presentation (default: true)
    var shouldAutoPlayAfterPresentation = true
    
    /// Custom image can be set for the play button (video)
    var customPlayButton: UIImage? {
        didSet {
            playIndicatorView.image = playIndicatorImage
        }
    }
    
    /// Custom image can be set for the play button (music)
    var customMusicButton: UIImage? {
        didSet {
            playIndicatorView.image = playIndicatorImage
        }
    }
    
    /// Custom image can be set for when media fails to play
    var customFailButton: UIImage? {
        didSet {
            playIndicatorView.image = playIndicatorImage
        }
    }
    
    private var playIndicatorImage: UIImage? {
        if shouldHidePlayButton {
            return nil
        } else if let player = player, player.didFailToPlay {
            return customFailButton ?? UIImage.failIndicator(themeColor: themeColor, isFullScreen: isFullScreen, pressShowsGIF: pressShowsGIF)
        } else if let playButton = customPlayButton, media.hasVideo {
            return playButton
        } else if let musicButton = customMusicButton, media.hasAudio {
            return musicButton
        } else {
            return UIImage.playIndicator(themeColor: themeColor)
        }
    }
    
    /// Timer for animating the playIndicatorView, to show that the video is loading
    private var animateTimer = Timer()
    
    /// Setting this value to true will allow you to have the fullscreen popup originate from the frame of the original view, without having to set the originRect yourself (default: false)
    var shouldPresentFromOriginRect = false
    
    /// Rect that specifies where the mediaView's frame will originate from when presenting, and needs to be converted into its position in the mainWindow
    var originRect: CGRect?
    
    /// Rect that specifies where the mediaView's frame will originate from when presenting, and is already converted into its position in the mainWindow
    var originRectConverted: CGRect?
    
    /// Change font for track labels (default: System font of size 14)
    var trackFont: UIFont = .systemFont(ofSize: 14) {
        didSet {
            track.trackFont = trackFont
        }
    }
    
    /// By default, there is a buffer of 12px on the bottom of the view, and more space can be added by adjusting this bottom buffer. This is useful in order to have the mediaView show above UITabBars, UIToolbars, and other views that need reserved space on the bottom of the screen.
    var bottomBuffer: CGFloat = 0.0 {
        didSet {
            bottomBuffer.clamp(lower: 0, upper: 120)
        }
    }
    
    /// Ratio that the minimized view will be shruken to, can be set to a custom value or one of the available ABMediaViewRatioPresets. (Height/Width)
    var minimizedAspectRatio: CGFloat = .landscapeRatio {
        didSet {
            minimizedAspectRatio.clamp(lower: .landscapeRatio, upper: .portraitRatio)
        }
    }
    
    /// Ratio of the screen's width that the mediaView's minimized view will stretch across.
    var minimizedWidthRatio: CGFloat = 0.5 {
        didSet {
            let maxWidthRatio = (UIScreen.superviewWidth - 24.0) / UIScreen.superviewWidth
            minimizedWidthRatio.clamp(lower: 0.25, upper: maxWidthRatio)
        }
    }
    
    /// Ability to offset the subviews at the top of the screen to avoid hiding other views (ie. UIStatusBar)
    var topBuffer: CGFloat = 0.0 {
        didSet {
            topBuffer.clamp(lower: 0, upper: 64)
            
            updateTopOverlayHeight()
            updateTitleLabelOffsets()
            updateDetailsLabelOffsets()
            layoutSubviews()
        }
    }
    
    /// Determines whether the view has a video
    var hasVideo: Bool {
        return media.hasVideo
    }
    
    /// Determines whether the view has a audio
    var hasAudio: Bool {
        return media.hasAudio
    }
    
    /// Determines whether the view has media (video or audio)
    var hasPlayableMedia: Bool {
        return media.hasPlayableMedia
    }
    
    /// Determines whether the view is already playing video
    private var isPlayingVideo: Bool {
        return player?.isPlaying ?? false || isLoadingVideo
    }
    
    /// Determines whether the user can press and hold the image thumbnail for GIF
    var pressShowsGIF = false
    
    /// Determines whether user is long pressing thumbnail
    internal var isLongPressing = false
    
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
    
    var minimizedFrame: CGRect {
        return CGRect(x: maxViewOffsetX, y: maxViewOffsetY, width: minViewWidth, height: minViewHeight)
    }
    
    /// Height constraint of the top overlay
    private lazy var topOverlayHeight: NSLayoutConstraint = {
        let height = 50 + (UIScreen.isLandscape ? 0 : topBuffer)
        let constraint = NSLayoutConstraint(item: track, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        
        return constraint
    }()
    
    /// Space between the titleLabel and the superview
    private lazy var titleTopOffset: CGFloat = {
        return 8.0 + topBuffer - (UIScreen.isLandscape ? topBuffer : 0)
    }()
    
    /// Constraint for the space between the titleLabel and the superview
    private lazy var titleTopOffsetConstraint: NSLayoutConstraint = {
        let offset = titleTopOffset + (detailsLabel.isEmpty ? 8.0 : 0)
        return NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: offset)
    }()
    
    /// Space between the detailsLabel and the superview
    private lazy var detailsTopOffsetConstraint: NSLayoutConstraint = {
        let offset = titleTopOffset + 18
        return NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: offset)
    }()
    
    /// Play button imageView which shows in the center of the video or audio, notifies the user that a video or audio can be played
    private lazy var playIndicatorView: UIImageView = {
        let imageView = UIImageView(image: playIndicatorImage)
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
    private var swipePosition: CGPoint = .zero
    
    /// Variable tracking offset of video
    private var offset: CGFloat {
        return frame.origin.y
    }
    
    /// Number of seconds in the buffer
    private var bufferTime: CGFloat = 0.0
    
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
        
        if hasPlayableMedia {
            track.updateSubviews()
        }
        
        let dividend = UIScreen.isPortrait ? frame.width : frame.height
        let playSize = 30 + (30 * (dividend / UIScreen.superviewWidth))
        
        playIndicatorView.frame.size = CGSize(playSize)
        playIndicatorView.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        closeButton.frame.origin = CGPoint(x: 0, y: 0 + (UIScreen.isPortrait ? 0 : topBuffer))
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
    @objc func handleTapFromRecognizer() {
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
                        player.pause()
                    } else if !isLoadingVideo {
                        stopVideoAnimate()
                        hidePlayIndicator()
                        player.play()
                    } else {
                        loadVideoAnimate()
                        player.play()
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
        stopVideoAnimate()
        
        if let player = player, player.didFailToPlay {
            playIndicatorView.alpha = 1
            playIndicatorView.image = playIndicatorImage
        } else {
            animateVideo()
            animateTimer = Timer.scheduledTimer(timeInterval: 0.751, target: self, selector: #selector(animateVideo), userInfo: nil, repeats: true)
        }
    }
    
    /// Stop video loading animation
    private func stopVideoAnimate() {
        animateTimer.invalidate()
    }
    
    /// Update the frame of the playerLayer
    private func updatePlayerFrame() {
        playerLayer?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height);
    }
    
    /// Animate the video indicator
    @objc private func animateVideo() {
        if hasPlayableMedia && !isLoadingVideo {
            let updatedAlpha: CGFloat = playIndicatorView.alpha == 1 ? 0.4 : 1
            
            UIView.animate(withDuration: 0.75, animations: {
                self.playIndicatorView.alpha = updatedAlpha
            })
        } else {
            playIndicatorView.alpha = (player?.didFailToPlay ?? false) ? 1 : 0
        }
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
                    // Inside ->
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
        let difference = location.y - swipePosition.y
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
        let difference = location.y - swipePosition.y
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
            
            closeButton.alpha = shouldHideCloseButton && swipeMode == .minimize && UIScreen.isPortrait ? 0 : 1
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
        let difference = location.x - swipePosition.x
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
    
    internal func setPlayIndicatorView(alpha: CGFloat = 1) {
        if hasPlayableMedia && (!isPlayingVideo || isLoadingVideo) {
            if !(shouldHidePlayButton && alpha != 0) {
                playIndicatorView.image = playIndicatorImage
                playIndicatorView.alpha = alpha
            }
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
        
        if hasPlayableMedia {
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
        if !detailsLabel.isEmpty, detailsLabel.constraints.contains(detailsTopOffsetConstraint) {
            layoutIfNeeded()
            detailsTopOffsetConstraint.constant = titleTopOffset + 18.0
            layoutIfNeeded()
        }
    }
    
    @objc private func adjustSubviews() {
        if isFullScreen {
            swipeRecognizer.isEnabled = UIScreen.isPortrait && swipeMode.movesWhenSwipe
            layer.cornerRadius = 0.0
            borderAlpha = 0.0
            frame = CGRect(x: 0, y: 0, width: UIScreen.superviewWidth, height: UIScreen.superviewHeight)
        }
        
        layoutSubviews()
    }
    
    @objc private func pauseVideoEnteringBackground() {
        if hasPlayableMedia, let player = player, player.isPlaying {
            player.pause()
        }
    }
    
    internal func prepForPresentation() {
        delegate?.willPresent(mediaView: self)
        isFullScreen = true
        handleCloseButtonDisplay()
        
        backgroundColor = .black
        
        if let originRect = originRect, originRectConverted != nil {
            if let originalSuperview = originalSuperview {
                originRectConverted = originalSuperview.convert(originRect, to: UIWindow.main)
            } else {
                originRectConverted = convert(originRect, to: UIWindow.main)
            }
        }
        
        closeButton.alpha = 0
        setTopOverlayAlpha(0)
        
        frame = originRectConverted ?? UIWindow.main.frame
        alpha = originRectConverted == nil ? 0 : 1
    }
    
    func handleCloseButtonDisplay() {
        closeButton.alpha = (isFullScreen && !shouldHideCloseButton && swipeMode != .minimize && UIScreen.isLandscape) ? 1 : 0
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
        topOverlayHeight.constant = 50 + (UIScreen.isLandscape ? 0 : topBuffer)
        self.layoutIfNeeded()
    }
    
    private func hidePlayIndicator(animated: Bool = false) {
        if let player = player, player.didFailToPlay {
            playIndicatorView.alpha = 1
        } else {
            UIView.animate(withDuration: animated ? 0.15 : 0 , animations: {
                self.playIndicatorView.alpha = 0
            })
        }
    }
    
    private var videoGravity: AVLayerVideoGravity {
        return videoAspectFit || contentMode == .scaleAspectFit ? .resizeAspect : .resizeAspectFill
    }
    
    public func setTitle(_ title: String, details: String? = nil) {
        titleLabel.removeFromSuperview()
        detailsLabel.removeFromSuperview()
        
        if titleLabel.constraints.contains(titleTopOffsetConstraint) {
            titleLabel.removeConstraint(titleTopOffsetConstraint)
        }
        
        if detailsLabel.constraints.contains(detailsTopOffsetConstraint) {
            detailsLabel.removeConstraint(detailsTopOffsetConstraint)
        }
        
        titleLabel.text = title
        detailsLabel.text = details
        
        guard !titleLabel.isEmpty else {
            return
        }
        
        if !subviews.contains(titleLabel) {
            addConstraints([.trailing, .leading], toView: titleLabel, constant: 50)
            addConstraint(titleTopOffsetConstraint)
            updateTitleLabelOffsets()
            titleLabel.addConstraints([.height], toView: titleLabel, constant: 18)
        }
        
        guard !detailsLabel.isEmpty, !subviews.contains(detailsLabel) else {
            return
        }
        
        addConstraints([.trailing, .leading], toView: detailsLabel, constant: 50)
        addConstraint(detailsTopOffsetConstraint)
        updateDetailsLabelOffsets()
        detailsLabel.addConstraints([.height], toView: detailsLabel, constant: 18)
    }
    
    // MARK: - Static
    // FIXME: Clear MediaView Directory
    
    static var audioTypeWhenPlay: VolumeManager.AudioType {
        get { return VolumeManager.shared.audioTypeWhenPlay }
        set { VolumeManager.shared.audioTypeWhenPlay = newValue }
    }
    
    static var audioTypeWhenStop: VolumeManager.AudioType {
        get { return VolumeManager.shared.audioTypeWhenStop }
        set { VolumeManager.shared.audioTypeWhenStop = newValue }
    }
    
    // MARK: Reset
    public func resetMedia() {
        media = Media()
        
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        image = nil
        
        bufferTime = 0
        playIndicatorView.alpha = 0
        closeButton.alpha = 0
        setTopOverlayAlpha(0)
        
        stopVideoAnimate()
    }
    
    public func reset() {
        delegate = nil
        shouldAutoPlayAfterPresentation = false
        shouldHideCloseButton = false
        shouldHidePlayButton = false
        shouldDisplayFullscreen = false
        allowLooping = false
        shouldShowTrack = false
        shouldDisplayRemainingTime = false
        
        resetMedia()
    }
    
    // MARK: - Initializers
    private init(mediaView: MediaView) {
        super.init(frame: .zero)
        commonInitializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitializer()
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    // MARK: - LabelDelegate
    func didTouchUpInside(label: Label) {
        switch label.tag {
        case 1000:
            delegate?.handleTitleSelection(in: self)
        case 2000:
            delegate?.handleDetailsSelection(in: self)
        default:
            break
        }
    }
    
    // MARK: - TrackViewDelegate
    func seekTo(time: TimeInterval, track: TrackView) {
        guard let player = player, let timeScale = player.currentItem?.asset.duration.timescale else {
            return
        }
        
        let timeCM = CMTimeMakeWithSeconds(time, timeScale)
        player.seek(to: timeCM, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    // MARK: - PlayerDelegate
    func didPlay(player: Player) {
        handleTopOverlayDisplay()
        
        if !player.didFailToPlay {
            delegate?.didPlayVideo(for: self)
        }
    }
    
    func didPause(player: Player) {
        stopVideoAnimate()
        setPlayIndicatorView(alpha: 1)
        handleTopOverlayDisplay()
        
        delegate?.didPauseVideo(for: self)
    }
}
