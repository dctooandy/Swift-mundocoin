//
// Created by liq on 2018/5/4.
//

import Foundation
import UIKit
class BaseDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext:UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext:UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        fromViewController.view.frame = finalFrameForVC.offsetBy(dx: 0, dy: Views.screenHeight)
                        containerView.subviews.filter {
                            $0.tag == 5566
                            }.first?.alpha = 0
        }, completion: {
            finished in
            if !transitionContext.transitionWasCancelled {
                fromViewController.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
}
