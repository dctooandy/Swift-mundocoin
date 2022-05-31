//
//  UCPasswordViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/23.
//


import Foundation
import RxCocoa
import RxSwift

class UCPasswordViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    let twoFAVC = SecurityVerificationViewController.loadNib()
    fileprivate let changedPWVC = CPasswordViewController.loadNib()
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    var oldInputView : InputStyleView!
    var newInputView : InputStyleView!
    var confirmInputView : InputStyleView!
    let submitButton = CornerradiusButton()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        setupUI()
        bindTextfield()
        bindCancelButton()
        bindPwdButton()
        bindAction()
        bindBorderColor()
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
    func setupUI()
    {
        title = "Change password".localized
        view.backgroundColor = #colorLiteral(red: 0.9552231431, green: 0.9678531289, blue: 0.994515121, alpha: 1)
        let oldView = InputStyleView(inputViewMode: .oldPassword)
        let newView = InputStyleView(inputViewMode: .newPassword)
        let confirmView = InputStyleView(inputViewMode: .confirmPassword)
        oldInputView = oldView
        newInputView = newView
        confirmInputView = confirmView
        view.addSubview(oldInputView)
        view.addSubview(newInputView)
        view.addSubview(confirmInputView)
        view.addSubview(submitButton)
        
        oldInputView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(110)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Themes.inputViewPasswordHeight)
        }
        newInputView.snp.makeConstraints { (make) in
            make.top.equalTo(oldInputView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Themes.inputViewPasswordHeight)
        }
        confirmInputView.snp.makeConstraints { (make) in
            make.top.equalTo(newInputView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Themes.inputViewPasswordHeight)
        }
        submitButton.setTitle("Submit".localized, for: .normal)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmInputView.snp.bottom).offset(20)
            make.centerX.equalTo(confirmInputView)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        oldInputView.tfMaskView.changeBorderWith(isChoose:false)
        newInputView.tfMaskView.changeBorderWith(isChoose:false)
        confirmInputView.tfMaskView.changeBorderWith(isChoose:false)
    }
    // MARK: -
    // MARK:業務方法
    func bindTextfield()
    {
        let isoldValid = oldInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. password, input: acc)
        }
        let isnewValid = newInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. password, input: acc)
        }
        let isconfirmValid = confirmInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return (acc == self.newInputView.textField.text) &&
                    RegexHelper.match(pattern:. password, input: acc)
        }
        
        isoldValid.skip(1).bind(to: oldInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isnewValid.skip(1).bind(to: newInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isconfirmValid.skip(1).bind(to: confirmInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        Observable.combineLatest(isoldValid, isnewValid,isconfirmValid)
            .map { return $0.0 && $0.1 && $0.2 } //reget match result
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: dpg)
    }
    func bindCancelButton()
    {
        let _ =  oldInputView.textField.rx.text.map({$0 ?? ""})
            .map({$0.isEmpty})
            .bind(to: oldInputView.cancelRightButton.rx.isHidden)
            .disposed(by: dpg)
        let _ =  newInputView.textField.rx.text.map({$0 ?? ""})
            .map({$0.isEmpty})
            .bind(to: newInputView.cancelRightButton.rx.isHidden)
            .disposed(by: dpg)
        let _ =  confirmInputView.textField.rx.text.map({$0 ?? ""})
            .map({$0.isEmpty})
            .bind(to: confirmInputView.cancelRightButton.rx.isHidden)
            .disposed(by: dpg)
    }
    func bindPwdButton()
    {
        submitButton.rx.tap
            .subscribeSuccess { [self] in
                submitButtonPressed()
            }.disposed(by: dpg)
    }
    func customerUpdatePassword(Withcode:String)
    {
        if let currentString = oldInputView.textField.text,
        let newString = newInputView.textField.text
        {
            Beans.loginServer.customerUpdatePassword(current: currentString, updated: newString, verificationCode: Withcode).subscribeSuccess { [self]data in
                Log.v("更改成功")
                changedPWVC.backgroundImageViewHidden()
                self.navigationController?.pushViewController(changedPWVC, animated: true)
            }.disposed(by: dpg)
        }
    }
    func bindAction()
    {
        twoFAVC.securityViewMode = .selectedMode
        twoFAVC.rxVerifySuccessClick().subscribeSuccess { [self](stringData) in
            customerUpdatePassword(Withcode: stringData.0)
        }.disposed(by: dpg)
    }
    func bindBorderColor()
    {
        oldInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            oldInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
            newInputView.tfMaskView.changeBorderWith(isChoose:false)
            confirmInputView.tfMaskView.changeBorderWith(isChoose:false)
        }.disposed(by: dpg)
        newInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            oldInputView.tfMaskView.changeBorderWith(isChoose:false)
            newInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
            confirmInputView.tfMaskView.changeBorderWith(isChoose:false)
        }.disposed(by: dpg)
        confirmInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            oldInputView.tfMaskView.changeBorderWith(isChoose:false)
            newInputView.tfMaskView.changeBorderWith(isChoose:false)
            confirmInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
    }
    func submitButtonPressed()
    {
        self.navigationController?.pushViewController(twoFAVC, animated: true)
    }
}
// MARK: -
// MARK: 延伸