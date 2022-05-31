//
//  GuidePageViewController.swift
//  betlead
//
//  Created by Victor on 2019/6/3.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GuidePageViewController: UIPageViewController, Nibloadable {
    
    private var viewControllersList = [FirstLaunchViewController]()
    private let dpg = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        binding()
    }
    
    func setup() {
        let first = FirstLaunchViewController.loadNib()
        first.launchStep = .first
        first.setupUI()
        self.viewControllersList.append(first)
        
        let sec = FirstLaunchViewController.loadNib()
        sec.launchStep = .second
        sec.setupUI()
        self.viewControllersList.append(sec)
        
        let third = FirstLaunchViewController.loadNib()
        third.launchStep = .third
        third.setupUI()
        self.viewControllersList.append(third)
        self.setDisplayViewController(0)
        
    }
    
    func binding() {
        for i in viewControllersList {
            i.binding(goMain: { [weak self]  in
                print("go main")
                self?.displayMainViewController()
            }, goLogin: {  [weak self]  in
                print("go Register")
                self?.displayLoginViewController()
            }, next: {  [weak self] (step) in
                print("step: \(step)")
                self?.setDisplayViewController(step + 1)
            }) { [weak self] in
                print("pass")
                self?.displayMainViewController()
            }
        }
    }
    
    func setDisplayViewController(_ idx: Int) {
        DispatchQueue.main.async {
            self.setViewControllers([self.viewControllersList[idx]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func displayMainViewController() {
        DispatchQueue.main.async {
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                appdelegate.window?.rootViewController = BetleadNavigationController(rootViewController:TabbarViewController())
                appdelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
    let loginVC = LoginSignupViewController.share
    func displayLoginViewController() {
        DispatchQueue.main.async {
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                appdelegate.window?.rootViewController = self.loginVC
                appdelegate.window?.makeKeyAndVisible()
            }
        }
    }
    override var preferredStatusBarStyle:UIStatusBarStyle {
        return .default
    }
}

public enum GuideStep: Int {
    case first, second, third
    
    
    func title() -> String {
        switch self {
        case .first:
            return "有投必返"
        case .second:
            return "竞无止境"
        case .third:
            return "以小搏大"
        }
    }
    
    
    func subtitle() -> String {
        switch self {
        case .first:
            return "赛事不停歇"
        case .second:
            return "蓄力前行火热开打"
        case .third:
            return "百万奖池爆不停"
        }
    }
    func image() -> UIImage {
        switch self {
        case .first:
            return #imageLiteral(resourceName: "bg-launch-baseball")
        case .second:
            return #imageLiteral(resourceName: "bg-launch-Game")
        case .third:
            return #imageLiteral(resourceName: "bg-launch-caisno")
        }
    }
    
}
