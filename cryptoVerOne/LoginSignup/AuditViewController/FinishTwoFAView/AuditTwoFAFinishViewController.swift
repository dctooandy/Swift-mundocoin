//
//  AuditTwoFAFinishViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 7/7/22.
//


import Foundation
import RxCocoa
import RxSwift

class AuditTwoFAFinishViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static let share: AuditTwoFAFinishViewController = AuditTwoFAFinishViewController.loadNib()

    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var backView: UIView!
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        title = "Google Authentication".localized
        backView.backgroundColor = Themes.grayF4F7FE
        view.backgroundColor = Themes.black1B2559
        setupUI()
        bind()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,.font: Fonts.PlusJakartaSansBold(20)]

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
        titleLabel.text = "The App will generate verification codes for more protection when you logging in.".localized
        backView.addSubview(actionButton)
        actionButton.setTitle("Got it".localized, for: .normal)
        actionButton.titleLabel?.font = Fonts.SFProTextSemibold(16)
        actionButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        actionButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x19BBB1)) , for: .normal)
        actionButton.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
        backView.addSubview(bottomLabel)
        bottomLabel.isHidden = true
        bottomLabel.snp.makeConstraints { (make) in
            make.top.equalTo(actionButton.snp.bottom).offset(13)
            make.centerX.equalToSuperview()
        }
    }
    func resetUI()
    {
        actionButton.setTitle("Got it".localized, for: .normal)
        bottomLabel.isHidden = true
    }
    func bind()
    {
        bindButton()
    }
    func bindButton()
    {
        actionButton.rx.tap.subscribeSuccess { [self](_) in
            navigationController?.popToRootViewController(animated: true)
        }.disposed(by: dpg)
    }

    func goRebindGoogleAuth()
    {
        let googleAuthVC = TwoFactorAuthViewController.loadNib()
        _ = self.navigationController?.pushViewController(googleAuthVC, animated: true)
    }
    @objc override func popVC() {
        navigationController?.popToRootViewController(animated: true)
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
// MARK: -
// MARK: 延伸
