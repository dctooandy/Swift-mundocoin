//
// Created by liq on 2018/5/4.
//

import Foundation
import UIKit
class BasePresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext:UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.25
  }

  func animateTransition(using transitionContext:UIViewControllerContextTransitioning) {
    let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
    let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
    let containerView = transitionContext.containerView
    let bgView = UIView(color: .black)
    bgView.alpha = 0
    bgView.tag = 5566
    toViewController.view.frame = finalFrameForVC.offsetBy(dx: 0, dy: Views.screenHeight)
    bgView.frame = finalFrameForVC
    containerView.addSubview(bgView)
    containerView.addSubview(toViewController.view)
    UIView.animate(withDuration: transitionDuration(using: transitionContext),
        delay: 0,
        options: .curveEaseInOut,
        animations: {
          toViewController.view.frame = finalFrameForVC
          bgView.alpha = 0.3
        }) { (finished) in
      transitionContext.completeTransition(true)
    }


  }
} 

