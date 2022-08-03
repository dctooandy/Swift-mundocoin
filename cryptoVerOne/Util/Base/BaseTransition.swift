//
//  BaseTransition.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/8/3.
//

import Foundation
class BaseTransition:NSObject, UIViewControllerAnimatedTransitioning {
    var operation : UINavigationController.Operation!
    var duration : CGFloat = 0.0
    var isFromLeft = false
    // 定義轉場動畫為0.8秒
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    // 具體的轉場動畫
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)
        let fromView = fromVC?.view
        
        let toVC = transitionContext.viewController(forKey: .to)
        let toView = toVC?.view
        
        let containerView = transitionContext.containerView
        containerView.addSubview(fromView!)
        containerView.addSubview(toView!)
        if self.operation == .push
        {
            let newFrame = CGRect(x: (isFromLeft ? -Views.screenWidth : Views.screenWidth), y: 0, width: (toView?.bounds.width)!, height: (toView?.bounds.height)!)
            let newFinalFrame = CGRect(x: 0, y: 0, width: (toView?.bounds.width)!, height: (toView?.bounds.height)!)
            toView?.frame = newFrame
            UIView.animate(withDuration: duration, animations: {
                toView?.frame = newFinalFrame
                
            }, completion: { finished in
                
                transitionContext.completeTransition(true)
                
            })
        }else
        {
            let newFrame = CGRect(x: (isFromLeft ? Views.screenWidth : -Views.screenWidth), y: 0, width: (toView?.bounds.width)!, height: (toView?.bounds.height)!)
            toView?.frame = newFrame
            let newFinalFrame = CGRect(x: 0, y: 0, width: (toView?.bounds.width)!, height: (toView?.bounds.height)!)
            UIView.animate(withDuration: duration, animations: {
                toView?.frame = newFinalFrame
                
            }, completion: { finished in
                
                transitionContext.completeTransition(true)
                
            })
        }
        // 轉場動畫
//        toView?.alpha = 0
//        UIView.animate(withDuration: duration, animations: {
//            fromView?.alpha = 0
//
//        }, completion: { [self] finished in
//            UIView.animate(withDuration: duration, animations: {
//                toView?.alpha = 1
//
//            }, completion: { finished in
//
//                // 通知完成轉場
//                transitionContext.completeTransition(true)
//            })
//
//        })
            
        
    }
}
