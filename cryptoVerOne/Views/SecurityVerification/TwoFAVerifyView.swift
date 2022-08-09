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

enum TwoFAViewMode {
    case both
    case onlyEmail
    case onlyTwoFA
}
class TwoFAVerifyView: UIView {
    // MARK:業務設定
    private let onSecondSendVerifyClick = PublishSubject<Any>()
    private let onSubmitBothClick = PublishSubject<(String,String)>()
    private let onSubmitOnlyEmailClick = PublishSubject<String>()
    private let onSubmitOnlyTwoFAClick = PublishSubject<String>()
    private let onLostGoogleClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var twoFAViewMode : TwoFAViewMode = .both {
        didSet{
            resetUI()
            bindTextfield()
            bindBorderColor()
        }
    }
    var emailHeightConstraint : NSLayoutConstraint!
    var twoFAHeightConstraint : NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    var emailInputView = InputStyleView(inputViewMode: .emailVerify(KeychainManager.share.getLastAccount()?.account ?? ""))
    var twoFAInputView = InputStyleView(inputViewMode: .twoFAVerify)
    @IBOutlet weak var lostTwoFALabel: UILabel!
    let submitButton : CornerradiusButton = {
       let btn = CornerradiusButton()
        btn.titleLabel?.font = Fonts.PlusJakartaSansRegular(16)
        btn.setTitle("Submit".localized, for: .normal)
        btn.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        btn.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
        self.bind()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func removeFromSuperview() {
        super.removeFromSuperview()
        emailInputView.resetTimerAndAll()
        twoFAInputView.resetTimerAndAll()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
        emailInputView.tfMaskView.changeBorderWith(isChoose:false)
        twoFAInputView.tfMaskView.changeBorderWith(isChoose:false)

        emailInputView.textField.sendActions(for: .valueChanged)
        twoFAInputView.textField.sendActions(for: .valueChanged)

        
        
    }
    // MARK: -
    // MARK:業務方法
    func setup() {
        addSubview(emailInputView)
        addSubview(twoFAInputView)
        addSubview(submitButton)
    }
    func bindStyle()
    {
        InputViewStyleThemes.emailInputHeightType.bind(to: emailHeightConstraint.rx.constant).disposed(by: dpg)
        InputViewStyleThemes.twoFAInputHeightType.bind(to: twoFAHeightConstraint.rx.constant).disposed(by: dpg)
    }
    func resetUI()
    {
        switch twoFAViewMode {
        case .both:
            setupEmailInputView()
            setupTwoFAInputView(withTop: true)
            bindStyle()
        case .onlyEmail:
            setupEmailInputView()
            twoFAInputView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            twoFAInputView.isHidden = true
        case .onlyTwoFA:
            setupTwoFAInputView()
            emailInputView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            emailInputView.isHidden = true
        }
        lostTwoFALabel.text = "Lost google 2FA?".localized
        lostTwoFALabel.textColor = Themes.gray707EAE
        lostTwoFALabel.snp.remakeConstraints { (make) in
            make.top.equalTo(twoFAInputView.snp.bottom)
            make.leading.equalToSuperview().offset(32)
        }
        lostTwoFALabel.isHidden = (twoFAViewMode == .both ? false :true)
        submitButton.snp.remakeConstraints { (make) in
            make.top.equalTo(lostTwoFALabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
    }
    func setupEmailInputView()
    {
        emailHeightConstraint = NSLayoutConstraint(item: emailInputView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewDefaultHeight))
        emailInputView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
//            make.height.equalTo(Themes.inputViewDefaultHeight)
            make.height.equalTo(emailHeightConstraint.constant)
        }
        emailInputView.addConstraint(emailHeightConstraint)
    }
    func setupTwoFAInputView(withTop:Bool = false)
    {
        twoFAHeightConstraint = NSLayoutConstraint(item: twoFAInputView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewDefaultHeight))
        twoFAInputView.snp.remakeConstraints { (make) in
            if withTop == true
            {
                make.top.equalTo(emailInputView.snp.bottom)
            }else
            {
                make.top.equalToSuperview()
            }
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
//            make.height.equalTo(Themes.inputViewDefaultHeight)
            make.height.equalTo(twoFAHeightConstraint.constant)
        }
        twoFAInputView.addConstraint(twoFAHeightConstraint)
    }
    func bind()
    {
//        bindBorderColor()
        bindCancelButton()
        bindLostTwoFALabel()
        bindAction()
    }
 
