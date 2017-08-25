//
//  Label.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation

protocol LabelDelegate: class {
    
    func didTouchUpInside(label: Label)
}

class Label: UILabel {
    
    enum Kind {
        case title
        case description
        case track
    }
    
    weak var delegate: LabelDelegate?
    var kind: Kind!
    
    private let tapRecognizer = TapGesture(target: self, action: #selector(handleTapRecognizer))
    
    init(width: CGFloat, text: String, delegate: LabelDelegate?, kind: Kind = .track, isInteractionEnabled: Bool = true) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: width, height: 16)))
        
        self.text = text
        self.alpha = 0
        self.kind = kind
        self.delegate = delegate
        self.textAlignment = .left
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = .white
        self.addShadow()
        self.isUserInteractionEnabled = isInteractionEnabled
        
        self.addGestureRecognizer(self.tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTapRecognizer() {
        delegate?.didTouchUpInside(label: self)
    }
}
