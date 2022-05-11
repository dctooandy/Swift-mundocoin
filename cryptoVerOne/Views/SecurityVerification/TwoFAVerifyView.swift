//
//  TwoFAVerifyView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/10.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import Toaster

enum TwoFAInputMode {
    case email
    case twoFA
    case none
    
    func topString() -> String {
        switch self {
        case .email: return "Enter the 6-digit code sent to ".localized
        case .twoFA: return "Enter the 6-digit code from google 2FA".localized
        default: return ""
        }
    }
    
    func textPlacehloder() -> String {
        switch self {
        case .email: return "Email verification code".localized
        case .twoFA: return "Google Authenticator code".localized
        default: return ""
        }
    }
    
    func invaildString() -> String {
        switch self {
        case .email: return "Invaild verification code".localized
        case .twoFA: return "Invaild verification code".localized
        default: return ""
        }
    }
    func rightLabelString() -> String
    {
        switch self {
        case .email: return "Send".localized
        case .twoFA: return "Paste".localized
        default: return ""
        }
    }
}
enum TwoFAViewMode {
    case both
    case onlyEmail
    case onlyTwoFA
}
class TwoFAVerifyView: UIView {
    // MARK:業務設定
    private let onSecondSendVerifyClick = PublishSubject<Any>()
    private let onsubmitBothClick = PublishSubject<(String,String)>()
    private let onSubmitOnlyEmailClick = PublishSubject<String>()
    private let onSubmitOnlyTwoFAClick = PublishSubject<String>()
    private let dpg = DisposeBag()
    var twoFAViewMode : TwoFAViewMode = .both {
        didSet{
            self.setup()
            self.bind()
        }
    }
    
    // MARK: -
    // MARK:UI 設定
    var emailInputView = InputStyleView(inputMode: .email)
    var twoFAInputView = InputStyleView(inputMode: .twoFA)
    @IBOutlet weak var lostTwoFALabel: UILabel!
    let submitButton : CornerradiusButton = {
       let btn = CornerradiusButton()
        btn.titleLabel?.font = Fonts.pingFangTCRegular(16)
        btn.setTitle("Submit".localized, for: .normal)
        btn.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        btn.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func removeFromSuperview() {
        super.removeFromSuperview()
        emailInputView.removeFromSuperview()
        twoFAInputView.removeFromSuperview()
    }
    // MARK: -
    // MARK:業務方法
    func setup() {
        let defaultHeight : CGFloat = height(90/812)
        var bottomY : CGFloat = height(90/812)
        switch twoFAViewMode {
        case .both:
            addSubview(emailInputView)
            addSubview(twoFAInputView)
            setupEmailInputView(withTop: 0)
            setupTwoFAInputView(withTop: defaultHeight)
            bottomY = height(90/812) * 2.0
        case .onlyEmail:
            addSubview(emailInputView)
            setupEmailInputView(withTop: 0)
        case .onlyTwoFA:
            addSubview(twoFAInputView)
            setupTwoFAInputView(withTop: 0)
        }
        lostTwoFALabel.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(bottomY)
            make.leading.equalToSuperview().offset(32)
        }
        addSubview(submitButton)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(lostTwoFALabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.065)
        }
    }
    func setupEmailInputView(withTop:CGFloat)
    {
        emailInputView.snp.makeConstraints { (make) in
            make.top.equalTo(withTop)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(height(90/812))
        }
    }
    func setupTwoFAInputView(withTop:CGFloat)
    {
        twoFAInputView.snp.makeConstraints { (make) in
            make.top.equalTo(withTop)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(height(90/812))
        }
    }
    func bind()
    {
        bindTextfield()
        bindCancelButton()
        bindLostTwoFALabel()
        bindAction()
    }
    func bindTextfield()
    {
        let isEmailValid = emailInputView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let _ = self, let acc = str else { return false  }
                return RegexHelper.match(pattern: .otp, input: acc)
        }
        let isTwoFAValid = twoFAInputView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let _ = self, let acc = str else { return false  }
                return RegexHelper.match(pattern: .otp, input: acc)
        }
        switch twoFAViewMode {
        case .both:
            isEmailValid.skip(1).bind(to: emailInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
            isTwoFAValid.skip(1).bind(to: twoFAInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
            Observable.combineLatest(isEmailValid, isTwoFAValid)
                .map { return $0.0 && $0.1 } //reget match result
                .bind(to: submitButton.rx.isEnabled)
                .disposed(by: dpg)
        case .onlyEmail:
            isEmailValid.skip(1).bind(to: emailInputView.invalidLabel.rx.isHidden)
                .disposed(by: dpg)
            isEmailValid.bind(to: submitButton.rx.isEnabled).disposed(by: dpg)
        case .onlyTwoFA:
            isTwoFAValid.skip(1).bind(to: twoFAInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
            isTwoFAValid.bind(to: submitButton.rx.isEnabled).disposed(by: dpg)
        }        
    }
    func bindCancelButton()
    {
        let _ =  emailInputView.textField.rx.text.map({$0 ?? ""})
            .map({$0.isEmpty})
            .bind(to: emailInputView.cancelRightButton.rx.isHidden)
            .disposed(by: dpg)
        let _ =  twoFAInputView.textField.rx.text.map({$0 ?? ""})
            .map({$0.isEmpty})
            .bind(to: twoFAInputView.cancelRightButton.rx.isHidden)
            .disposed(by: dpg)
    }
    func bindLostTwoFALabel()
    {
        lostTwoFALabel.rx.click.subscribeSuccess { (_) in
            Toast.show(msg: "連接")
        }.disposed(by: dpg)
    }
    func cleanTextField() {
        emailInputView.textField.text = ""
        twoFAInputView.textField.text = ""
        emailInputView.invalidLabel.isHidden = true
        twoFAInputView.invalidLabel.isHidden = true
    }
    func bindAction()
    {
        emailInputView.rxSendVerifyAction().subscribeSuccess { [weak self](_) in
            self?.onSecondSendVerifyClick.onNext(())
        }.disposed(by: dpg)
        submitButton.rx.tap.subscribeSuccess { [self](_) in
            submitAction()
        }.disposed(by: dpg)
    }
    
    func submitAction()
    {
        switch self.twoFAViewMode {
        case .both:
            if let emailString = self.emailInputView.textField.text,
               let twoFAString = self.twoFAInputView.textField.text
            {
                onsubmitBothClick.onNext((emailString,twoFAString))
            }
        case .onlyEmail:
            if let emailString = self.emailInputView.textField.text
            {
                onSubmitOnlyEmailClick.onNext((emailString))
            }
        case .onlyTwoFA:
            if let twoFAString = self.twoFAInputView.textField.text
            {
                onSubmitOnlyTwoFAClick.onNext((twoFAString))
            }
        }
    }
    
    func rxSecondSendVerifyAction() -> Observable<(Any)>
    {
        return onSecondSendVerifyClick.asObserver()
    }
    func rxSubmitBothAction() -> Observable<(String,String)>
    {
        return onsubmitBothClick.asObserver()
    }
    func rxSubmitOnlyEmailAction() -> Observable<(String)>
    {
        return onSubmitOnlyEmailClick.asObserver()
    }
    func rxSubmitOnlyTwiFAAction() -> Observable<(String)>
    {
        return onSubmitOnlyTwoFAClick.asObserver()
    }
    func cleanTimer()
    {
        emailInputView.resetTimerAndAll()
    }
}
// MARK: -
// MARK: 延伸
