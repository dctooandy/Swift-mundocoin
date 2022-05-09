//
//  DonateDismissAnimationController.swift
//  sprout
//
//  Created by CS on 2017/10/16.
//  Copyright © 2017年 CS. All rights reserved.
//

import Foundation
import UIKit

class BottomSheetDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

  func transitionDuration(using transitionContext:UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.25
  }

  func animateTransition(using transitionContext:UIViewControllerContextTransitioning) {
    let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
    let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
    let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
    UIView.animate(withDuration: transitionDuration(using: transitionContext),
        delay: 0,
        options: .curveEaseInOut,
        animations: {
          fromViewController.view.frame = CGRect(x: Views.screenWidth,
              y: 0,
              width: fromViewController.view.frame.width,
              height: fromViewController.view.frame.height)
          toViewController.view.frame = finalFrameForVC.offsetBy(dx: 0, dy: 0)
        }, completion: {
      finished in
      fromViewController.view.removeFromSuperview()
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })

  }
}
