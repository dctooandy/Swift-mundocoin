//
//  AuthenticationViewController.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/22.
//


import Foundation
import RxCocoa
import RxSwift
import SnapKit

class AuthenticationViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let authenCheckPassed = PublishSubject<Bool>()
    private let dpg = DisposeBag()
    var authenHeightConstraint : NSLayoutConstraint!
    var authenInputViewMode : InputViewMode = .email(withStar: false)
    {
        didSet{
            setupUI()
            bindStyle()
            bindButton()
            bindTextfield()
            bindTextfieldReturnKey()
            bindTextfieldAction()
            setupInputViewMode(mode: authenInputViewMode)
        }
    }
    // MARK: -
    // MARK:UI 設定
    var verifyVC : VerifyViewController!
    var authenInputView: InputStyleView!
    @IBOutlet weak var nextButton: CornerradiusButton!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authenInputView.invalidLabel.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
 
    // MARK: -
    // MARK:業務方法
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        authenInputView.tfMaskView.changeBorderWith(isChoose:false)
    }
    func setupInputViewMode(mode: InputViewMode)
    {
        authenInputView.onlySetupMode(mode: mode)
    }
    func setupUI()
    {
        if authenInputViewMode == .phone(withStar: false)
        {
            title = "SMS Authentication"
        }else if authenInputViewMode == .email(withStar: false)
        {
            title = "Email Authentication"
        }
        let accountView = InputStyleView(inputViewMode: nil)
        authenInputView = accountView
        self.view.addSubview(authenInputView)
        authenHeightConstraint = NSLayoutConstraint(item: authenInputView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewDefaultHeight))
        authenInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(110)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(authenHeightConstraint.constant)
        }
        authenInputView.addConstraint(authenHeightConstraint)
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(authenInputView.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(37)
            make.right.equalToSuperview().offset(-37)
            make.height.equalTo(47)
        }
    }
    func bindStyle()
    {
        InputViewStyleThemes.normalInputHeightType.bind(to: authenHeightConstraint.rx.constant).disposed(by: dpg)
    }
    func checkAccoutExist(account :String )
    {
        Beans.loginServer.verificationIDGet(idString: account).subscribe { [self] dto in
            Log.v("帳號沒有註冊過")
            addBindAction()
        } onError: { [self] error in
            if let error = error as? ApiServiceError {
                switch error {
                case .errorDto(let dto):
                    var verifyString = "Email"
                    let status = dto.httpStatus ?? ""
                    let reason = dto.reason
                    if status == "400"
                    {
                        Log.v("帳號已存在")
                        if reason == "ID_NOT_EXISTS"
                        {
                            if authenInputViewMode == .email(withStar: false)
                            {
                                verifyString = "Email"
                            }else
                            {
                                verifyString = "Mobile"
                            }
                            authenInputView.changeInvalidLabelAndMaskBorderColor(with: "\(verifyString) already registered.")

                        }else
                        {
                            ErrorHandler.show(error: error)
                        }                        
                    }else
                    {
                        ErrorHandler.show(error: error)
                    }
                default:
                    ErrorHandler.show(error: error)
                }
            }
        }.disposed(by: disposeBag)
    }
    func addBindAction()
    {
        var dataDto = KeychainManager.share.getLastAccountDto()
        if authenInputViewMode == .email(withStar: false)
        {
            if let accountString = authenInputView.textField.text?.localizedLowercase
            {
                dataDto?.account = accountString
            }
            dataDto?.loginMode = .emailPage
            verifyVC = VerifyViewController.instance( emailAuthenDto: dataDto)
        }else
        {
            if let phoneString = authenInputView.textField.text ,
               let phoneCodeString = authenInputView.mobileCodeLabel.text
            {
                let phoneInt :Int = Int(phoneString) ?? 0
                let phoneIntString :String = String(phoneInt)
                dataDto?.phone = (phoneCodeString + phoneIntString)
                dataDto?.phoneCode = phoneCodeString
            }
            dataDto?.loginMode = .phonePage
            verifyVC = VerifyViewController.instance( mobileAuthenDto: dataDto)
        }
        navigationController?.pushViewController(verifyVC, animated: true)

    }
    func bindButton()
    {
        nextButton.rx.tap.subscribeSuccess { [self] _ in
            if authenInputViewMode == .email(withStar: false)
            {
                if let accountString = authenInputView.textField.text?.localizedLowercase
                {
                    checkAccoutExist(account: accountString)
                }
            }else
            {
                if let phoneString = authenInputView.textField.text ,
                   let phoneCodeString = authenInputView.mobileCodeLabel.text
                {
                    let phoneInt :Int = Int(phoneString) ?? 0
                    let phoneIntString :String = String(phoneInt)
                    checkAccoutExist(account: (phoneCodeString + phoneIntString))
                }
            }
        }.disposed(by: dpg)
    }
    func bindTextfield() {
        let isAccountValid = authenInputView.textField.rx.text
//        let isAccountValid = accountTextField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let strongSelf = self, let acc = str else { return false  }
                if ((strongSelf.authenInputView.textField.isFirstResponder) != true) {
                    strongSelf.authenInputView.invalidLabel.isHidden = true
                }
                var patternValue = RegexHelper.Pattern.onlyMobile
                if strongSelf.authenInputViewMode == .phone(withStar: false) {
                    patternValue = .onlyMobile
                }else
                {
                    patternValue = .mail
                }
                return RegexHelper.match(pattern: patternValue, input: acc)
        }
        let isAccountHeightType = authenInputView.textField.rx.text
            .map { [weak self] (str) -> InputViewHeightType in
                guard let strongSelf = self, let acc = str else { return .accountInvalidHidden }
                if ((strongSelf.authenInputView.textField.isFirstResponder) == true) {
                    var patternValue = RegexHelper.Pattern.onlyMobile
                    if strongSelf.authenInputViewMode == .phone(withStar: false) {
                        patternValue = .onlyMobile
                    }else
                    {
                        patternValue = .mail
                    }
                    let resultValue:InputViewHeightType = RegexHelper.match(pattern: patternValue, input: acc) == true ? .accountInvalidHidden : (acc.isEmpty == true ? .accountInvalidShow : .accountInvalidShow)
                    if resultValue == .accountInvalidShow
                    {
                        strongSelf.authenInputView.invalidLabel.isHidden = false
                    }else
                    {
                        strongSelf.authenInputView.invalidLabel.isHidden = true
                    }
                    return resultValue
                }else
                {
                    if strongSelf.authenInputView.invalidLabel.textColor == .red
                    {
                        return .accountInvalidShow
                    }
                    return .accountInvalidHidden
                }
        }
        isAccountHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: dpg)
        isAccountValid.bind(to: nextButton.rx.isEnabled).disposed(by: dpg)
    }
    func bindTextfieldReturnKey()
    {
        authenInputView.textField.keyboardType = (authenInputViewMode == .phone(withStar: false) ? .numberPad :.emailAddress)
        authenInputView.textField.returnKeyType = .done
    }
    func bindTextfieldAction()
    {
        authenInputView.rxChoosePhoneCodeClick().subscribeSuccess { [self](phoneCode) in
            Log.v("PhoneCode:\(phoneCode)")
            let searchVC = SelectViewController.loadNib()
            searchVC.currentSelectMode = .selectArea(phoneCode)
            searchVC.rxSelectedAreaCodeClick().subscribeSuccess { [self] selectedCode in
                authenInputView.mobileCodeLabel.text = selectedCode
            }.disposed(by: disposeBag)
            searchVC.modalPresentationStyle = .popover
            self.present(searchVC, animated: true)
        }.disposed(by: dpg)
        authenInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText(textFieldChoose:isChoose)
            resetTFMaskView(authen:isChoose)
        }.disposed(by: dpg)
    }

    func resetInvalidText(textFieldChoose:Bool = false )
    {
        if textFieldChoose == true
        {
            authenInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
    }
    // 重置Border外觀
    func resetTFMaskView(authen:Bool = false ,force:Bool = false )
    {
        if authenInputView.invalidLabel.textColor != .red || force == true
        {
            authenInputView.tfMaskView.changeBorderWith(isChoose:authen)
        }
    }
    func resetInputView(view : InputStyleView)
    {
        if view.invalidLabel.textColor != .red
        {
            view.invalidLabel.isHidden = true
        }
    }
    func changeInvalidTextColor(with invalidDto:[ErrorsDetailDto])
    {
        for subData in invalidDto
        {
            if authenInputView.textField.text?.lowercased() == subData.rejectValue.lowercased()
            {
                authenInputView.changeInvalidLabelAndMaskBorderColor(with: subData.reason)
            }
        }
    }
    func resignAllResponder()
    {
        resetTFMaskView()
        authenInputView.textField.resignFirstResponder()
    }
}
// MARK: -
// MARK: 延伸
