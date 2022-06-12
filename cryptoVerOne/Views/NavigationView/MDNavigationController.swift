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

class MDNavigationController:UINavigationController{
    // MARK:業務設定
    // MARK: -
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
    }
    
    private func setupNavigationBar() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = .clear
       
    }
    // MARK: -
    // MARK:業務方法
    @objc func popVC() {
        _ = self.popViewController(animated:true)
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
        super.pushViewController(viewController, animated:animated)
    }
    
    override var preferredStatusBarStyle:UIStatusBarStyle {
        return .default
    }
}
