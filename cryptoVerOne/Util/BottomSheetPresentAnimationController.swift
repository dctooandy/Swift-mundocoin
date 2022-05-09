//
//  CustomerTransitionVC.swift
//  sprout
//
//  Created by CS on 2017/10/16.
//  Copyright © 2017年 CS. All rights reserved.
//

import Foundation
import UIKit

class BottomSheetPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext:UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.25
  }

  func animateTransition(using transitionContext:UIViewControllerContextTransitioning) {
    let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
    let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
    let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
    let containerView = transitionContext.containerView
    let bgView = UIView(color: .black)
    bgView.alpha = 0
    toViewController.view.frame = finalFrameForVC.offsetBy(dx: Views.screenWidth, dy: 0)
    bgView.frame = finalFrameForVC
    containerView.addSubview(bgView)
    containerView.addSubview(toViewController.view)
    UIView.animate(withDuration: transitionDuration(using: transitionContext),
        delay: 0,
        options: .curveEaseInOut,
        animations: {
          toViewController.view.frame = finalFrameForVC
          fromViewController.view.frame = finalFrameForVC.offsetBy(dx: -Views.screenWidth, dy: 0)
        }) { (finished) in
      transitionContext.completeTransition(true)
    }


  }
}
    
    
    
    



