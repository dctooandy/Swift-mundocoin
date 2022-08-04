//
//  CustomPresentAnimation.swift
//  AnimationDemo
//
//  Created by ohlulu on 2019/1/20.
//  Copyright © 2019 ohlulu. All rights reserved.
//

import UIKit

class CustomPresentAnimation: NSObject , UIViewControllerAnimatedTransitioning {
    
    var startPoint: CGPoint
    var grayView: UIView!
    private let durationTime = 0.45
    
    init(startPoint: CGPoint) {
        self.startPoint = startPoint
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return durationTime
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.viewController(forKey: .to)?.view else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(grayView)
        grayView.frame = containerView.frame
        grayView.backgroundColor = .black
        grayView.alpha = 0
        
        let maskView = UIView()
        maskView.frame.size = CGSize(width: 1, height: 1)
        maskView.center = startPoint
        maskView.backgroundColor = .black
        maskView.layer.cornerRadius = 0.5
        toView.mask = maskView
        containerView.addSubview(toView)
        
        let containerFrame = containerView.frame
        let maxY = max(containerFrame.height - startPoint.y, startPoint.y)
        let maxX = max(containerFrame.width - startPoint.x, startPoint.x)
        let maxSize = max(maxY, maxX) * 2.1

        UIView.animate(
            withDuration: durationTime,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                
                maskView.frame.size = CGSize(width: maxSize, height: maxSize)
                maskView.layer.cornerRadius = maxSize / 2.0
                maskView.center = self.startPoint
                self.grayView.alpha = 0.5
        }) { (flag) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
