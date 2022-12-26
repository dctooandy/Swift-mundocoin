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
    private var isNetWorkConnectIng = false
    private let onSubmitClick = PublishSubject<String>()
    private var dpg = DisposeBag()
    private let cancelImg = UIImage(named: "icon-close")!
    fileprivate let changedPWVC = CPasswordViewController.loadNib()
    var newPasswordHeightConstraint : NSLayoutConstraint!
    var confirmPasswordHeightConstraint : NSLayoutConstraint!
    var resetPWDto : LoginPostDto?
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
        title = "Forgot password"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:backBtn)
        setupUI()
        bindTextfield()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = LoadingViewController.dismiss()
        isNetWorkConnectIng = false
        dpg = DisposeBag()
        bindPwdButton()
        bindBorderColor()
        bindTextfieldReturnKey()
        bindStyle()
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        resetTFMaskView()
        newPasswordInputView.textField.sendActions(for: .valueChanged)
        confirmPasswordInputView.textField.sendActions(for: .valueChanged)
    }
    func resetTFMaskView(newPW:Bool = false ,confirmPW:Bool = false ,force:Bool = false )
    {
        if newPasswordInputView.invalidLabel.textColor != .red || force == true
        {
            newPasswordInputView.tfMaskView.changeBorderWith(isChoose:newPW)
        }
        if confirmPasswordInputView.invalidLabel.textColor != .red || force == true
        {
            confirmPasswordInputView.tfMaskView.changeBorderWith(isChoose:confirmPW)
        }
    }
    func setupUI()
    {
        view.backgroundColor = Themes.grayF4F7FE
        let newPasswordView = InputStyleView(inputViewMode: .newPassword)
        newPasswordInputView = newPasswordView
        let confirmPasswordView = InputStyleView(inputViewMode: .confirmPassword)
        confirmPasswordInputView = confirmPasswordView
        
        self.newPasswordInputView.textField.addTarget(self.confirmPasswordInputView.textField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)

        newPasswordHeightConstraint = NSLayoutConstraint(item: newPasswordInputView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewPasswordHeight))
        confirmPasswordHeightConstraint = NSLayoutConstraint(item: confirmPasswordInputView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewPasswordHeight))

        topLabel.text = "Reset password".localized
        view.addSubview(newPasswordInputView)
        view.addSubview(confirmPasswordInputView)
        view.addSubview(submitButton)

        newPasswordInputView.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(newPasswordHeightConstraint.constant)
//            make.height.equalTo(Themes.inputViewPasswordHeight)
        }
        newPasswordInputView.addConstraint(newPasswordHeightConstraint)
        confirmPasswordInputView.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordInputView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(confirmPasswordHeightConstraint.constant)
//            make.height.equalTo(Themes.inputViewPasswordHeight)
        }
        confirmPasswordInputView.addConstraint(confirmPasswordHeightConstraint)
        submitButton.titleLabel?.font = Fonts.PlusJakartaSansRegular(16)
        submitButton.setTitle("Submit".localized, for: .normal)
        submitButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        submitButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmPasswordInputView.snp.bottom).offset(40)
            make.centerX.equalTo(confirmPasswordInputView)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
    }
    func bindPwdButton()
    {
        submitButton.rx.tap
            .subscribeSuccess { [self] in
                submitButton.isEnabled = false
                if isNetWorkConnectIng != true
                {
                    isNetWorkConnectIng = true
                    submitButtonPressed()
                }
            }.disposed(by: dpg)
    }
    func bindTextfield()
    {
        let isNewPWValid = newPasswordInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                if (self.newPasswordInputView.textField.isFirstResponder) != true
                {
                    self.newPasswordInputView.invalidLabel.isHidden = true
                }
                return RegexHelper.match(pattern:. password, input: acc)
        }
        let isConPWValid = confirmPasswordInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                if (self.confirmPasswordInputView.textField.isFirstResponder) != true
                {
                    self.confirmPasswordInputView.invalidLabel.isHidden = true
                }
                return (acc == self.newPasswordInputView.textField.text) &&
                    RegexHelper.match(pattern:. password, input: acc)
        }
        
