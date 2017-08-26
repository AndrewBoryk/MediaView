//
//  UIImage+Extensions.swift
//  Pods
//
//  Created by Andrew Boryk on 6/27/17.
//
//

import Foundation

extension UIImage {
    
    static var close: UIImage? {
        let size: CGFloat = 18.0
        UIGraphicsBeginImageContextWithOptions(CGSize(size), false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.saveGState()
        
        let leftPath = UIBezierPath()
        leftPath.move(to: .zero)
        leftPath.addLine(to: CGPoint(size))
        leftPath.close()
        
        let rightPath = UIBezierPath()
        rightPath.move(to: CGPoint(x: 0, y: size))
        rightPath.addLine(to: CGPoint(x: size, y: 0))
        rightPath.close()
        
        let color: CGColor = UIColor.white.cgColor
        context.setFillColor(color)
        context.setStrokeColor(color)
        context.setLineWidth(1.5)
        context.setShadow(offset: .zero, blur: 1.0, color: UIColor.black.cgColor)
        
        context.setLineJoin(.round)
        context.setLineCap(.round)
        
        context.addPath(rightPath.cgPath)
        context.strokePath()
        context.addPath(rightPath.cgPath)
        context.fillPath()
        context.addPath(leftPath.cgPath)
        context.strokePath()
        context.addPath(leftPath.cgPath)
        context.fillPath()
        context.restoreGState()
        
        let closeX = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return closeX
    }
    
    static func topOverlay(frame: CGRect) -> UIImage? {
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor]
        
        UIGraphicsBeginImageContextWithOptions(gradient.frame.size, false, 0)
        gradient.render(in: context)
        
        let outputImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage
    }
}
