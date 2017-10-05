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
    
    private let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapRecognizer))
    
    init(alignment: NSTextAlignment = .left) {
        super.init(frame: .zero)
        
        self.font = UIFont.systemFont(ofSize: 12)
        self.isUserInteractionEnabled = false
        self.text = "0:00"
        self.textAlignment = alignment
        self.textColor = UIColor.white.withAlphaComponent(0.85)
        self.commonInitializer()
    }
    
    init(width: CGFloat, text: String = "", delegate: LabelDelegate?, kind: Kind = .track, isInteractionEnabled: Bool = true, font: UIFont = UIFont.systemFont(ofSize: 12)) {
        super.init(frame: CGRect(width: width, height: 16))
        
        self.kind = kind
        self.text = text
        self.font = font
        self.delegate = delegate
        self.isUserInteractionEnabled = true
        self.textColor = .white
        
        self.commonInitializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInitializer()
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    private func commonInitializer() {
        self.alpha = 0
        self.addShadow()
        self.addGestureRecognizer(self.tapRecognizer)
    }
    
    @objc private func handleTapRecognizer() {
        delegate?.didTouchUpInside(label: self)
    }
}
