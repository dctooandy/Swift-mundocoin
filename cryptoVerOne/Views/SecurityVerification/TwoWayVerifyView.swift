//
//  TwoWayVerifyView.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/21.
//


import Foundation
import UIKit
import RxCocoa
import RxSwift
import Toaster

enum TwoWayViewMode {
    case both
    case onlyEmail
    case onlyMobile
}
class TwoWayVerifyView: UIView {
    // MARK:業務設定
    private let onEmailSecondSendVerifyClick = PublishSubject<Any>()
    private let onMobileSecondSendVerifyClick = PublishSubject<Any>()
//    private let onSecondSendVerifyClick = PublishSubject<Any>()
    private let onSubmitBothClick = PublishSubject<(String,String)>()
    private let onSubmitOnlyEmailClick = PublishSubject<String>()
    private let onSubmitOnlyMobileClick = PublishSubject<String>()
    private let onLostGoogleClick = PublishSubject<Any>()
    private var dpg = DisposeBag()
    private var isNetWorkConnectIng = false
    var twoWayViewMode : TwoWayViewMode = .both {
        didSet{
            dpg = DisposeBag()
            resetUI()
            bindTextfield()
            bindBorderColor()
            bind()
        }
    }
    var emailHeightConstraint : NSLayoutConstraint!
    var mobileHeightConstraint : NSLayoutConstraint!
//    var twoFAHeightConstraint : NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    var emailInputView = InputStyleView(inputViewMode: .emailVerify(MemberAccountDto.share?.email ?? ""))
    var mobileInputView = InputStyleView(inputViewMode: .mobileVerify(MemberAccountDto.share?.phone ?? ""))
//    var twoFAInputView = InputStyleView(inputViewMode: .twoFAVerify)
//    @IBOutlet weak var lostTwoFALabel: UILabel!
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
        mobileInputView.resetTimerAndAll()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
        emailInputView.tfMaskView.changeBorderWith(isChoose:false)
        mobileInputView.tfMaskView.changeBorderWith(isChoose:false)
        emailInputView.textField.sendActions(for: .valueChanged)
        mobileInputView.textField.sendActions(for: .valueChanged)
        InputViewStyleThemes.share.emailAcceptInputHeightStyle(.emailInvalidHidden)
    }
    // MARK: -
    // MARK:業務方法
    func setup() {
        addSubview(emailInputView)
        addSubview(mobileInputView)
        addSubview(submitButton)
    }
    func bindStyle()
    {
        InputViewStyleThemes.emailInputHeightType.bind(to: emailHeightConstraint.rx.constant).disposed(by: dpg)
        InputViewStyleThemes.mobileInputHeightType.bind(to: mobileHeightConstraint.rx.constant).disposed(by: dpg)
    }
    func resetUI()
    {
        switch twoWayViewMode {
        case .both:
            setupMobileInputView()
            setupEmailInputView(withTop: true)
            bindStyle()
        case .onlyEmail:
            setupEmailInputView()
            mobileInputView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            mobileInputView.isHidden = true
        case .onlyMobile:
            setupMobileInputView()
            emailInputView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            emailInputView.isHidden = true
        }
//        lostTwoFALabel.text = "Lost google 2FA?".localized
//        lostTwoFALabel.textColor = Themes.gray707EAE
//        lostTwoFALabel.snp.remakeConstraints { (make) in
////            if twoWayViewMode == .both
////            {
////                make.top.equalTo(twoFAInputView.snp.bottom)
////            }else
////            {
////                make.top.equalTo(emailInputView.snp.bottom)
////            }
//            make.leading.equalToSuperview().offset(32)
//        }
//        lostTwoFALabel.isHidden = (twoWayViewMode == .both ? false :true)
        submitButton.snp.remakeConstraints { (make) in
            if twoWayViewMode == .both
            {
                make.top.equalTo(emailInputView.snp.bottom).offset(10)
            }else if twoWayViewMode == .onlyEmail
            {
                make.top.equalTo(emailInputView.snp.bottom).offset(10)
            }else if twoWayViewMode == .onlyMobile
            {
                make.top.equalTo(mobileInputView.snp.bottom).offset(10)
            }
//            make.top.equalTo(lostTwoFALabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
    }
    func setupEmailInputView(withTop:Bool = false)
    {
        emailHeightConstraint = NSLayoutConstraint(item: emailInputView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewDefaultHeight))
        emailInputView.snp.remakeConstraints { (make) in
            if withTop == true
            {
                make.top.equalTo(mobileInputView.snp.bottom)
            }else
            {
                make.top.equalToSuperview()
            }
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
//            make.height.equalTo(Themes.inputViewDefaultHeight)
            make.height.equalTo(emailHeightConstraint.constant)
        }
        emailInputView.addConstraint(emailHeightConstraint)
    }
    func setupMobileInputView()
    {
        mobileHeightConstraint = NSLayoutConstraint(item: mobileInputView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewDefaultHeight))
        mobileInputView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
