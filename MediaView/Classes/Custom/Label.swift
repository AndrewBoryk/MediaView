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
    
    var isEmpty: Bool {
        guard let text = text?.replacingOccurrences(of: " ", with: "") else {
            return true
        }
        
        return text.isEmpty
    }
    
    init(y: CGFloat) {
        super.init(frame: CGRect(x: 0, y: y, width: 120, height: 14))
        
        self.font = UIFont.systemFont(ofSize: 12)
        self.isUserInteractionEnabled = false
        self.text = "0:00"
        self.textColor = UIColor.white.withAlphaComponent(0.85)
        
        self.commonInitializer()
        
    }
    
    init(width: CGFloat, text: String = "", delegate: LabelDelegate?, kind: Kind = .track, isInteractionEnabled: Bool = true, font: UIFont = UIFont.systemFont(ofSize: 12)) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: width, height: 16)))
        
        self.kind = kind
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
    
    private func commonInitializer() {
        self.text = text
        self.alpha = 0
        
        self.textAlignment = .left
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addShadow()
        
        self.addGestureRecognizer(self.tapRecognizer)
    }
    
    @objc private func handleTapRecognizer() {
        delegate?.didTouchUpInside(label: self)
    }
}
