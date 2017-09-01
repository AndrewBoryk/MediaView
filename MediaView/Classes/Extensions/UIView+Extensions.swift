//
//  UIView+Extensions.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/26/17.
//

import Foundation

extension UIView {
    
    func addConstraints(_ constraints: [NSLayoutAttribute], toView view: UIView, constant: CGFloat = 0) {
        for constraint in constraints {
            switch constraint {
            case .height, .width:
                let constraint = NSLayoutConstraint(item: view, attribute: constraint, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constant)
                constraint.isActive = true
                addConstraint(constraint)
            default:
                let constraint = NSLayoutConstraint(item: self, attribute: constraint, relatedBy: .equal, toItem: view, attribute: constraint, multiplier: 1, constant: constant)
                constraint.isActive = true
                addConstraint(constraint)
            }
        }
    }
}
