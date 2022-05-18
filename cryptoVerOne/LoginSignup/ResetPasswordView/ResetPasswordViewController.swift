//
//  ResetPasswordViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/6.
//

import Foundation
import RxCocoa
import RxSwift

class ResetPasswordViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    private let cancelImg = UIImage(named: "icon-close")!
    fileprivate let changedPWVC = CPasswordViewController.loadNib()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var newPasswordInputView : InputStyleView!
    var confirmPasswordInputView : InputStyleView!

    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton()
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
//    let newPWCancelRightButton = UIButton()
//    let confirmPWCancelRightButton = UIButton()
    let submitButton = CornerradiusButton()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:backBtn)
        setupUI()
        bindPwdButton()
        bindTextfield()
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(Views.topOffset + 12.0)
        }
        backgroundImageView.layer.cornerRadius = 20
        backgroundImageView.layer.contents = UIImage(color: .white)?.cgImage
        backgroundImageView.layer.addShadow()
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        view.backgroundColor = #colorLiteral(red: 0.9552231431, green: 0.9678531289, blue: 0.994515121, alpha: 1)
        
        let newPasswordView = InputStyleView(inputViewMode: .newPassword)
        newPasswordInputView = newPasswordView
        let confirmPasswordView = InputStyleView(inputViewMode: .confirmPassword)
        confirmPasswordInputView = confirmPasswordView
        topLabel.text = "Reset password".localized
        view.addSubview(newPasswordInputView)
        view.addSubview(confirmPasswordInputView)
        view.addSubview(submitButton)

        newPasswordInputView.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(80)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Themes.inputViewPasswordHeight)
        }
        confirmPasswordInputView.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordInputView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Themes.inputViewPasswordHeight)
        }
      
        submitButton.titleLabel?.font = Fonts.pingFangTCRegular(16)
        submitButton.setTitle("Submit".localized, for: .normal)
        submitButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        submitButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmPasswordInputView.snp.bottom).offset(10)
            make.centerX.equalTo(confirmPasswordInputView)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
    }
    func bindPwdButton()
    {
        submitButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.submitButtonPressed()
            }.disposed(by: dpg)
    }
    func bindTextfield()
    {
        let isNewPWValid = newPasswordInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. password, input: acc)
        }
        let isConPWValid = confirmPasswordInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return (acc == self.newPasswordInputView.textField.text) &&
                    RegexHelper.match(pattern:. password, input: acc)
        }
        isNewPWValid.skip(1).bind(to: newPasswordInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isConPWValid.skip(1).bind(to: confirmPasswordInputView.invalidLabel.rx.isHidden).disposed(by: dpg)

        Observable.combineLatest(isNewPWValid, isConPWValid)
            .map { return $0.0 && $0.1 } //reget match result
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: dpg)
    }
    func submitButtonPressed()
    {
        self.navigationController?.pushViewController(changedPWVC, animated: true)
    }
    @objc func popVC(isAnimation : Bool = true)
    {
        _ = self.navigationController?.popToRootViewController(animated: isAnimation)
    }
}
// MARK: -
// MARK: 延伸

