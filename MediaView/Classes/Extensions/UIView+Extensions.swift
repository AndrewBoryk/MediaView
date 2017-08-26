//
//  UIView+Extensions.swift
//  MediaView
//
//  Created by Andrew Boryk on 8/26/17.
//

import Foundation

extension UIView {
    
    func addConstraints(_ constraints: [NSLayoutAttribute], toView view: UIView) {
        for constraint in constraints {
            switch constraint {
            case .height, .width:
                break
            default:
                if #available(iOS 9.0, *) {
                    switch constraint {
                    case .leading:
                        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
                    case .top:
                        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
                    case .trailing:
                        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
                    case .bottom:
                        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                    default:
                        break
                    }
                } else {
                    addConstraint(NSLayoutConstraint(item: self, attribute: constraint, relatedBy: .equal, toItem: view, attribute: constraint, multiplier: 1, constant: 0))
                }
            }
        }
    }
}
