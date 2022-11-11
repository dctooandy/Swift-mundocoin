//
//  BaseViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import RxCocoa
import RxSwift
import UIKit
import SnapKit


class BaseViewController:UIViewController,Nibloadable{
    // MARK:業務設定
    let disposeBag = DisposeBag()
    var isNavBarTransparent:Bool
    var isEnablePopGesture = true
    var isRecoverNavBar = true
    var isFromLeft = false
    private var isShowKeyboard = false

    // MARK: -
    // MARK:UI 設定
    lazy var naviBackBtn:TopBackButton = {
        let btn = TopBackButton()
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: naviBackBtn)
    }
    
    init(isNavBarTransparent:Bool = false){
        self.isNavBarTransparent = isNavBarTransparent
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        if (isNavBarTransparent) {
            self.navigationController?.navigationBar.isTranslucent = true
            Themes.applyNavigationBarClear(navBar:self.navigationController?.navigationBar, alpha:0.0, tinColor:.clear)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.delegate = nil
        if (isNavBarTransparent && isRecoverNavBar) {
            self.navigationController?.isNavigationBarHidden = false
            Themes.applyNavigationBarClear(navBar:self.navigationController?.navigationBar, alpha:1, tinColor:.white)
            Themes.applyNavigationBar(navBar:self.navigationController?.navigationBar)
        }
        if !isRecoverNavBar {
            Themes.applyNavigationBarClear(navBar:self.navigationController?.navigationBar, alpha:0, tinColor:.clear)
        }
    }
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent:parent)
//        if (!isNavBarTransparent && isRecoverNavBar) {
//            Themes.applyNavigationBarClear(navBar:self.navigationController?.navigationBar, alpha:1, tinColor:.white)
//            Themes.applyNavigationBar(navBar:self.navigationController?.navigationBar, isTranslucent:true)
//        }
//        if !isRecoverNavBar {
//            Themes.applyNavigationBarClear(navBar:self.navigationController?.navigationBar, alpha:0, tinColor:.clear)
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
   
    required init?(coder aDecoder: NSCoder) {
        self.isNavBarTransparent = false
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: -
    // MARK:業務方法
    @objc func popVC() {
        var fromLeft = false
        if self.navigationController?.viewControllers.last is UserMenuViewController
        {
            fromLeft = true
        }else
        {
            fromLeft = false
        }
        if let newNav = navigationController as? MDNavigationController
        {
            newNav.isFromLeft = fromLeft
        }
        if (self.navigationController?.viewControllers.filter{ $0 is UserMenuViewController}.count)! > 0
        {
            if let newNav = navigationController as? MDNavigationController
            {
                newNav.isFromLeft = true
            }
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    func setupKeyboard(_ constraint:NSLayoutConstraint, height:CGFloat = 240){
        let origin = constraint.constant
        let keyboardOnScreenHeight = Observable.from([
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                .map { _ in height },
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                .map { _ in 0 }
            ]).merge()
        
        keyboardOnScreenHeight.subscribeSuccess { (height) in
            constraint.constant = origin + height
            }.disposed(by: disposeBag)
        
    }
    func setupKeyboard(_ constraint:Constraint, height:CGFloat = 240){
        let origin = constraint.layoutConstraints[0].constant
        let keyboardOnScreenHeight = Observable.from([
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                .map { _ in height },
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                .map { _ in 0 }
            ]).merge()
        
        keyboardOnScreenHeight.subscribeSuccess { (height) in
            constraint.update(offset: -height + origin)
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
            }.disposed(by: disposeBag)
        
    }
    
    func setupDismissTap(){
        let tap = UITapGestureRecognizer()
        view.addGestureRecognizer(tap)
        tap.rx.event.subscribe({ [weak self] _ in
            self?.view.endEditing(true)
        } ).disposed(by: disposeBag)
    }
    var statusStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle:UIStatusBarStyle {
        if #available(iOS 13.0, *) {
#if Approval_PRO || Approval_DEV || Approval_STAGE
            return .lightContent
#else
            return .darkContent
#endif
        } else {
            return .default
        }
    }
}

extension UIViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented:UIViewController,
                                    presenting:UIViewController,
                                    source:UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BasePresentAnimationController()
    }
    
    public func animationController(forDismissed dismissed:UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BaseDismissAnimationController()
    }
}
extension BaseViewController: UINavigationControllerDelegate
{
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let newNav = navigationController as? MDNavigationController
        {
            return newNav.interactionController
        }else
        {
            return nil
        }
    }
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let baseTransition = BaseTransition()
        if let _ = navigationController as? MDNavigationController
        {
            if ((toVC as? UserMenuViewController) != nil) , ((fromVC as? WalletViewController) != nil)
            {
                baseTransition.isFromLeft = true
            }else if ((fromVC as? UserMenuViewController) != nil) , ((toVC as? WalletViewController) != nil)
            {
                baseTransition.isFromLeft = true
            }else
            {
                baseTransition.isFromLeft = false
            }
        }
        
        if operation == UINavigationController.Operation.push {
            baseTransition.operation = UINavigationController.Operation.push
            baseTransition.duration = 0.3
            return baseTransition
        }
        
        if operation == UINavigationController.Operation.pop {
            baseTransition.operation = UINavigationController.Operation.pop
            baseTransition.duration = 0.3
            
            return baseTransition
        }
        
        return nil
    }
}
