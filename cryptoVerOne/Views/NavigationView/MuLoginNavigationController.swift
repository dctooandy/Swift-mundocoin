//
//  MuLoginNavigationController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/5.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class MuLoginNavigationController:UINavigationController{
    
    private lazy var backBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named:"left-arrow"), for:.normal)
        btn.tintColor = .white
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        btn.setTitle("", for:.normal)
        return btn
    }()
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
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView:switchButton)
    }

    @objc func popVC() {
        _ = self.popViewController(animated:true)
    }
   
    override func pushViewController(_ viewController:UIViewController, animated:Bool) {
        viewController.hidesBottomBarWhenPushed = true
        viewController.tabBarController?.tabBar.isHidden = true
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(customView:backBtn)
        super.pushViewController(viewController, animated:animated)
    }
    
    override var preferredStatusBarStyle:UIStatusBarStyle {
        return .lightContent
    }
}
