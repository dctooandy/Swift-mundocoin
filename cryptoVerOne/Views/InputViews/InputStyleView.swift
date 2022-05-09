//
//  InputStyleView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/8.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class InputStyleView: UIView {
    // MARK:業務設定
    private var inputMode: LoginMode = .account
    private var currentShowMode: ShowMode = .login
    private let displayPwdImg = UIImage(named: "eye-solid")!.withRenderingMode(.alwaysTemplate)
    private let undisplayPwdImg =  UIImage(named: "eye-slash-solid")!.withRenderingMode(.alwaysTemplate)
    private let cancelImg = UIImage(named: "icon-close")!
    private let onClick = PublishSubject<String>()
    private let dpg = DisposeBag()
    private var isPWStyle : Bool = false
    private var isRegisterStyle : Bool = false
    // MARK: -
    // MARK:UI 設定
    let topLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.textColor = .black
        lb.text = "Email".localized
        lb.font = Fonts.pingFangSCRegular(16)
        return lb
    }()
    let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = Fonts.pingFangSCRegular(16)
        return tf
    }()
    let invalidLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.font = Fonts.pingFangSCRegular(14)
        lb.textColor = .red
        lb.isHidden = true
        return lb
    }()
    let displayRightButton = UIButton()
    let cancelRightButton = UIButton()
    
    // MARK: -
    // MARK:Life cycle
    convenience init(inputMode: LoginMode = .account, currentShowMode: ShowMode = .login, isPWStyle:Bool = false , isRegisterStyle: Bool = false) {
        self.init(frame: .zero)
        self.inputMode = inputMode
        self.isPWStyle = isPWStyle
        self.isRegisterStyle = isRegisterStyle
        self.currentShowMode = currentShowMode
        self.setup()
        self.bindPwdButton()
        self.bindTextfield()
        self.bindCancelButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: -
    // MARK:業務方法
    func setup()
    {
        addSubview(topLabel)
        addSubview(textField)
        addSubview(invalidLabel)

        
        textField.delegate = self
        displayRightButton.tintColor = .black
        let textFieldMulH = height(48/812)
        let invalidH = height(20/812)
        topLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(height(17/812))
        }
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(height(5/812))
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(textFieldMulH)
        }
        invalidLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textField.snp.bottom)
            make.left.equalTo(textField)
            make.height.equalTo(invalidH)
        }
        textField.setMaskView()
       
        resetUI()
    }
    func resetUI()
    {
        textField.textColor = .black
        displayRightButton.tintColor = .black
        var placeHolderString = ""
        var topLabelString = ""
        var invalidLabelString = ""
        switch currentShowMode {
        case .login:
            placeHolderString = (isPWStyle ? inputMode.pwdPlaceholder() : inputMode.accountPlacehloder())
        case .signup:
            placeHolderString = (isPWStyle ? inputMode.signupPwdPlaceholder() : (isRegisterStyle ? inputMode.signuprRegisterPlaceholder():inputMode.signupAccountPlacehloder()))
        case .forgotPW:
            placeHolderString = (isPWStyle ? "" : inputMode.forgotAccountPlacehloder())
        }
        textField.setPlaceholder(placeHolderString, with: Themes.grayLighter)
        
        switch inputMode {
        case .account:
            if currentShowMode == .forgotPW
            {
                topLabelString = "Enter your email to change your password".localized
            }else
            {
                topLabelString = (isPWStyle ? "Password".localized: (isRegisterStyle ? "Registration code".localized: "Email".localized))
            }
            invalidLabelString = (isPWStyle ? "Invaild verification code".localized: (isRegisterStyle ? "Invaild verification code".localized: "Invaild email".localized))
            textField.isSecureTextEntry = isPWStyle

        case .phone:
            topLabelString = (isPWStyle ?  "Password".localized: "Phone Number".localized)
            invalidLabelString = (isPWStyle ?  "Invaild verification code".localized: "Invaild phone".localized)
            textField.isSecureTextEntry = isPWStyle
        }
        topLabel.text = topLabelString
        invalidLabel.text = invalidLabelString
        var offetWidth = 0.0
        if currentShowMode != .forgotPW && isPWStyle == true
        {
            offetWidth = 24.0
        }
        addSubview(displayRightButton)
        displayRightButton.frame.size.width = 24
        displayRightButton.setTitle(nil, for: .normal)
        displayRightButton.setBackgroundImage(displayPwdImg, for: .normal)
        displayRightButton.snp.remakeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(textField)
            make.height.equalTo(24)
            make.width.equalTo(offetWidth)
        }
        addSubview(cancelRightButton)
        //設定文字刪除
        cancelRightButton.setBackgroundImage(cancelImg, for: .normal)
        cancelRightButton.backgroundColor = .black
        cancelRightButton.layer.cornerRadius = 7
        cancelRightButton.layer.masksToBounds = true
        cancelRightButton.snp.remakeConstraints { (make) in
            make.right.equalTo(displayRightButton.snp.left).offset(-10)
            make.centerY.equalTo(textField)
            make.width.height.equalTo(14)
        }
    }
    func bindPwdButton()
    {
        displayRightButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.displayRightPressed()
            }.disposed(by: dpg)
        cancelRightButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.cancelButtonPressed()
            }.disposed(by: dpg)
    }
    func bindTextfield()
    {
        
    }
    func bindCancelButton()
    {
        
    }
    func changeInputMode(mode: LoginMode) {
        inputMode = mode
        resetUI()
    }
    private func displayRightPressed() {
        
        switch inputMode {
        case .account:
            textField.isSecureTextEntry = !(textField.isSecureTextEntry)
            displayRightButton.setBackgroundImage(textField.isSecureTextEntry ? displayPwdImg : undisplayPwdImg , for: .normal)
        case .phone:
            onClick.onNext(textField.text!)
        }
    }
    private func cancelButtonPressed() {
        textField.text = ""
        cancelRightButton.isHidden = true
        textField.sendActions(for: .valueChanged)
    }
}
// MARK: -
// MARK: 延伸
extension InputStyleView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
