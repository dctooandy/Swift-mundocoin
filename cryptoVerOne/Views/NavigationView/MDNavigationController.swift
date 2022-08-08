//
//  MDNavigationController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

//enum ViewFromType:Int{
//    case fromLeft = 1
//    case fromRight = 2
//}

class MDNavigationController:UINavigationController{
    // MARK:業務設定
    // MARK: -
    let disposeBag = DisposeBag()
    var isFromLeft = false
    var interactionController: UIPercentDrivenInteractiveTransition?
    private var couldComplete = false
    // MARK:UI 設定
    lazy var mdBackBtn:TopBackButton = {
        let btn = TopBackButton()
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
  
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarHidden = true
        modalPresentationStyle = .fullScreen
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        
        let left = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeFromLeft(_:)))
        left.edges = .left
        view.addGestureRecognizer(left)
        let right = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeFromRight(_:)))
        right.edges = .right
        view.addGestureRecognizer(right)
    }
    
    private func setupNavigationBar() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = .clear
        self.navigationBar.tintColor = .white
    }
    // MARK: -
    // MARK:業務方法
//    func viewPushAnimation(_ viewController:UIViewController,from orientation:ViewFromType)
//    {
//        self.view.bringSubviewToFront(viewController.view)
//        AnimatorManager.scaleUp(view: viewController.view, frame: self.view.frame,orientation: orientation.rawValue).startAnimation()
//    }
    @objc func popVC() {
        _ = self.popViewController(animated:true)
        self.isFromLeft = false
    }
    
    @objc func pushToProfile() {
        _ = self.popViewController(animated:true)
    }
    
    @objc func pushToBell() {
        _ = self.popViewController(animated:true)
    }
    
    @objc func pushToBoard() {
        _ = self.popViewController(animated:true)
    }
    
    override func pushViewController(_ viewController:UIViewController, animated:Bool) {
        viewController.hidesBottomBarWhenPushed = true
        viewController.tabBarController?.tabBar.isHidden = true
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(customView:mdBackBtn)
        if let newVC = viewController as? UserMenuViewController {
            self.isFromLeft = true
            super.pushViewController(newVC, animated:animated)
        }else
        {
            self.isFromLeft = false
            super.pushViewController(viewController, animated:animated)
//            if self.viewControllers.filter({ $0 is UserMenuViewController}).count > 0
//            {
//                self.isFromLeft = true
//            }
        }
    }
//    func pushViewControllerFromLeft(_ viewController:UIViewController, animated:Bool) {
//        self.pushViewController(viewController, animated: animated)
//   }
    
    override var preferredStatusBarStyle:UIStatusBarStyle {
        if #available(iOS 13.0, *) {
#if Approval_PRO || Approval_DEV || Approval_STAGE
            return .darkContent
#else
            return .darkContent
#endif
        } else {
            return .default
        }
    }
    @objc func handleSwipeFromLeft(_ gesture: UIScreenEdgePanGestureRecognizer) {

        if (self.visibleViewController is UserMenuViewController) == true , interactionController == nil
        {
            
        }else
        {
            let percent = gesture.translation(in: gesture.view!).x / gesture.view!.bounds.size.width
            
            if gesture.state == .began {
                interactionController = UIPercentDrivenInteractiveTransition()
                if viewControllers.count > 1 {
                    popViewController(animated: true)
                } else {
                    //                dismiss(animated: true)
                }
            } else if gesture.state == .changed {
                interactionController?.update(percent)
            } else if gesture.state == .ended {
                //            if percent > 0.5 && gesture.state != .cancelled {
                //                interactionController?.finish()
                //            } else {
                //                interactionController?.cancel()
                //            }
                interactionController?.finish()
                interactionController = nil
            }
        }

    }
    @objc func handleSwipeFromRight(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if (self.visibleViewController is UserMenuViewController) == false , interactionController == nil
        {
            
        }else
        {
            self.isFromLeft = true

            let percent = -gesture.translation(in: gesture.view!).x / gesture.view!.bounds.size.width
            
            if gesture.state == .began {
                interactionController = UIPercentDrivenInteractiveTransition()
                if viewControllers.count > 1 {
                    popViewController(animated: true)
                } else {
                    //                dismiss(animated: true)
                }
            } else if gesture.state == .changed {
                interactionController?.update(percent)
            } else if gesture.state == .ended {
                //            if percent > 0.5 && gesture.state != .cancelled {
                //                interactionController?.finish()
                //            } else {
                //                interactionController?.cancel()
                //            }
                interactionController?.finish()
                interactionController = nil
            }
        }
    }
}
