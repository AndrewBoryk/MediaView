//
//  TrackView.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation

class TrackView: UIView, UIGestureRecognizerDelegate {
    
    var barHeight: CGFloat = 2.0
    var buffer: CGFloat = 0.0
    
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
    
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapRecognizer), delegate: self)
    private lazy var scrubRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanRecognizer), delegate: self)
    
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
    
    @objc private func handleTapRecognizer() {
        
    }
    
    @objc private func handlePanRecognizer() {
        
    }
}