//        isNewPWValid.skip(1).bind(to: newPasswordInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
//        isConPWValid.skip(1).bind(to: confirmPasswordInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        let isNewPWHeightType = newPasswordInputView.textField.rx.text
            .map { [weak self] (str) -> InputViewHeightType in
                guard let strongSelf = self, let password = str else { return .newPWInvalidHidden }
                if ((strongSelf.newPasswordInputView.textField.isFirstResponder) == true) {
                    var patternValue = RegexHelper.Pattern.phone
                    patternValue = .password
                    let resultValue:InputViewHeightType = RegexHelper.match(pattern: patternValue, input: password) == true ? .newPWInvalidHidden : (password.isEmpty == true ? .newPWInvalidShow : .newPWInvalidShow)
                    if resultValue == .newPWInvalidShow
                    {
                        strongSelf.newPasswordInputView.invalidLabel.isHidden = false
                    }else
                    {
                        strongSelf.newPasswordInputView.invalidLabel.isHidden = true
                    }
                    return resultValue
                }else
                {
                    if strongSelf.newPasswordInputView.invalidLabel.textColor == .red
                    {
                        return .newPWInvalidShow
                    }
                    return .newPWInvalidHidden
                }
        }
        
        let isConfirmPWHeightType = confirmPasswordInputView.textField.rx.text
            .map { [weak self] (str) -> InputViewHeightType in
                guard let strongSelf = self, let password = str else { return .confirmPWInvalidHidden }
                if ((strongSelf.confirmPasswordInputView.textField.isFirstResponder) == true) {
                    var patternValue = RegexHelper.Pattern.phone
                    patternValue = .password
                    let resultValue:InputViewHeightType = RegexHelper.match(pattern: patternValue, input: password) == true ? .confirmPWInvalidHidden : (password.isEmpty == true ? .confirmPWInvalidShow : .confirmPWInvalidShow)
                    if resultValue == .confirmPWInvalidShow
                    {
                        strongSelf.confirmPasswordInputView.invalidLabel.isHidden = false
                    }else
                    {
                        strongSelf.confirmPasswordInputView.invalidLabel.isHidden = true
                    }
                    return resultValue
                }else
                {
                    if strongSelf.confirmPasswordInputView.invalidLabel.textColor == .red
                    {
                        return .confirmPWInvalidShow
                    }
                    return .confirmPWInvalidHidden
                }
        }
        isNewPWHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: disposeBag)
        isConfirmPWHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: disposeBag)
        Observable.combineLatest(isNewPWValid, isConPWValid)
            .map { return $0.0 && $0.1 } //reget match result
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    func bindBorderColor()
    {
        newPasswordInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText(newPW:isChoose)
            resetTFMaskView(newPW:isChoose)
            resetInputView(view: newPasswordInputView)
//            accountInputView.textField.sendActions(for: .valueChanged)
            if isChoose == false
            {
                confirmPasswordInputView.textField.becomeFirstResponder()
            }
        }.disposed(by: dpg)
        confirmPasswordInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText(confirmPW:isChoose)
            resetTFMaskView(confirmPW:isChoose)
            resetInputView(view: confirmPasswordInputView)
        }.disposed(by: dpg)
    }
    func resetInvalidText(newPW:Bool = false ,confirmPW:Bool = false )
    {
        if newPW == true
        {
            newPasswordInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
        if confirmPW == true
        {
            confirmPasswordInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
    }
    func resetInputView(view : InputStyleView)
    {
        if view.invalidLabel.textColor != .red
        {
            view.invalidLabel.isHidden = true
        }
    }
    func bindTextfieldReturnKey()
    {
        newPasswordInputView.textField.returnKeyType = .next
        confirmPasswordInputView.textField.returnKeyType = .done
    }
    func bindStyle()
    {
        InputViewStyleThemes.newInputHeightType.bind(to: newPasswordHeightConstraint.rx.constant).disposed(by: dpg)
        InputViewStyleThemes.confirmInputHeightType.bind(to: confirmPasswordHeightConstraint.rx.constant).disposed(by: dpg)
    }
    func submitButtonPressed()
    {
        if let passwordString = newPasswordInputView.textField.text
        {
            resignAllResponder()
            if let resetData = self.resetPWDto
            {
                Beans.loginServer.customerForgotPassword(mode:resetData.loginMode , accountString: resetData.toAccountString.lowercased(), verificationCode: resetData.resetCode, newPassword: passwordString).subscribe { [self] (data) in
                    gotoFinalVC()
                } onError: { [self](error) in
                    
                    if let errorData = error as? ApiServiceError
                    {
                        switch errorData {
                        case .errorDto(let dto):
                            let status = dto.httpStatus ?? ""
//                            let reason = dto.reason
                            if status == "400"
                            {
                                showAlert()
                            }else
                            {
                                ErrorHandler.show(error: error)
                                isNetWorkConnectIng = false
                            }
                        default:
                            ErrorHandler.show(error: error)
                            isNetWorkConnectIng = false
                        }
                    }
                }.disposed(by: dpg)
            }
        }
    }
    func showAlert()
    {
        let popVC =  ConfirmPopupView(viewHeight:222.0 ,iconMode: .showIcon("Back"),
                                      title: "Error",
                                      message: "The verification code is timeout, you could try it again.") { [self] isOK in

            if isOK {
                Log.v("返回")
                isNetWorkConnectIng = false
                self.popVC()
            }
        }
        popVC.messageLabel.textColor = Themes.gray718096
        popVC.messageLabel.font = Fonts.PlusJakartaSansMedium(14)
        popVC.start(viewController: self)
    }
    func resignAllResponder()
    {
        resetTFMaskView()
        newPasswordInputView.textField.resignFirstResponder()
        confirmPasswordInputView.textField.resignFirstResponder()
    }
    func gotoFinalVC()
    {
        self.navigationController?.pushViewController(changedPWVC, animated: true)
//        isNetWorkConnectIng = false
    }
    func rxSubmitClick() -> Observable<String>
    {
        return onSubmitClick.asObserver()
    }
    @objc override func popVC()
    {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
// MARK: -
// MARK: 延伸

