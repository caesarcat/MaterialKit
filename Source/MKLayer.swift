//
//  MKLayer.swift
//  MaterialKit
//
//  Created by Le Van Nghia on 11/15/14.
//  Copyright (c) 2014 Le Van Nghia. All rights reserved.
//

import UIKit
import QuartzCore

enum MKTimingFunction {
    case Linear
    case EaseIn
    case EaseOut
    case Custom(Float, Float, Float, Float)
    
    var function : CAMediaTimingFunction {
        switch self {
        case .Linear:
            return CAMediaTimingFunction(name: "linear")
        case .EaseIn:
            return CAMediaTimingFunction(name: "easeIn")
        case .EaseOut:
            return CAMediaTimingFunction(name: "easeOut")
        case .Custom(let cpx1, let cpy1, let cpx2, let cpy2):
            return CAMediaTimingFunction(controlPoints: cpx1, cpy1, cpx2, cpy2)
        }
    }
}

class MKLayer {
    private var superLayer: CALayer!
    private let circleLayer = CALayer()
    private let backgroundLayer = CALayer()
    private let maskLayer = CAShapeLayer()
    var circleGrowRatioMax: Float = 0.9 {
        didSet {
            if circleGrowRatioMax > 0 {
                let superLayerWidth = CGRectGetWidth(superLayer.bounds)
                let superLayerHeight = CGRectGetHeight(superLayer.bounds)
                let circleSize = CGFloat(max(superLayerWidth, superLayerHeight)) * CGFloat(circleGrowRatioMax)
                let circleCornerRadius = circleSize/2
                
                circleLayer.cornerRadius = circleCornerRadius
                setSubLayerLocationAt(CGPoint(x: superLayerWidth/2, y: superLayerHeight/2))
            }
        }
    }
    
    init(superLayer: CALayer) {
        self.superLayer = superLayer
        
        let superLayerWidth = CGRectGetWidth(superLayer.bounds)
        let superLayerHeight = CGRectGetHeight(superLayer.bounds)
        
        // background layer
        backgroundLayer.frame = superLayer.bounds
        backgroundLayer.opacity = 0.0
        superLayer.addSublayer(backgroundLayer)
        
        // circlelayer
        let circleSize = CGFloat(max(superLayerWidth, superLayerHeight)) * CGFloat(circleGrowRatioMax)
        let circleCornerRadius = circleSize/2
       
        circleLayer.opacity = 0.0
        circleLayer.cornerRadius = circleCornerRadius
        setSubLayerLocationAt(CGPoint(x: superLayerWidth/2, y: superLayerHeight/2))
        backgroundLayer.addSublayer(circleLayer)
        
        // mask layer
        setMaskLayerCornerRadius(superLayer.cornerRadius)
        backgroundLayer.mask = maskLayer
    }
   
    func enableOnlyCircleLayer() {
        backgroundLayer.removeFromSuperlayer()
        superLayer.addSublayer(circleLayer)
    }
    
    func setBackgroundLayerColor(color: UIColor) {
        backgroundLayer.backgroundColor = color.CGColor
    }
    
    func setCircleLayerColor(color: UIColor) {
        circleLayer.backgroundColor = color.CGColor
    }
    
    func setSubLayerLocationAt(center: CGPoint) {
        let bounds = superLayer.bounds
        let width = CGRectGetWidth(bounds)
        let height = CGRectGetHeight(bounds)
        let subSize = CGFloat(max(width, height)) * CGFloat(circleGrowRatioMax)
        let subX = center.x - subSize/2
        let subY = center.y - subSize/2
        
        // disable animation when changing layer frame
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        circleLayer.frame = CGRect(x: subX, y: subY, width: subSize, height: subSize)
        CATransaction.commit()
    }
    
    func setMaskLayerCornerRadius(cornerRadius: CGFloat) {
        maskLayer.path = UIBezierPath(roundedRect: backgroundLayer.bounds, cornerRadius: cornerRadius).CGPath
    }
   
    func enableMask(enable: Bool = true) {
        backgroundLayer.mask = enable ? maskLayer : nil
    }
    
    func setBackgroundLayerCornerRadius(cornerRadius: CGFloat) {
        backgroundLayer.cornerRadius = cornerRadius
    }
    
    // MARK - Animation
    func animateScaleForCircleLayer(fromScale: Float, toScale: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let circleLayerAnim = CABasicAnimation(keyPath: "transform.scale")
        circleLayerAnim.fromValue = fromScale
        circleLayerAnim.toValue = toScale
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1.0
        opacityAnim.toValue = 0.0
        
        let groupAnim = CAAnimationGroup()
        groupAnim.duration = duration
        groupAnim.timingFunction = timingFunction.function
        groupAnim.removedOnCompletion = false
        groupAnim.fillMode = kCAFillModeForwards
        
        groupAnim.animations = [circleLayerAnim, opacityAnim]
    
        circleLayer.addAnimation(groupAnim, forKey: nil)
    }
    
    func animateAlphaForBackgroundLayer(timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let backgroundLayerAnim = CABasicAnimation(keyPath: "opacity")
        backgroundLayerAnim.fromValue = 1.0
        backgroundLayerAnim.toValue = 0.0
        backgroundLayerAnim.duration = duration
        backgroundLayerAnim.timingFunction = timingFunction.function
        backgroundLayer.addAnimation(backgroundLayerAnim, forKey: nil)
    }
    
    func animateSuperLayerShadow(fromRadius: CGFloat, toRadius: CGFloat, fromOpacity: Float, toOpacity: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        animateShadowForLayer(superLayer, fromRadius: fromRadius, toRadius: toRadius, fromOpacity: fromOpacity, toOpacity: toOpacity, timingFunction: timingFunction, duration: duration)
    }
    
    func animateMaskLayerShadow() {
        
    }
    
    private func animateShadowForLayer(layer: CALayer, fromRadius: CGFloat, toRadius: CGFloat, fromOpacity: Float, toOpacity: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let radiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
        radiusAnimation.fromValue = fromRadius
        radiusAnimation.toValue = toRadius
        
        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = fromOpacity
        opacityAnimation.toValue = toOpacity
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.timingFunction = timingFunction.function
        groupAnimation.removedOnCompletion = false
        groupAnimation.fillMode = kCAFillModeForwards
        groupAnimation.animations = [radiusAnimation, opacityAnimation]
        
        layer.addAnimation(groupAnimation, forKey: nil)
    }
}
