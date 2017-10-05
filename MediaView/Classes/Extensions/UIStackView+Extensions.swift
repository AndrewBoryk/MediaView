//
//  UIStackView+Extensions.swift
//  MediaView
//
//  Created by Andrew Boryk on 10/2/17.
//

import Foundation

extension UIStackView {
    
    convenience init(frame: CGRect, axis: UILayoutConstraintAxis = .vertical, alignment: UIStackViewAlignment = .fill, distribution: UIStackViewDistribution =  .fill, spacing: CGFloat = 0, subviews: [UIView] = []) {
        self.init(frame: frame)
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
        
        for subview in subviews {
            addArrangedSubview(subview)
        }
    }
}
