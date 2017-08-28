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
    
    static func playIndicator(themeColor: UIColor) -> UIImage? {
        let size: CGFloat = 60
        UIGraphicsBeginImageContextWithOptions(CGSize(size), false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        context.setFillColor(themeColor.withAlphaComponent(0.8).cgColor)
        context.fillEllipse(in: rect)
        
        let leftPath = UIBezierPath()
        leftPath.move(to: CGPoint(18))
        leftPath.addLine(to: CGPoint(42))
        leftPath.close()
        
        let rightPath = UIBezierPath()
        rightPath.move(to: CGPoint(18, 42))
        rightPath.addLine(to: CGPoint(42, 18))
        rightPath.close()
        
        let color = UIColor.white.withAlphaComponent(1.0).cgColor
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
        
        let playCircle = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return playCircle
    }
    
    static func failIndicator(themeColor: UIColor, isFullScreen: Bool, pressShowsGIF: Bool) -> UIImage? {
        let size: CGFloat = 60.0
        UIGraphicsBeginImageContextWithOptions(CGSize(60), false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        context.setFillColor(themeColor.withAlphaComponent(0.8).cgColor)
        context.fillEllipse(in: rect)
        
        if !isFullScreen && pressShowsGIF {
            let thickness: CGFloat = 2.0
            context.setLineWidth(thickness)
            context.setStrokeColor(UIColor.white.cgColor)
            
            let rectGIF = CGRect(x: 1, y: 1, width: size - thickness, height: size - thickness)
            
            let ra: [CGFloat] = [4, 2]
            context.setLineDash(phase: 0.0, lengths: ra)
            context.strokeEllipse(in: rectGIF)
        }
        
        let inset: CGFloat = 15.0
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(20.625, inset))
        bezierPath.addLine(to: CGPoint(size - inset, size / 2))
        bezierPath.addLine(to: CGPoint(20.625, size - inset))
        bezierPath.close()
        
        let color = UIColor.white.withAlphaComponent(0.8).cgColor
        context.setFillColor(color)
        context.setStrokeColor(color)
        context.setLineWidth(0)
        
        context.setLineJoin(.round)
        context.setLineCap(.round)
        
        context.addPath(bezierPath.cgPath)
        context.strokePath()
        context.addPath(bezierPath.cgPath)
        context.fillPath()
        context.restoreGState()
        
        let failIndicator = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return failIndicator
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
