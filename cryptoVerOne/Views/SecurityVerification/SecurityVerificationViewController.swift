//
//  SecurityVerificationViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/10.
//

import Foundation
import RxCocoa
import RxSwift

class SecurityVerificationViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    var twoFAVerifyView = TwoFAVerifyView.loadNib()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Security Verification"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
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
        twoFAVerifyView.twoFAViewMode = .both
        view.addSubview(twoFAVerifyView)
        let height = self.navigationController?.navigationBar.frame.maxY ?? 44
        twoFAVerifyView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(height + 40)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

    }
}
// MARK: -
// MARK: 延伸
