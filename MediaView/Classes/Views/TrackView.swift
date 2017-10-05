//
//  TrackView.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation

protocol TrackViewDelegate: class {
    
    func seekTo(time: TimeInterval, track: TrackView)
}

class TrackView: UIView, UIGestureRecognizerDelegate {
    
    weak var delegate: TrackViewDelegate?
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(handleTapRecognizer(_:)),
                                             delegate: self)
        return gesture
    }()
    
    lazy var scrubRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(handlePanRecognizer(_:)),
                                             delegate: self)
        return gesture
    }()
    
    /// Color for the progress bar
    var themeColor: UIColor {
        get { return progressView.backgroundColor ?? .cyan }
        set { progressView.backgroundColor = newValue }
    }
    
    /// Font used in the track's time labels
    var trackFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            currentTimeLabel.font = trackFont
            totalTimeLabel.font = trackFont
        }
    }
    
    /// Amount of time that has been loaded for the media
    var buffer: TimeInterval = 0.0 {
        didSet {
            guard buffer >= 0 else {
                return
            }
            
            updateBufferView()
        }
    }
    
    /// Amount of time which has elapsed for the media
    var progress: TimeInterval = 0.0 {
        didSet {
            guard progress >= 0 else {
                return
            }
            
            updateProgressView()
        }
    }
    
    /// Total duration for the media
    var duration: TimeInterval = 15.0 {
        didSet {
            guard duration >= 0 else {
                return
            }
            
            updateTotalTimeLabel()
        }
    }
    
    /// Determines whether the right track label should show total time or time remaining
    var showTimeRemaining = false {
        didSet {
            updateTotalTimeLabel()
        }
    }
    
    private var barHeight: CGFloat = 2.0
    private var canSeek = false
    private var hideTimer = Timer()
    
    private var currentTimeLabel = Label()
    private var totalTimeLabel = Label(alignment: .right)
    
    private var trackRectEmpty: CGRect {
        return CGRect(width: 0, height: barHeight)
    }
    
    private var trackRectFull: CGRect {
        return CGRect(width: frame.width, height: barHeight)
    }
    
    private lazy var barBackgroundView: UIView = {
        let barBackgroundView = UIView(frame: trackRectFull)
        barBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        barBackgroundView.layer.masksToBounds = false
        barBackgroundView.layer.shadowColor = UIColor.black.cgColor
        barBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        barBackgroundView.layer.shadowOpacity = 0.8
        barBackgroundView.layer.shadowRadius = 4.0
        
        return barBackgroundView
    }()
    
    private lazy var bufferView: UIView = {
        let bufferView = UIView(frame: trackRectEmpty)
        bufferView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        return bufferView
    }()
    
    private lazy var progressView: UIView = {
        let progressView = UIView(frame: trackRectEmpty)
        progressView.backgroundColor = .cyan
        
        return progressView
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInitialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInitialization()
    }
    
    private func commonInitialization() {
        let timeStackView = UIStackView(frame: CGRect(width: frame.width, height: 20),
                                        axis: .horizontal,
                                        distribution: .fillEqually,
                                        subviews: [currentTimeLabel, totalTimeLabel])
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: 30, width: frame.width, height: 30),
                                    spacing: 4,
                                    subviews: [timeStackView, barBackgroundView])
        
        barBackgroundView.addConstraints([.height], toView: barBackgroundView, constant: barHeight)
        
        addSubview(stackView)
        addConstraints([.leading, .trailing, .bottom, .top], toView: stackView)
        
        barBackgroundView.addSubview(bufferView)
        barBackgroundView.addSubview(progressView)
        addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(scrubRecognizer)
    }
    
    // MARK: - Gestures
    @objc private func handleTapRecognizer(_ gesture: UIGestureRecognizer) {
        touchRegistered(gesture: gesture)
        scheduleTimer()
    }
    
    @objc private func handlePanRecognizer(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            touchRegistered(gesture: gesture)
        case .changed:
            guard barBackgroundView.frame.height >= 6.0 else {
                return
            }
            
            seek(to: gesture.location(in: self).x)
        case .cancelled, .ended, .failed:
            hideTimer.invalidate()
            scheduleTimer()
        default:
            break
        }
    }
    
    private func touchRegistered(gesture: UIGestureRecognizer) {
        if barBackgroundView.frame.height >= 6.0 {
            seek(to: gesture.location(in: self).x)
        } else {
            setTrackHidden(false)
        }
        
        hideTimer.invalidate()
    }
    
    // MARK: - Public
    func setProgress(_ progress: TimeInterval, duration: TimeInterval) {
        self.progress = progress
        self.duration = duration
    }
    
    func setBuffer(_ buffer: TimeInterval, duration: TimeInterval) {
        self.buffer = buffer
        self.duration = duration
    }
    
    func updateSubviews() {
        updateBarBackground()
        updateProgressView()
        updateBufferView()
    }
    
    func hideTrackAndInvalidate() {
        hideTimer.invalidate()
        setTrackHidden()
    }
    
    func reset() {
        setBuffer(0, duration: 0)
        setProgress(0, duration: 0)
    }
    
    // MARK: - Private
    private func updateTotalTimeLabel() {
        if !showTimeRemaining || duration < progress {
            totalTimeLabel.text = duration.timeString
        } else {
            totalTimeLabel.text = (duration - progress).timeString
        }
    }
    
    private func updateBarBackground() {
        guard let constraint = (barBackgroundView.constraints.first { $0.firstAttribute == .height }) else {
            return
        }
        
        layoutIfNeeded()
        constraint.constant = self.barHeight
        UIView.animate(withDuration: 0.1, animations: {
            self.layoutIfNeeded()
        })
    }
    
    private func updateBufferView() {
        var animationDuration = 0.0
        var bufferFrame = trackRectEmpty
        
        if buffer > 0 && (duration - 0.5) > 0 {
            let elapsedTime = buffer / (duration - 0.5)
            let width = elapsedTime.float * frame.width
            bufferFrame.size.width = width
            animationDuration = 0.1
        }
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.bufferView.frame = bufferFrame
        })
    }
    
    private func updateProgressView() {
        var animationDuration = 0.0
        var progressFrame = trackRectEmpty
        
        if progress > 0 && (duration - 0.5) > 0 {
            let elapsedTime = progress / (duration - 0.5)
            let width = elapsedTime.float * frame.width
            progressFrame.size.width = width
            animationDuration = 0.1
        }
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.progressView.frame = progressFrame
        })
        
        currentTimeLabel.text = progress.timeString
        updateTotalTimeLabel()
    }
    
    private func seek(to point: CGFloat) {
        if canSeek, point < barBackgroundView.frame.width {
            let ratio = point / barBackgroundView.frame.width
            let seekTime = ratio.time * duration
            
            delegate?.seekTo(time: seekTime, track: self)
        }
    }
    
    private func scheduleTimer() {
        if #available(iOS 10, *) {
            hideTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                self.setTrackHidden(true)
            })
        } else {
            hideTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(setTrackHidden(_:)), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func setTrackHidden(_ isHidden: Bool = true) {
        barHeight = isHidden ? 2 : 6
        canSeek = !isHidden
        
        UIView.animate(withDuration: isHidden ? 0.4 : 0.2, animations: {
            self.currentTimeLabel.alpha = isHidden ? 0 : 1
            self.totalTimeLabel.alpha = isHidden ? 0 : 1
            self.updateBufferView()
            self.updateProgressView()
            self.updateBarBackground()
        }) { _ in
            if !isHidden {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.canSeek = self.barHeight == 6
                })
            }
        }
    }
}
