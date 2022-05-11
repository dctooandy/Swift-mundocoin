//
//  SecurityVerificationViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/10.
//

import Foundation
import RxCocoa
import RxSwift
enum SecurityViewMode {
    case defaultMode
    case selectedMode
}
class SecurityVerificationViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var securityViewMode : SecurityViewMode = .defaultMode {
        didSet{
      
        }
    }
    // MARK: -
    // MARK:UI 設定
    var twoFAVerifyView = TwoFAVerifyView()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Security Verification"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        bind()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        twoFAVerifyView.removeFromSuperview()
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        let twoFAView = TwoFAVerifyView.loadNib()
        twoFAView.twoFAViewMode = .both
        self.twoFAVerifyView = twoFAView
        view.addSubview(twoFAVerifyView)
        let height = self.navigationController?.navigationBar.frame.maxY ?? 44
        twoFAVerifyView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(height + 40)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    func bind()
    {
        bindAction()
    }
    func bindAction()
    {
        self.twoFAVerifyView.rxSecondSendVerifyAction().subscribeSuccess { [self](_) in
            Log.i("發送驗證傳送請求")
        }.disposed(by: dpg)
    }
}
// MARK: -
// MARK: 延伸
