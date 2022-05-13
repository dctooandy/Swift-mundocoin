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
import Toaster

enum InputViewMode {
    case emailVerify
    case twoFAVerify
    case copy
    case withdrawTo
    case email
    case phone
    case password
    case forgotPW
    case registration
    
    func topString() -> String {
        switch self {
        case .emailVerify: return "Enter the 6-digit code sent to ".localized
        case .twoFAVerify: return "Enter the 6-digit code from google 2FA".localized
        case .copy: return "Copy this key to your authenticator app".localized
        case .withdrawTo: return "Withdraw to address".localized
        case .email: return "Email".localized
        case .phone: return "Phone Number".localized
        case .password: return "Password".localized
        case .forgotPW: return "Enter your email to change your password".localized
        case .registration: return "Registration code".localized
        }
    }
    
    func textPlacehloder() -> String {
        switch self {
        case .emailVerify: return "Email verification code".localized
        case .twoFAVerify: return "Google Authenticator code".localized
        case .withdrawTo: return "Long press to paste".localized
        case .email: return "...@mundo.com"
        case .password: return "********".localized
        case .forgotPW: return "...@mundo.com"
        default: return ""
        }
    }
    
    func invaildString() -> String {
        switch self {
        case .emailVerify: return "Invaild verification code".localized
        case .twoFAVerify: return "Invaild verification code".localized
        case .withdrawTo: return "Please check the withdrawal address.".localized
        case .email: return "Incorrect email format.".localized
        case .phone: return "Invalid phone number.".localized
        case .password: return "8-20 charaters with any combination or letters, numbers, and symbols.".localized
        case .forgotPW: return "Incorrect email format.".localized
        case .registration: return "Invalid registration code".localized
        default: return ""
        }
    }
    func rightLabelString() -> String
    {
        switch self {
        case .emailVerify: return "Send".localized
        case .twoFAVerify: return "Paste".localized
        case .copy: return "Copy".localized
        default: return ""
        }
    }
}
class InputStyleView: UIView {
    // MARK:業務設定
    private var inputViewMode: InputViewMode = .email
//    private var inputMode: InputViewMode = .email
//    private var currentShowMode: ShowMode = .loginEmail
    private let displayPwdImg = UIImage(named: "eye-solid")!.withRenderingMode(.alwaysTemplate)
    private let undisplayPwdImg =  UIImage(named: "eye-slash-solid")!.withRenderingMode(.alwaysTemplate)
    private let cancelImg = UIImage(named: "icon-close")!
    private let addressBookImgView : UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "arrow-circle-right"))
        return imgView
    }()
    private let cameraImgView : UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "arrow-circle-right"))
        return imgView
    }()
    private let onClick = PublishSubject<String>()
    private let onSendClick = PublishSubject<Any>()
    private let onPasteClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    private var isPWStyle : Bool = false
    private var isRegisterStyle : Bool = false
    private var timer: Timer?
    private var countTime = 60
    var offetWidth : CGFloat = 0.0
    // MARK: -
    // MARK:UI 設定
    let topLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.textColor = .black
        lb.text = "Email".localized
        lb.font = Fonts.pingFangSCRegular(14)
        return lb
    }()
    let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = Fonts.sfProLight(16)
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
    let verifyResentLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = .black
        lb.text = "Send".localized
        lb.font = Fonts.pingFangTCSemibold(14)
        return lb
    }()
    let displayRightButton = UIButton()
    let cancelRightButton = UIButton()
    
    // MARK: -
    // MARK:Life cycle
    convenience init(inputViewMode: InputViewMode = .email, isPWStyle:Bool = false , isRegisterStyle: Bool = false) {
        self.init(frame: .zero)
        self.inputViewMode = inputViewMode
        self.isPWStyle = isPWStyle
        self.isRegisterStyle = isRegisterStyle
//        self.currentShowMode = currentShowMode
        self.setup()
        self.bindPwdButton()
        self.bindTextfield()
        self.bindCancelButton()
        timer?.invalidate()
    }
    convenience init(inputViewMode: InputViewMode = .emailVerify) {
        self.init(frame: .zero)
        self.inputViewMode = inputViewMode
        self.isPWStyle = false
        self.isRegisterStyle = false
//        self.currentShowMode = currentShowMode
        self.setup()
        self.bindPwdButton()
        self.bindTextfield()
        self.bindCancelButton()
        timer?.invalidate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func removeFromSuperview() {
        super.removeFromSuperview()
        timer?.invalidate()
        timer = nil
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
        var topLabelString = ""
        var placeHolderString = ""
        var invalidLabelString = ""
        var rightLabelWidth : CGFloat = 0.0
        offetWidth = (inputViewMode == .password ? 24.0:0.0)
        textField.isSecureTextEntry = (inputViewMode == .password)
        topLabelString = inputViewMode.topString()
        placeHolderString = inputViewMode.textPlacehloder()
        invalidLabelString = inputViewMode.invaildString()
        cancelRightButton.isHidden = ( inputViewMode == .copy ? true : false)
        textField.isUserInteractionEnabled = ( inputViewMode == .copy ? false : true)
        if inputViewMode != .withdrawTo
        {
            addSubview(verifyResentLabel)
            verifyResentLabel.text = inputViewMode.rightLabelString()
            rightLabelWidth = verifyResentLabel.intrinsicContentSize.width
            verifyResentLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-10)
                make.centerY.equalTo(textField)
            }
        }
        topLabel.text = topLabelString
        invalidLabel.text = invalidLabelString
        textField.setPlaceholder(placeHolderString, with: Themes.grayLighter)
        
        addSubview(displayRightButton)
        displayRightButton.frame.size.width = 24
        displayRightButton.setTitle(nil, for: .normal)
        displayRightButton.setBackgroundImage(displayPwdImg, for: .normal)
        displayRightButton.snp.remakeConstraints { (make) in
            make.right.equalToSuperview().offset(-10 - rightLabelWidth)
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
        let rightView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 34 + rightLabelWidth + offetWidth , height: 10))
        textField.rightViewMode = .always
        textField.rightView = rightView
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
        verifyResentLabel.rx.click
            .subscribeSuccess { [weak self] in
                self?.verifyResentPressed()
        }.disposed(by: dpg)
    }
    func bindTextfield()
    {
        
    }
    func bindCancelButton()
    {
        
    }
