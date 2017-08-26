//
//  TrackView.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation

protocol TrackViewDelegate: class {
    
    func seekTo(time: CGFloat, track: TrackView)
}

class TrackView: UIView, UIGestureRecognizerDelegate {
    
    weak var delegate: TrackViewDelegate?
    
    private var barHeight: CGFloat = 2.0
    private var canSeek = false
    private var hideTimer = Timer()
    lazy var trackRect = CGRect(x: 0, y: frame.height - barHeight, width: 0, height: barHeight)
    
    var trackFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            currentTimeLabel.font = trackFont
            totalTimeLabel.font = trackFont
        }
    }
    
    var buffer: CGFloat = 0.0 {
        didSet {
            guard buffer >= 0 else {
                return
            }
            
            updateBufferView()
        }
    }
    
    var progress: CGFloat = 0.0 {
        didSet {
            guard progress >= 0 else {
                return
            }
            
            updateProgressView()
        }
    }
    
    var duration: CGFloat = 15.0 {
        didSet {
            guard duration >= 0 else {
                return
            }
            
            updateTotalTimeLabel()
        }
    }
    
    var showTimeRemaining = false {
        didSet {
            updateTotalTimeLabel()
        }
    }
    
    lazy var barBackgroundView: UIView = {
        let barBackgroundView = UIView(frame: CGRect(x: 0, y: frame.height - barHeight, width: frame.width, height: barHeight))
        barBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        barBackgroundView.layer.masksToBounds = false
        barBackgroundView.layer.shadowColor = UIColor.black.cgColor
        barBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        barBackgroundView.layer.shadowOpacity = 0.8
        barBackgroundView.layer.shadowRadius = 4.0
        
        return barBackgroundView
    }()
    
    lazy var bufferView: UIView = {
        let bufferView = UIView(frame: CGRect(x: 0, y: frame.height - barHeight, width: 0, height: barHeight))
        bufferView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        return bufferView
    }()
    
    lazy var progressView: UIView = {
        let progressView = UIView(frame: CGRect(x: 0, y: frame.height - barHeight, width: 0, height: barHeight))
        progressView.backgroundColor = UIColor.cyan
        
        return progressView
    }()
    
    lazy var currentTimeLabel: Label = Label(y: self.frame.height - self.barHeight - 14)
    
    lazy var totalTimeLabel: Label = {
        let label = Label(y: self.frame.height - self.barHeight - 14)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapRecognizer(_:)), delegate: self)
    private lazy var scrubRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanRecognizer(_:)), delegate: self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInitialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInitialization()
    }
    
    private func commonInitialization() {
        addSubview(barBackgroundView)
        addSubview(bufferView)
        addSubview(progressView)
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)
        addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(scrubRecognizer)
    }
    
    @objc private func handleTapRecognizer(_ gesture: UIGestureRecognizer) {
        touchRegistered(gesture: gesture)
    }
    
    @objc private func handlePanRecognizer(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            touchRegistered(gesture: gesture)
        case .changed:
            if barBackgroundView.frame.height >= 6.0 {
                seek(to: gesture.location(in: self).y)
            }
            
            hideTimer.invalidate()
        case .cancelled, .ended, .failed:
            hideTimer.invalidate()
            scheduleTimer()
        default:
            break
        }
    }
    
    func setProgress(_ progress: CGFloat, duration: CGFloat) {
        self.progress = progress
        self.duration = duration
    }
    
    func setBuffer(_ buffer: CGFloat, duration: CGFloat) {
        self.buffer = buffer
        self.duration = duration
    }
    
    private func updateTotalTimeLabel() {
        if !showTimeRemaining || duration < progress {
            totalTimeLabel.text = duration.getTimeString()
        } else {
            totalTimeLabel.text = (duration - progress).getTimeString()
        }
    }
    
    private func updateBarBackground() {
        UIView.animate(withDuration: 0.1, animations: {
            self.barBackgroundView.frame = CGRect(x: 0, y: self.frame.height - self.barHeight, width: self.frame.width, height: self.barHeight)
            self.currentTimeLabel.frame = CGRect(x: 8, y: self.frame.height - self.barHeight - 20.0, width: 120.0, height: 20.0)
            self.totalTimeLabel.frame = CGRect(x: self.frame.width - 128, y: self.frame.height - self.barHeight - 20.0, width: 120.0, height: 20.0)
        })
    }
    
    private func updateBufferView() {
        var animationDuration = 0.0
        var bufferFrame = trackRect
        
        if buffer > 0 && (duration - 0.5) > 0 {
            let elapsedTime = buffer / (duration - 0.5)
            let width = elapsedTime * frame.width
            bufferFrame.size.width = width
            animationDuration = 0.1
        }
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.bufferView.frame = bufferFrame
        })
    }
    
    private func updateProgressView() {
        var animationDuration = 0.0
        var progressFrame = trackRect
        
        if progress > 0 && (duration - 0.5) > 0 {
            let elapsedTime = progress / (duration - 0.5)
            let width = elapsedTime * frame.width
            progressFrame.size.width = width
            animationDuration = 0.1
        }
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.progressView.frame = progressFrame
        })
        
        currentTimeLabel.text = progress.getTimeString()
        updateTotalTimeLabel()
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
    
    func seek(to point: CGFloat) {
        if canSeek, point < bufferView.frame.width {
            let ratio = point / bufferView.frame.width
            let seekTime = ratio * duration
            
            delegate?.seekTo(time: seekTime, track: self)
        }
    }
    
    func touchRegistered(gesture: UIGestureRecognizer) {
        if barBackgroundView.frame.height >= 6.0 {
            seek(to: gesture.location(in: self).y)
        } else {
            setTrackHidden(false)
        }
        
        hideTimer.invalidate()
    }
    
    func scheduleTimer() {
        if #available(iOS 10, *) {
            hideTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                self.setTrackHidden(false)
            })
        } else {
            hideTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(setTrackHidden(_:)), userInfo: nil, repeats: false)
        }
    }
}
