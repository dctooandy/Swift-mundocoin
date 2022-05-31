//
//  BetleadNavigationViewController.swift
//  betlead
//
//  Created by Andy Chen on 2019/6/6.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit

class BetleadNavigationController:UINavigationController{
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarHidden = true
        modalPresentationStyle = .fullScreen
        setupNavigationBar()
    }
    
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
    }
    
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton()
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    
    private func setupNavigationBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(customView:backBtn)
        self.navigationBar.setBackgroundImage(UIImage(named: "navigation-bg")?.resizableImage(withCapInsets: .zero, resizingMode: .stretch), for: .default)
        self.navigationBar.tintColor = .white
        self.navigationBar.shadowImage = UIImage()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationBar.titleTextAttributes = textAttributes
        
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
        return .default
    }
    
}
