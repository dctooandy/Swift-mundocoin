//
//  TFFinishReViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/12.
//

import Foundation
import RxCocoa
import RxSwift
enum TFFinishMode {
    case reverify
    case back
}
class TFFinishReViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static let share: TFFinishReViewController = TFFinishReViewController.loadNib()
    var viewMode:TFFinishMode = .back {
        didSet {
            resetUI()
        }
    }
    let withdrawVC = WithdrawViewController.share
    let withdrawNewVC = WithdrawNewViewController.share
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    let actionButton = CornerradiusButton()
    var bottomLabel : UILabel = {
       let label = UILabel()
        label.font = Fonts.PlusJakartaSansRegular(14)
        label.textColor = UIColor(rgb: 0x757575)
        label.text = "To reset 2FA will take at lease 7 Days.".localized
        return label
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Themes.grayF4F7FE
        title = "Google Authentication".localized
        setupUI()
        bind()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    func setupUI()
    {
        titleLabel.text = "You’ve enabled the Google Authenticator.  The App will generate verification codes for more protection when you logging in, redeeming, renewing, withdrawing, and changing a password in steaker.".localized
        view.addSubview(actionButton)
        actionButton.setTitle("Back".localized, for: .normal)
        actionButton.titleLabel?.font = Fonts.PlusJakartaSansMedium(16)
        actionButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        actionButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        actionButton.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.065)
        }
        view.addSubview(bottomLabel)
        bottomLabel.isHidden = true
        bottomLabel.snp.makeConstraints { (make) in
            make.top.equalTo(actionButton.snp.bottom).offset(13)
            make.centerX.equalToSuperview()
        }
    }
    func resetUI()
    {
        switch viewMode {
        case .back:
            actionButton.setTitle("Back".localized, for: .normal)
            bottomLabel.isHidden = true
        case .reverify:
            actionButton.setTitle("Re-verify".localized, for: .normal)
            bottomLabel.isHidden = false
        }
    }
    func bind()
    {
        bindButton()
    }
    func bindButton()
    {
        actionButton.rx.tap.subscribeSuccess { [self](_) in
            switch viewMode {
            case .back:
                if let vcArray = self.navigationController?.viewControllers
                {
                    var shouldDirectToWithdrawVC = true
                    for vc in vcArray {
                        if vc is SecurityViewController
                        {
                            let securityVC = SecurityViewController.share
                            _ = self.navigationController?.popToViewController(securityVC, animated:true )
                            shouldDirectToWithdrawVC = false
                            break
                        }
                    }
                    if shouldDirectToWithdrawVC == true
                    {
//                        let withdrawVC = WalletViewController.loadNib()
//                        self.navigationController?.viewControllers = [withdrawVC]
//                        withdrawVC.navigationController?.pushViewController(withdrawVC, animated: true)
//                        let withdrawVC = WithdrawViewController.share
                        if KeychainManager.share.getMundoCoinSioFeedbackEnable() == true
                        {
                            self.navigationController?.viewControllers = [withdrawNewVC]
                            WalletViewController.share.navigationController?.pushViewController(withdrawNewVC, animated: true)
                        }else
                        {
                            self.navigationController?.viewControllers = [withdrawVC]
                            WalletViewController.share.navigationController?.pushViewController(withdrawVC, animated: true)
                        }
                    }
                }
            case .reverify:
                let twoFAVC = SecurityVerificationViewController.loadNib()
                twoFAVC.securityViewMode = .onlyEmail
                twoFAVC.rxVerifySuccessClick().subscribeSuccess { [self] (_) in
                    // 目前沒有驗證驗證碼
                    goRebindGoogleAuth()
                }.disposed(by: dpg)
                _ = self.navigationController?.pushViewController(twoFAVC, animated: true)
            }
        }.disposed(by: dpg)
    }

    func goRebindGoogleAuth()
    {
        let googleAuthVC = TwoFactorAuthViewController.loadNib()
        _ = self.navigationController?.pushViewController(googleAuthVC, animated: true)
    }
    @objc override func popVC() {
        switch viewMode {
        case .back:
//            let securityVC = SecurityViewController.share
//            _ = self.navigationController?.popToViewController(securityVC, animated:true )
            self.navigationController?.popToRootViewController(animated: true)
        case .reverify:
            super.popVC()
        }
    }
    // MARK: -
    // MARK:業務方法
}
// MARK: -
// MARK: 延伸
