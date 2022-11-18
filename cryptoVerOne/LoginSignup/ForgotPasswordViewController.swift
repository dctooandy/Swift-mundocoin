//
//  ForgotPasswordViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 11/18/22.
//

import UIKit
import Parchment
import RxSwift
import Toaster
import AVFoundation
import AVKit

class ForgotPasswordViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    fileprivate let forgotPageVC = ForgotPageViewController()
    static let share: ForgotPasswordViewController = ForgotPasswordViewController.loadNib()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var backgroundImageView: UIImageView!
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBackgroundView()
        setupForgotPageVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        view.backgroundColor = Themes.grayF4F7FE
        title = "Forgot password"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
    }
    func setupForgotPageVC()
    {
        addChild(forgotPageVC)
        view.insertSubview(forgotPageVC.view, aboveSubview: backgroundImageView)
        forgotPageVC.view.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().offset(140)
            make.left.bottom.right.equalToSuperview()
        })
    }
    func setupBackgroundView()
    {
        backgroundImageView.layer.cornerRadius = 20
        backgroundImageView.layer.contents = UIImage(color: .white)?.cgImage
        backgroundImageView.layer.addShadow()
    }
}
// MARK: -
// MARK: 延伸