    func bindTextfield()
    {
        let isEmailValid = emailInputView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let _ = self, let acc = str else { return false  }
                if (self?.emailInputView.textField.isFirstResponder) != true
                {
                    self?.emailInputView.invalidLabel.isHidden = true
                }
                return RegexHelper.match(pattern: .otp, input: acc)
        }
        let isTwoFAValid = twoFAInputView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let _ = self, let acc = str else { return false  }
                if (self?.twoFAInputView.textField.isFirstResponder) != true
                {
                    self?.twoFAInputView.invalidLabel.isHidden = true
                }
                return RegexHelper.match(pattern: .otp, input: acc)
        }
        switch twoFAViewMode {
        case .both:
            let isEmailHeightType = emailInputView.textField.rx.text
                .map { [weak self] (str) -> InputViewHeightType in
                    guard let strongSelf = self, let acc = str else { return .emailInvalidHidden }
                    if ((strongSelf.emailInputView.textField.isFirstResponder) == true) {
                        let patternValue = RegexHelper.Pattern.otp

                        let resultValue:InputViewHeightType = RegexHelper.match(pattern: patternValue, input: acc) == true ? .emailInvalidHidden : (acc.isEmpty == true ? .emailInvalidShow : .emailInvalidShow)
                        if resultValue == .emailInvalidShow
                        {
                            strongSelf.emailInputView.invalidLabel.isHidden = false
                        }else
                        {
                            strongSelf.emailInputView.invalidLabel.isHidden = true
                        }
                        return resultValue
                    }else
                    {
                        if strongSelf.emailInputView.invalidLabel.textColor == .red
                        {
                            return .emailInvalidShow
                        }
                        return .emailInvalidHidden
                    }
            }
            isEmailHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: dpg)
            let isTwoFAHeightType = twoFAInputView.textField.rx.text
                .map { [weak self] (str) -> InputViewHeightType in
                    guard let strongSelf = self, let acc = str else { return .twoFAInvalidHidden }
                    if ((strongSelf.twoFAInputView.textField.isFirstResponder) == true) {
                        let patternValue = RegexHelper.Pattern.otp

                        let resultValue:InputViewHeightType = RegexHelper.match(pattern: patternValue, input: acc) == true ? .twoFAInvalidHidden : (acc.isEmpty == true ? .twoFAInvalidShow : .twoFAInvalidShow)
                        if resultValue == .twoFAInvalidShow
                        {
                            strongSelf.twoFAInputView.invalidLabel.isHidden = false
                        }else
                        {
                            strongSelf.twoFAInputView.invalidLabel.isHidden = true
                        }
                        return resultValue
                    }else
                    {
                        if strongSelf.twoFAInputView.invalidLabel.textColor == .red
                        {
                            return .twoFAInvalidShow
                        }
                        return .twoFAInvalidHidden
                    }
            }
            isTwoFAHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: dpg)
//            isEmailValid.skip(1).bind(to: emailInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
//            isTwoFAValid.skip(1).bind(to: twoFAInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
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
//        let _ =  emailInputView.textField.rx.text.map({$0 ?? ""})
//            .map({$0.isEmpty})
//            .bind(to: emailInputView.cancelRightButton.rx.isHidden)
//            .disposed(by: dpg)
//        let _ =  twoFAInputView.textField.rx.text.map({$0 ?? ""})
//            .map({$0.isEmpty})
//            .bind(to: twoFAInputView.cancelRightButton.rx.isHidden)
//            .disposed(by: dpg)
    }
    func bindBorderColor()
    {
        emailInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText(email:isChoose)
            resetTFMaskView(email: isChoose)
            resetInputView(view: twoFAInputView)
            if isChoose == false
            {
                twoFAInputView.textField.becomeFirstResponder()
            }
        }.disposed(by: dpg)
        twoFAInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText(twoFA:isChoose)
            resetTFMaskView(twoFA: isChoose)
           
        }.disposed(by: dpg)
    }
    func resetInvalidText(email:Bool = false ,twoFA:Bool = false )
    {
        if email == true
        {
            emailInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
        if twoFA == true
        {
            twoFAInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
    }
    func resetTFMaskView(email:Bool = false ,twoFA:Bool = false ,force:Bool = false)
    {
        if emailInputView.invalidLabel.textColor != .red || force == true
        {
            emailInputView.tfMaskView.changeBorderWith(isChoose:email)
        }
        if twoFAInputView.invalidLabel.textColor != .red || force == true
        {
            twoFAInputView.tfMaskView.changeBorderWith(isChoose:twoFA)
        }
    }
    func resetInputView(view : InputStyleView)
    {
        if view.invalidLabel.textColor != .red
        {
            view.invalidLabel.isHidden = true
        }
    }
    func bindLostTwoFALabel()
    {
        lostTwoFALabel.rx.click.subscribeSuccess { [self](_) in
            onLostGoogleClick.onNext(())
        }.disposed(by: dpg)
    }
    func cleanTextField() {
        emailInputView.textField.text = ""
        emailInputView.textField.sendActions(for: .valueChanged)
        twoFAInputView.textField.text = ""
        twoFAInputView.textField.sendActions(for: .valueChanged)
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
                onSubmitBothClick.onNext((emailString,twoFAString))
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
        return onSubmitBothClick.asObserver()
    }
    func rxSubmitOnlyEmailAction() -> Observable<(String)>
    {
        return onSubmitOnlyEmailClick.asObserver()
    }
    func rxSubmitOnlyTwiFAAction() -> Observable<(String)>
    {
        return onSubmitOnlyTwoFAClick.asObserver()
    }
    func rxLostGoogleAction() -> Observable<(Any)>
    {
        return onLostGoogleClick.asObserver()
    }
    func cleanTimer()
    {
        emailInputView.resetTimerAndAll()
    }
}
// MARK: -
// MARK: 延伸