//    func changeInputMode(mode: LoginMode) {
//        inputMode = mode
//        resetUI()
//    }
    private func displayRightPressed() {
        textField.isSecureTextEntry = !(textField.isSecureTextEntry)
        displayRightButton.setBackgroundImage(textField.isSecureTextEntry ? displayPwdImg : undisplayPwdImg , for: .normal)
    }
    private func cancelButtonPressed() {
        textField.text = ""
        cancelRightButton.isHidden = true
        textField.sendActions(for: .valueChanged)
    }
    private func verifyResentPressed() {
        switch inputViewMode {
        case .emailVerify:
            emailSendVerify()
        case .twoFAVerify:
            pasteStringToTF()
        case .copy:
            copyStringToTF()
        default:
            break
        }
        cancelRightButton.isHidden = true
        textField.sendActions(for: .valueChanged)
    }
    func emailSendVerify()
    {
        Log.v("重發驗證")
        if self.timer == nil
        {
            verifyResentLabel.isUserInteractionEnabled = false
            setupTimer()
            sendRequestForVerify()
        }
    }
    func resetDisplayBtnUI()
    {
        var rightLabelWidth : CGFloat = 0.0
        rightLabelWidth = verifyResentLabel.intrinsicContentSize.width
        displayRightButton.snp.updateConstraints { (make) in
            make.right.equalToSuperview().offset(-10 - rightLabelWidth)
        }
        let rightView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20 + rightLabelWidth + 14 + offetWidth , height: 10))
        textField.rightView = nil
        textField.rightViewMode = .always
        textField.rightView = rightView
    }
    func setupTimer()
    {
        timer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
    }

    @objc func countDown()
    {
        print("count timer: \(countTime)")
        countTime -= 1
        if countTime == 0 {
//            tfRightBtn.setImageTitle(image: nil, title: rightBtnTitle())
//            tfRightBtn.isEnabled = true
            resetTimerAndAll()
            return
        }
        verifyResentLabel.text = "Resend in ".localized + "\(countTime) s"
        verifyResentLabel.textColor = UIColor(rgb: 0xB5B5B5)
        resetDisplayBtnUI()
    }
    func pasteStringToTF()
    {
        if let string = UIPasteboard.general.string
        {
            textField.text = string
        }
    }
    func copyStringToTF()
    {
        UIPasteboard.general.string = textField.text
        Toast.show(msg: "Copied")
    }
    func resetTimerAndAll()
    {
        verifyResentLabel.text = "Send".localized
        verifyResentLabel.textColor = .black
        resetDisplayBtnUI()
        timer?.invalidate()
        timer = nil
        countTime = 60
        verifyResentLabel.isUserInteractionEnabled = true
    }
    func sendRequestForVerify()
    {
        onSendClick.onNext(())
    }
    func rxSendVerifyAction() -> Observable<(Any)>
    {
        return onSendClick.asObserver()
    }
    func rxPasteAction() -> Observable<(Any)>
    {
        return onPasteClick.asObserver()
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
