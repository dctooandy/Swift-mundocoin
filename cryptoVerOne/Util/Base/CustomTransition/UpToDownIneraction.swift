//
//  UpToDownIneration.swift
//  AnimationDemo
//
//  Created by ohlulu on 2019/3/10.
//  Copyright © 2019 ohlulu. All rights reserved.
//

import UIKit

class UpToDownIneraction: UIPercentDrivenInteractiveTransition {
    var interacting = false
    
    private var couldComplete = false
    private weak var presentingViewController: UIViewController? = nil
    
    func wireGesture(on viewController: UIViewController) {
        presentingViewController = viewController
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        viewController.view.addGestureRecognizer(gesture)
    }
    
    @objc func handleGesture(_ gestureRecoginizer: UIPanGestureRecognizer) {
        let gestureView = gestureRecoginizer.view!
        let trainsiton = gestureRecoginizer.translation(in: gestureView)
        switch gestureRecoginizer.state {
        case .began:
            print("began")
            interacting = true
            if let naviController = presentingViewController?.navigationController {
                naviController.popViewController(animated: true)
            } else {
                presentingViewController?.dismiss(animated: true, completion: nil)
            }
        case .changed:
            var fraction = trainsiton.y / gestureView.frame.height
            print("\(fraction)")
            fraction = max(fraction, 0.0)
            fraction = min(fraction, 1)
            couldComplete = fraction > 0.4
            update(fraction)
        case .cancelled, .ended:
            interacting = false
            if couldComplete == false || gestureRecoginizer.state == .cancelled {
                cancel()
            } else {
                finish()
            }
        default:
            break
        }
    }

}