//            make.height.equalTo(Themes.inputViewDefaultHeight)
            make.height.equalTo(mobileHeightConstraint.constant)
        }
        mobileInputView.addConstraint(mobileHeightConstraint)
    }
//    func setupTwoFAInputView(withTop:Bool = false)
//    {
//        twoFAHeightConstraint = NSLayoutConstraint(item: twoFAInputView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(Themes.inputViewDefaultHeight))
//        twoFAInputView.snp.remakeConstraints { (make) in
//            if withTop == true
//            {
//                make.top.equalTo(emailInputView.snp.bottom)
//            }else
//            {
//                make.top.equalToSuperview()
//            }
//            make.leading.equalToSuperview().offset(28)
//            make.trailing.equalToSuperview().offset(-28)
////            make.height.equalTo(Themes.inputViewDefaultHeight)
//            make.height.equalTo(twoFAHeightConstraint.constant)
//        }
//        twoFAInputView.addConstraint(twoFAHeightConstraint)
//    }
    func bind()
    {
//        bindBorderColor()
        bindCancelButton()
//        bindLostTwoFALabel()
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
        let isMobileValid = mobileInputView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let _ = self, let acc = str else { return false  }
                if (self?.mobileInputView.textField.isFirstResponder) != true
                {
                    self?.mobileInputView.invalidLabel.isHidden = true
                }
                return RegexHelper.match(pattern: .otp, input: acc)
        }
        switch twoWayViewMode {
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
            let isMobileHeightType = mobileInputView.textField.rx.text
                .map { [weak self] (str) -> InputViewHeightType in
                    guard let strongSelf = self, let acc = str else { return .twoFAInvalidHidden }
                    if ((strongSelf.mobileInputView.textField.isFirstResponder) == true) {
                        let patternValue = RegexHelper.Pattern.otp

                        let resultValue:InputViewHeightType = RegexHelper.match(pattern: patternValue, input: acc) == true ? .mobileInvalidHidden : (acc.isEmpty == true ? .mobileInvalidShow : .mobileInvalidShow)
                        if resultValue == .mobileInvalidShow
                        {
                            strongSelf.mobileInputView.invalidLabel.isHidden = false
                        }else
                        {
                            strongSelf.mobileInputView.invalidLabel.isHidden = true
                        }
                        return resultValue
                    }else
                    {
                        if strongSelf.mobileInputView.invalidLabel.textColor == .red
                        {
                            return .mobileInvalidShow
                        }
                        return .mobileInvalidHidden
                    }
            }
            isMobileHeightType.bind(to: InputViewStyleThemes.share.rx.isShowInvalid).disposed(by: dpg)
//            isEmailValid.skip(1).bind(to: emailInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
//            isTwoFAValid.skip(1).bind(to: twoFAInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
            Observable.combineLatest(isEmailValid, isMobileValid)
                .map { return $0.0 && $0.1 } //reget match result
                .bind(to: submitButton.rx.isEnabled)
                .disposed(by: dpg)
        case .onlyEmail:
            isEmailValid.skip(1).bind(to: emailInputView.invalidLabel.rx.isHidden)
                .disposed(by: dpg)
            isEmailValid.bind(to: submitButton.rx.isEnabled).disposed(by: dpg)
        case .onlyMobile:
            isMobileValid.skip(1).bind(to: mobileInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
            isMobileValid.bind(to: submitButton.rx.isEnabled).disposed(by: dpg)
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
        mobileInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText(mobile:isChoose)
            resetTFMaskView(mobile: isChoose)
            resetInputView(view: emailInputView)
            if isChoose == false
            {
                emailInputView.textField.becomeFirstResponder()
            }
        }.disposed(by: dpg)
        emailInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            resetInvalidText(email:isChoose)
            resetTFMaskView(email: isChoose)
        }.disposed(by: dpg)
    }
    func resetInvalidText(email:Bool = false ,mobile:Bool = false )
    {
        if email == true
        {
            emailInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
        if mobile == true
        {
            mobileInputView.changeInvalidLabelAndMaskBorderColor(with:"")
        }
    }
    func resetTFMaskView(email:Bool = false ,mobile:Bool = false ,force:Bool = false)
    {
        if emailInputView.invalidLabel.textColor != .red || force == true
        {
            emailInputView.tfMaskView.changeBorderWith(isChoose:email)
        }
        if mobileInputView.invalidLabel.textColor != .red || force == true
        {
            mobileInputView.tfMaskView.changeBorderWith(isChoose:mobile)
        }
    }
    func resetInputView(view : InputStyleView)
    {
        if view.invalidLabel.textColor != .red
        {
            view.invalidLabel.isHidden = true
        }
    }
//    func bindLostTwoFALabel()
//    {
//        lostTwoFALabel.rx.click.subscribeSuccess { [self](_) in
//            onLostGoogleClick.onNext(())
//        }.disposed(by: dpg)
//    }
    func cleanTextField() {
        emailInputView.textField.text = ""
        emailInputView.textField.sendActions(for: .valueChanged)
        mobileInputView.textField.text = ""
        mobileInputView.textField.sendActions(for: .valueChanged)
        emailInputView.invalidLabel.isHidden = true
        mobileInputView.invalidLabel.isHidden = true
    }
    func bindAction()
    {
        emailInputView.rxSendVerifyAction().subscribeSuccess { [weak self](_) in
            self?.onEmailSecondSendVerifyClick.onNext(())
        }.disposed(by: dpg)
        mobileInputView.rxSendVerifyAction().subscribeSuccess { [weak self](_) in
            self?.onMobileSecondSendVerifyClick.onNext(())
        }.disposed(by: dpg)
        submitButton.rx.tap.subscribeSuccess { [self](_) in
            submitButton.isEnabled = false
            if isNetWorkConnectIng != true
            {
                isNetWorkConnectIng = true
                submitAction()
            }
        }.disposed(by: dpg)
    }
    func resetProperty()
    {
        isNetWorkConnectIng = false
    }
    func submitAction()
    {
        switch self.twoWayViewMode {
        case .both:
            if let emailString = self.emailInputView.textField.text,
               let mobileString = self.mobileInputView.textField.text
            {
                onSubmitBothClick.onNext((mobileString,emailString))
            }
        case .onlyEmail:
            if let emailString = self.emailInputView.textField.text
            {
                onSubmitOnlyEmailClick.onNext((emailString))
            }
        case .onlyMobile:
            if let mobileString = self.mobileInputView.textField.text
            {
                onSubmitOnlyMobileClick.onNext((mobileString))
            }
        }
    }
    
    func rxEmailSecondSendVerifyAction() -> Observable<(Any)>
    {
        return onEmailSecondSendVerifyClick.asObserver()
    }
    func rxMobileSecondSendVerifyAction() -> Observable<(Any)>
    {
        return onMobileSecondSendVerifyClick.asObserver()
    }
    func rxSubmitBothAction() -> Observable<(String,String)>
    {
        return onSubmitBothClick.asObserver()
    }
    func rxSubmitOnlyEmailAction() -> Observable<(String)>
    {
        return onSubmitOnlyEmailClick.asObserver()
    }
    func rxSubmitOnlyMobileAction() -> Observable<(String)>
    {
        return onSubmitOnlyMobileClick.asObserver()
    }
    func rxLostGoogleAction() -> Observable<(Any)>
    {
        return onLostGoogleClick.asObserver()
    }
    func cleanTimer()
    {
        emailInputView.resetTimerAndAll()
        mobileInputView.resetTimerAndAll()
    }
}
// MARK: -
// MARK: 延伸
