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
        }
    }
    
    // MARK: -
    // MARK:UI 設定
    var emailInputView = InputStyleView(inputViewMode: .emailVerify)
    var twoFAInputView = InputStyleView(inputViewMode: .twoFAVerify)
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
    // MARK: -
    // MARK:業務方法
    func setup() {
        addSubview(emailInputView)
        addSubview(twoFAInputView)
        addSubview(submitButton)
    }
    func resetUI()
    {
        let defaultHeight : CGFloat = 90
        var bottomY : CGFloat = 90
        switch twoFAViewMode {
        case .both:
            setupEmailInputView(withTop: 0)
            setupTwoFAInputView(withTop: defaultHeight)
            bottomY = 90 * 2.0
        case .onlyEmail:
            setupEmailInputView(withTop: 0)
            twoFAInputView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            twoFAInputView.isHidden = true
        case .onlyTwoFA:
            setupTwoFAInputView(withTop: 0)
            emailInputView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            emailInputView.isHidden = true
        }
        lostTwoFALabel.text = "Lost google 2FA?".localized
        lostTwoFALabel.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(bottomY)
            make.leading.equalToSuperview().offset(32)
        }
        lostTwoFALabel.isHidden = (twoFAViewMode == .both ? false :true)
        submitButton.snp.remakeConstraints { (make) in
            make.top.equalTo(lostTwoFALabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
    }
    func setupEmailInputView(withTop:CGFloat)
    {
        emailInputView.snp.remakeConstraints { (make) in
            make.top.equalTo(withTop)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Themes.inputViewDefaultHeight)
        }
    }
    func setupTwoFAInputView(withTop:CGFloat)
    {
        twoFAInputView.snp.remakeConstraints { (make) in
            make.top.equalTo(withTop)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(Themes.inputViewDefaultHeight)
        }
    }
    func bind()
    {
        bindUI()
        bindCancelButton()
        bindLostTwoFALabel()
        bindAction()
    }
    func bindUI()
    {
        emailInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            emailInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
            twoFAInputView.tfMaskView.changeBorderWith(isChoose:false)
        }.disposed(by: dpg)
        twoFAInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            emailInputView.tfMaskView.changeBorderWith(isChoose:false)
            twoFAInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
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
