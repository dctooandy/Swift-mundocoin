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
import DropDown

enum InputViewMode :Equatable {
    case emailVerify
    case twoFAVerify
    case copy
    case withdrawToAddress
    case email
    case phone
    case password
    case forgotPW
    case registration
    case networkMethod(Array<String>)
    case withdrawTo(Bool)
    case txid
    
    func topString() -> String {
        switch self {
        case .emailVerify: return "Enter the 6-digit code sent to ".localized
        case .twoFAVerify: return "Enter the 6-digit code from google 2FA".localized
        case .copy: return "Copy this key to your authenticator app".localized
        case .withdrawToAddress: return "Withdraw to address".localized
        case .email: return "Email".localized
        case .phone: return "Phone Number".localized
        case .password: return "Password".localized
        case .forgotPW: return "Enter your email to change your password".localized
        case .registration: return "Registration code".localized
        case .networkMethod( _ ): return "Network Method".localized
        case .withdrawTo( _ ): return "Withdraw to".localized
        case .txid: return "Txid".localized
        }
    }
    
    func textPlacehloder() -> String {
        switch self {
        case .emailVerify: return "Email verification code".localized
        case .twoFAVerify: return "Google Authenticator code".localized
        case .withdrawToAddress: return "Long press to paste".localized
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
        case .withdrawToAddress: return "Please check the withdrawal address.".localized
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
    func dropDataSource() -> Array<String>
    {
        switch self {
        case .networkMethod(let array):
            return array
        default:
            return []
        }
    }
    func isNetworkMethod() -> Bool
    {
        switch self {
        case .networkMethod( _ ):
            return true
        default:
            return false
        }
    }
}
class InputStyleView: UIView {
    // MARK:業務設定
    private var inputViewMode: InputViewMode = .email
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
    private let onAddressBookClick = PublishSubject<Any>()
    private let onScanClick = PublishSubject<Any>()
    private let onAddAddressClick = PublishSubject<String>()
    private let onTextLabelClick = PublishSubject<String>()
    private let dpg = DisposeBag()
    private var timer: Timer?
    private var countTime = 60
    var displayOffetWidth : CGFloat = 0.0
    var cancelOffetWidth : CGFloat = 0.0
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
    let textLabel: UnderlinedLabel = {
        let tfLabel = UnderlinedLabel()
        tfLabel.backgroundColor = .clear
        tfLabel.font = Fonts.sfProLight(16)
        tfLabel.numberOfLines = 0
        tfLabel.adjustsFontSizeToFitWidth = true
        tfLabel.minimumScaleFactor = 0.5
        tfLabel.isUserInteractionEnabled = true
        return tfLabel
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
    let addressBookImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "launch-logo")
        return imgView
    }()
    let scanImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "launch-logo")
        return imgView
    }()
    let addAddressImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "arrow-circle-right")
        return imgView
    }()
    let copyAddressImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "arrow-circle-right")
        return imgView
    }()
    let displayRightButton = UIButton()
    let cancelRightButton = UIButton()
    //DropDown
    lazy var chooseButton:UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        return btn
    }()
    let chooseDropDown = DropDown()
    let anchorView : UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: -
    // MARK:Life cycle
    convenience init(inputViewMode: InputViewMode = .email) {
        self.init(frame: .zero)
        self.inputViewMode = inputViewMode
        self.setup()
        self.bindPwdButton()
        self.bindImageView()
        self.bindTextfield()
        self.bindLabel()
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
        let topLabelH = height(17/812)
        let invalidH = height(20/812)
        topLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(topLabelH)
        }
        invalidLabel.snp.makeConstraints { (make) in
            make.left.equalTo(textField)
            make.height.equalTo(invalidH)
            make.bottom.equalToSuperview()
        }
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(height(5/812)).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(invalidLabel.snp.top).offset(-8)
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
        displayOffetWidth = (inputViewMode == .password ? 24.0:0.0)
        switch self.inputViewMode {
        case .copy ,.networkMethod(_), .withdrawTo(_) ,.txid:
            cancelOffetWidth = 0.0
            textField.isUserInteractionEnabled = false
        default:
            cancelOffetWidth = 14.0
            textField.isUserInteractionEnabled = true
        }
        textField.isSecureTextEntry = (inputViewMode == .password)
        topLabelString = inputViewMode.topString()
        placeHolderString = inputViewMode.textPlacehloder()
        invalidLabelString = inputViewMode.invaildString()
     
        if inputViewMode == .emailVerify ||
            inputViewMode == .twoFAVerify ||
            inputViewMode == .copy
        {
            addSubview(verifyResentLabel)
            verifyResentLabel.text = inputViewMode.rightLabelString()
            verifyResentLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-10)
                make.centerY.equalTo(textField)
            }
            rightLabelWidth = verifyResentLabel.intrinsicContentSize.width
        }else if inputViewMode == .withdrawToAddress
        {
            addSubview(scanImageView)
            addSubview(addressBookImageView)
            scanImageView.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-10)
                make.centerY.equalTo(textField)
                make.size.equalTo(18)
            }
            addressBookImageView.snp.makeConstraints { (make) in
                make.right.equalTo(scanImageView.snp.left).offset(-10)
                make.centerY.equalTo(textField)
                make.size.equalTo(18)
            }
            rightLabelWidth = 18 + 18 + 10
        }else if inputViewMode.isNetworkMethod()
        {
            textField.text = "TRC20"
            let textFieldMulH = height(48/812)
            let tfWidth = width(361.0/414.0) - 40
            addSubview(chooseButton)
            addSubview(anchorView)
            anchorView.snp.makeConstraints { (make) in
                make.top.equalTo(textField.snp.bottom)
                make.height.equalTo(textFieldMulH)
                make.centerX.equalToSuperview()
                make.width.equalTo(tfWidth)
            }
            chooseButton.snp.makeConstraints { (make) in
                make.edges.equalTo(textField)
            }
            setupChooseDropdown()
            bindChooseButton()
        }else if inputViewMode == .withdrawTo(true)
        {
            addSubview(addAddressImageView)
            addSubview(copyAddressImageView)
            copyAddressImageView.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-10)
                make.centerY.equalTo(textField)
                make.size.equalTo(18)
            }
            addAddressImageView.snp.makeConstraints { (make) in
                make.right.equalTo(copyAddressImageView.snp.left).offset(-10)
                make.centerY.equalTo(textField)
                make.size.equalTo(18)
            }
            rightLabelWidth = 18 + 18 + 10
        }else if inputViewMode == .txid
        {
            addSubview(textLabel)
            textLabel.snp.makeConstraints { (make) in
                make.left.top.bottom.equalTo(textField)
                make.right.equalToSuperview().offset(-35)
            }
            addSubview(copyAddressImageView)
            copyAddressImageView.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-10)
                make.centerY.equalTo(textField)
                make.size.equalTo(18)
            }
            rightLabelWidth = 18 + 10
        }else
        {
            rightLabelWidth = 10
        }
        
        topLabel.text = topLabelString
        invalidLabel.text = invalidLabelString
        textField.setPlaceholder(placeHolderString, with: Themes.grayLighter)
        
        addSubview(displayRightButton)
        displayRightButton.setTitle(nil, for: .normal)
        displayRightButton.setBackgroundImage(displayPwdImg, for: .normal)
        displayRightButton.snp.remakeConstraints { (make) in
            make.right.equalToSuperview().offset(-10 - rightLabelWidth)
            make.centerY.equalTo(textField)
            make.height.equalTo(24)
            make.width.equalTo(displayOffetWidth)
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
            make.height.equalTo(14)
            make.width.equalTo(cancelOffetWidth)
        }

        let rightView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10 + rightLabelWidth + displayOffetWidth + cancelOffetWidth , height: 10))
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
    func bindImageView()
    {
        scanImageView.rx.click.subscribeSuccess { [self](_) in
            self.onScanClick.onNext(())
        }.disposed(by: dpg)
        addressBookImageView.rx.click.subscribeSuccess { [self](_) in
            self.onAddressBookClick.onNext(())
        }.disposed(by: dpg)
        
        copyAddressImageView.rx.click.subscribeSuccess { [self](_) in
            copyStringToTF()
        }.disposed(by: dpg)
        addAddressImageView.rx.click.subscribeSuccess { [self](_) in
            self.onAddAddressClick.onNext(self.textField.text!)
        }.disposed(by: dpg)
    }
    func bindLabel()
    {
        textLabel.rx.click.subscribeSuccess { [self](_) in
            onTextLabelClick.onNext(textLabel.text!)
        }.disposed(by: dpg)
    }
    func bindTextfield()
    {
        
    }
    func bindCancelButton()
    {
        
    }
    func bindChooseButton()
    {
        chooseButton.rx.tap.subscribeSuccess { (_) in
            self.chooseDropDown.show()
        }.disposed(by: dpg)
    }
    func setupChooseDropdown()
    {
        DropDown.setupDefaultAppearance()
        chooseDropDown.anchorView = anchorView
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
//        chooseDropDown.bottomOffset = CGPoint(x: 0, y:(chooseDropDown.anchorView?.plainView.bounds.height)!)
        chooseDropDown.topOffset = CGPoint(x: 0, y:-(chooseDropDown.anchorView?.plainView.bounds.height)!)
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseDropDown.direction = .bottom
        switch inputViewMode {
        case .networkMethod(let array):
            chooseDropDown.dataSource = array
        default:
            break
        }
        
        // Action triggered on selection
        chooseDropDown.selectionAction = { [weak self] (index, item) in
//            self?.chooseButton.setTitle(item, for: .normal)
            self?.textField.text = item
        }
        chooseDropDown.dismissMode = .onTap
    }
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
        let rightView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10 + rightLabelWidth + displayOffetWidth + cancelOffetWidth , height: 10))
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
    func rxScanImagePressed() -> Observable<Any> {
        return onScanClick.asObserver()
    }
    func rxAddressBookImagePressed() -> Observable<Any> {
        return onAddressBookClick.asObserver()
    }
    func rxAddAddressImagePressed() -> Observable<String> {
        return onAddAddressClick.asObserver()
    }
    func rxTextLabelClick() -> Observable<String> {
        return onTextLabelClick.asObserver()
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
