//
//  CustomTransition.swift
//  AnimationDemo
//
//  Created by ohlulu on 2019/3/2.
//  Copyright © 2019 ohlulu. All rights reserved.
//

import UIKit

class CustomTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    var destinationPoint = CGPoint.zero
    
    private let grayView = UIView()
    
    private lazy var presentAnimation = CustomPresentAnimation(startPoint: destinationPoint)
    private lazy var dismissAnimation = CustomDismissAnimation(endPoint: destinationPoint)
    
    let interaction = UpToDownIneraction()
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        presentAnimation.grayView = grayView
        return presentAnimation
    }
    
    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        dismissAnimation.grayView = grayView
        return dismissAnimation
    }
    
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        print(interaction.interacting)
        return interaction.interacting ? interaction : nil
    }
    
}
