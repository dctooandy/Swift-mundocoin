//
//  CustomDismissAnimation.swift
//  AnimationDemo
//
//  Created by ohlulu on 2019/3/2.
//  Copyright © 2019 ohlulu. All rights reserved.
//

import UIKit

class CustomDismissAnimation: NSObject , UIViewControllerAnimatedTransitioning {
    
    let endPoint: CGPoint
    var grayView: UIView!
    private let durationTime = 0.45
    
    init(endPoint: CGPoint) {
        self.endPoint = endPoint
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return durationTime
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewController(forKey: .from)?.view else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        let containerFrame = containerView.frame
        let maxY = max(containerFrame.height - endPoint.y, endPoint.y)
        let maxX = max(containerFrame.width - endPoint.x, endPoint.x)
        let maxSize = max(maxY, maxX) * 2.1
        
        let maskView = UIView()
        maskView.frame.size = CGSize(width: maxSize, height: maxSize)
        maskView.center = endPoint
        maskView.backgroundColor = .black
        maskView.layer.cornerRadius = maxSize / 2.0
        
        fromView.mask = maskView
        
        containerView.addSubview(fromView)
        
        UIView.animate(
            withDuration: durationTime,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                
                maskView.frame.size = CGSize(width: 1, height: 1)
                maskView.layer.cornerRadius = 0.5
                maskView.center = self.endPoint
                self.grayView.alpha = 0
        }) { (flag) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
