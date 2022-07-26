//
//  AnimatorManager.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/7/26.
//

import Foundation
import UIKit
class AnimatorManager {
    static func scaleUp(view: UIView, frame:CGRect , orientation : Int) -> UIViewPropertyAnimator {
        var initFrame = view.frame
        switch orientation {
        case 1:
            initFrame.origin.x -= Views.screenWidth
        case 2:
            initFrame.origin.x += Views.screenWidth
        default: break
        }
        view.frame = initFrame
        let scale = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut)

        scale.addAnimations({
            view.frame = frame
        }, delayFactor: 0.2)

        scale.addCompletion { (_) in
                            print("animation done")
                            }
        return scale
  }
}
