//
//  PlayIndicatorView.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/28/17.
//

import UIKit

protocol PlayIndicatorDelegate: class {
    
    func player(for playIndicatorView: PlayIndicatorView) -> Player?
    func shouldShowPlayIndicator() -> Bool
    func image(for playIndicatorView: PlayIndicatorView) -> UIImage?
}

class PlayIndicatorView: UIImageView {
    
    weak var delegate: PlayIndicatorDelegate?
    
    /// Timer for animating the playIndicatorView, to show that the video is loading
    private(set) internal var animateTimer = Timer()
    
    init(delegate: PlayIndicatorDelegate?) {
        super.init(image: delegate?.image(for: self))
        self.delegate = delegate
        contentMode = .scaleAspectFit
        translatesAutoresizingMaskIntoConstraints = false
        center = center
        sizeToFit()
        alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Show that the video is loading with animation
    @objc func beginAnimation() {
        endAnimation()
        
        if let player = delegate?.player(for: self), player.didFailToPlay {
            alpha = 1
            updateImage()
        } else {
            animate()
            animateTimer = Timer.scheduledTimer(timeInterval: 0.751, target: self, selector: #selector(animate), userInfo: nil, repeats: true)
        }
    }
    
    /// Stop video loading animation
    func endAnimation() {
        animateTimer.invalidate()
    }
    
    /// Animate the video indicator
    @objc private func animate() {
        if let shouldShow = delegate?.shouldShowPlayIndicator(), shouldShow {
            let updatedAlpha: CGFloat = alpha == 1 ? 0.4 : 1
            
            UIView.animate(withDuration: 0.75, animations: {
                self.alpha = updatedAlpha
            })
        } else {
            alpha = (delegate?.player(for: self)?.didFailToPlay ?? false) ? 1 : 0
        }
    }
    
    func updateImage() {
        image = delegate?.image(for: self)
    }
    
}
