//
//  TFBeginViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/12.
//

import Foundation
import RxCocoa
import RxSwift

class TFBeginViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static let share: TFBeginViewController = TFBeginViewController.loadNib()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    let goAuthButton = CornerradiusButton()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Google Authentication".localized
        setupUI()
        bind()
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
        titleLabel.text = "Google Authentication".localized
        subTitleLabel.text = "Complete your Google Authentication to get started. Ensure the safety and security of Mundo.".localized
        view.addSubview(goAuthButton)
        goAuthButton.setTitle("Google Authentication".localized, for: .normal)
        goAuthButton.titleLabel?.font = Fonts.pingFangTCMedium(16)
        goAuthButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        goAuthButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        goAuthButton.snp.makeConstraints { (make) in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(80)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.065)
        }
    }
    func bind()
    {
        goAuthButton.rx.tap.subscribeSuccess { [self](_) in
            let twoFAVC = SecurityVerificationViewController.loadNib()
            twoFAVC.securityViewMode = .onlyEmail
            twoFAVC.rxVerifySuccessClick().subscribeSuccess { (_) in
                goRebindGoogleAuth()
            }.disposed(by: dpg)
            _ = self.navigationController?.pushViewController(twoFAVC, animated: true)
        }.disposed(by: dpg)
    }
    func goRebindGoogleAuth()
    {
        let googlwAuthVC = TwoFactorAuthViewController.loadNib()
        _ = self.navigationController?.pushViewController(googlwAuthVC, animated: true)
    }
}
// MARK: -
// MARK: 延伸
