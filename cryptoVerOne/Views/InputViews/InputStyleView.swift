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
    case emailVerify(String)
    case twoFAVerify
    case copy
    case withdrawToAddress // 取款頁面白名單關閉
    case address
    case email
    case phone
    case password
    case forgotPW
    case registration
    case networkMethod(Array<String>)
    case crypto(Array<String>)
    case withdrawAddressToConfirm
    case withdrawAddressToDetail(Bool)
    case withdrawAddressFromDetail
    case withdrawAddressInnerFromDetail
    case txid(String)
    case securityVerification
    case oldPassword
    case newPassword
    case confirmPassword
    case customLabel(String)
    
    case auditAccount
    case auditPassword
    
    func topString() -> String {
        switch self {
//        case .emailVerify(let emailString): return "Enter the 6-digit code sent to \(emailString)".localized
        case .emailVerify(let emailString): return "Sent to \(emailString)".localized
        case .twoFAVerify:
#if Approval_PRO || Approval_DEV || Approval_STAGE
            return "*Enter the 6-digit code from google 2FA".localized
#else
            return "Enter the 6-digit code from google 2FA".localized
#endif
        case .copy: return "Copy this key to your authenticator app".localized
        case .withdrawToAddress: return "Withdraw to address".localized
        case .address: return "Address".localized
        case .email: return "E-mail".localized
        case .phone: return "Phone Number".localized
        case .password: return "Password".localized
        case .forgotPW: return "Enter your email to change your password".localized
        case .registration: return "Registration code".localized
        case .networkMethod( _ ): return "Network Method".localized
        case .crypto( _ ): return "Crypto".localized
        case .withdrawAddressToConfirm: return "Withdraw to address".localized
        case .withdrawAddressToDetail(_): return "Withdraw to address".localized
        case .withdrawAddressFromDetail: return "From Address".localized
        case .withdrawAddressInnerFromDetail: return "From Mundocoin Address".localized
        case .txid( _ ): return "Txid".localized
        case .securityVerification: return "Security Verification".localized
        case .oldPassword: return "Old Password".localized
        case .newPassword: return "New Password".localized
        case .confirmPassword: return "Confirm New Password".localized
        case .customLabel(let title): return "\(title)"
        case .auditAccount : return "Admin /Email"
        case .auditPassword : return "Password"
        }
    }
    
    func textPlacehloder() -> String {
        switch self {
        case .emailVerify(_): return "Email verification code".localized
        case .twoFAVerify: return "Google Authenticator code".localized
        case .withdrawToAddress,.address: return "Long press to paste".localized
        case .email: return "...@mundocoin.com"
//        case .oldPassword,.password ,.newPassword , .confirmPassword: return "********".localized
        case .forgotPW: return "...@mundocoin.com"
        case .securityVerification: return "Enter the 6-digit code".localized
        case .auditAccount : return ""
        case .auditPassword : return ""
        default: return ""
        }
    }
    
    func invalidString() -> String {
        switch self {
        case .emailVerify(_): return "Enter the 6-digit code".localized
        case .twoFAVerify: return "Enter the 6-digit code".localized
        case .withdrawToAddress,.address: return "Please check the withdrawal address.".localized
        case .email: return "...@mundocoin.com".localized
        case .phone: return "Invalid phone number.".localized
        case .password ,.oldPassword ,.newPassword ,.confirmPassword: return "8-20 charaters with any combination or letters, numbers, and symbols.".localized
        case .forgotPW: return "...@mundocoin.com".localized
        case .registration: return "Enter the 6-digit code ".localized
        case .securityVerification: return "Enter the 6-digit code".localized
        default: return ""
        }
    }
    func rightLabelString() -> String
    {
        switch self {
        case .emailVerify(_): return "Send".localized
        case .twoFAVerify: return "Paste".localized
        case .copy: return "Copy".localized
        default: return ""
        }
    }
    func dropDataSource() -> Array<String>
    {
        switch self {
        case .networkMethod(let array),.crypto(let array):
            return array
        default:
            return []
        }
    }
    func isDropDownStyle() -> Bool
    {
        switch self {
        case .networkMethod( _ ),.crypto( _ ):
            return true
        default:
            return false
        }
    }
    func dropDownStylePlaceHolder() -> String
    {
        switch self {
        case .networkMethod( _ ):
            return "TRC20"
        case .crypto( _ ):
            return "USDT"
        default:
            return ""
        }
    }
    func isDropDownStyleEnable() -> Bool
    {
        switch self {
        case .networkMethod( let array ),.crypto( let array ):
            if array.count > 1
            {
                return true
            }else
            {
                return false
            }
        default:
            return true
        }
    }
}
class InputStyleView: UIView {
    // MARK:業務設定
    private var inputViewMode: InputViewMode = .email
    private let displayPwdImg = UIImage(named: "icon-view")
    private let undisplayPwdImg =  UIImage(named: "icon-view-hide")
    private let cancelImg = UIImage(named: "icon-close-round-fill")
    private let onChangeHeightAction = PublishSubject<CGFloat>()
    private let onSendClick = PublishSubject<Any>()
    private let onPasteClick = PublishSubject<Any>()
    private let onAddressBookClick = PublishSubject<Any>()
    private let onScanClick = PublishSubject<Any>()
    private let onAddAddressClick = PublishSubject<String>()
    private let onTextLabelClick = PublishSubject<String>()
    private let onChooseClick = PublishSubject<Bool>()
    private let dpg = DisposeBag()
    private var timer: Timer?
    private var countTime = 60
    var displayOffetWidth : CGFloat = 0.0
    var cancelOffetWidth : CGFloat = 0.0
    var tvHeightConstraint : NSLayoutConstraint!
    var withdrawInputViewFullHeight = false
    // MARK: -
    // MARK:UI 設定
    let tfMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = Themes.grayE0E5F2.cgColor
        view.isUserInteractionEnabled = false
        view.alpha = 1.0
#if Approval_PRO || Approval_DEV || Approval_STAGE
        view.applyCornerRadius(radius: 4)
#else
        view.applyCornerRadius(radius: 10)
#endif
        return view
    }()
    let topLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        
        lb.text = "Email".localized
#if Approval_PRO || Approval_DEV || Approval_STAGE
        lb.textColor = #colorLiteral(red: 0, green: 0.1254901961, blue: 0.2, alpha: 1)
        lb.font = Fonts.SFProDisplayBold(14)
#else
        lb.textColor = #colorLiteral(red: 0.106, green: 0.145, blue: 0.349, alpha: 1.0)
        lb.font = Fonts.PlusJakartaSansBold(14)
#endif
        return lb
    }()
    let textField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.textInputView.backgroundColor = .clear
        
#if Approval_PRO || Approval_DEV || Approval_STAGE
        tf.textColor = #colorLiteral(red: 0.1921568627, green: 0.2941176471, blue: 0.3568627451, alpha: 1)
        tf.font = Fonts.SFProDisplayRegular(16)
#else
        tf.textColor = #colorLiteral(red: 0.169, green: 0.212, blue: 0.455, alpha: 1.0)
        tf.font = Fonts.PlusJakartaSansRegular(16)
#endif
        return tf
    }()
    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.textInputView.backgroundColor = .clear
        tv.font = Fonts.PlusJakartaSansRegular(16)
        tv.textColor = #colorLiteral(red: 0.169, green: 0.212, blue: 0.455, alpha: 1.0)
        tv.returnKeyType = .done
        return tv
    }()
    let textLabel: UnderlinedLabel = {
        let tfLabel = UnderlinedLabel()
        tfLabel.backgroundColor = .clear
        tfLabel.font = Fonts.PlusJakartaSansRegular(14)
        tfLabel.numberOfLines = 0
        tfLabel.adjustsFontSizeToFitWidth = true
        tfLabel.minimumScaleFactor = 0.8
        tfLabel.isUserInteractionEnabled = true
        return tfLabel
    }()
    let normalTextLabel: UILabel = {
        let tfLabel = UILabel()
        tfLabel.backgroundColor = .clear
        tfLabel.font = Fonts.PlusJakartaSansRegular(14)
        tfLabel.textColor = Themes.gray2B3674
        tfLabel.numberOfLines = 0
        tfLabel.lineBreakMode = .byCharWrapping
//        tfLabel.adjustsFontSizeToFitWidth = true
//        tfLabel.minimumScaleFactor = 1
//        tfLabel.isUserInteractionEnabled = true
        return tfLabel
    }()
    let invalidLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.font = Fonts.PlusJakartaSansMedium(14)
        lb.textColor = Themes.grayA3AED0
        lb.isHidden = true
        lb.numberOfLines = 0
        lb.adjustsFontSizeToFitWidth = true
        return lb
    }()
    let verifyResentLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = .black
        lb.text = "Send".localized
#if Approval_PRO || Approval_DEV || Approval_STAGE
        lb.font = Fonts.SFProDisplayBold(15)
#else
        lb.font = Fonts.PlusJakartaSansRegular(14)
#endif
        return lb
    }()
    let addressBookImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "icon-addressbook")
        return imgView
    }()
    var scanImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "icon-scan")
        return imgView
    }()
    let addAddressImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "icon-add")
        return imgView
    }()
    let copyAddressImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "icon-copy")
        return imgView
    }()
    let dropDownImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "icon-chevron-down")
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
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 
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
    func setMode(mode:InputViewMode)
    {
        self.inputViewMode = mode
        self.setup()
        self.bindPwdButton()
        self.bindImageView()
        self.bindTextfield()
        self.bindLabel()
        self.bindCancelButton()
        timer?.invalidate()
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
        let isPasswordType = (inputViewMode == .password ||
                              inputViewMode == .newPassword ||
                              inputViewMode == .confirmPassword ||
                              inputViewMode == .oldPassword ||
                              inputViewMode == .auditPassword)
        var isCustomLabel = false
        let tfHeight = 46.0
        var showTextView = false
        switch inputViewMode {
        case .customLabel(_) ,.auditAccount,.auditPassword:
            isCustomLabel = true
        case .withdrawToAddress , .address:
            showTextView = true
        default:
            break
        }
        addSubview(topLabel)
        addSubview(textField)
        tvHeightConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: CGFloat(tfHeight))
        if showTextView == true
        {
            addSubview(textView)
            textView.delegate = self
        }
        addSubview(invalidLabel)
        textField.delegate = self
        displayRightButton.tintColor = Themes.grayA3AED0
        let topLabelH = 17
        let invalidH = (isPasswordType ? 39.0 : (isCustomLabel  ? 0.0 : 22.0))
        topLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(7)
            make.height.equalTo(topLabelH)
        }
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(9)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(46)
        }
        textField.addConstraint(tvHeightConstraint)
        if showTextView == true
        {
//            textField.isHidden = true
            textField.isUserInteractionEnabled = false
            textView.snp.makeConstraints { make in
                make.top.equalTo(textField).offset(5)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20-(24 + 20 + 10))
                make.bottom.equalTo(textField).offset(-5)
            }
            invalidLabel.isHidden = true
        }
        invalidLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textField.snp.bottom).offset(2)
            make.left.equalTo(topLabel)
            make.trailing.equalTo(textField)
            make.height.equalTo(invalidH)
        }
        setMaskView(showTV: showTextView)
        resetUI()
    }
    func setMaskView(showTV:Bool = false) {
        textField.addSubview(tfMaskView)
        tfMaskView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1.10)
            make.height.equalToSuperview().multipliedBy(Views.isIPhoneWithNotch() ? 1.0 : 1.1)
        }
//        if showTV == false
//        {
//        }else
//        {
//            textView.addSubview(tfMaskView)
//            tfMaskView.snp.makeConstraints { (make) in
//                make.center.equalToSuperview()
//                make.width.equalToSuperview().multipliedBy(1.10)
//                make.height.equalToSuperview().multipliedBy(Views.isIPhoneWithNotch() ? 1.0 : 1.1)
//            }
//        }
    }
    func resetTopLabelAndMask() {
        topLabel.snp.updateConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        tfMaskView.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(topLabel).offset(-15)
            make.bottom.equalTo(invalidLabel).offset(-15)
            make.left.right.equalTo(self)
        }
        self.sendSubviewToBack(textField)
    }
    func resetConfirmTopLabelAndMask() {
        topLabel.snp.updateConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        tfMaskView.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(topLabel).offset(-15)
            make.bottom.equalTo(normalTextLabel).offset(15)
            make.left.right.equalTo(self)
        }
        self.sendSubviewToBack(textField)
    }
    func resetUI()
    {
        displayRightButton.tintColor = Themes.gray707EAE
        cancelRightButton.tintColor = Themes.gray707EAE
        let isPasswordType = (inputViewMode == .password ||
                              inputViewMode == .newPassword ||
                              inputViewMode == .confirmPassword ||
                              inputViewMode == .oldPassword ||
                              inputViewMode == .auditPassword)
        var topLabelString = ""
        var placeHolderString = ""
        var invalidLabelString = ""
        var rightLabelWidth : CGFloat = 0.0
        displayOffetWidth = (isPasswordType ? 24.0:0.0)
        switch self.inputViewMode {
        case .copy ,.withdrawToAddress,.address ,.networkMethod(_), .crypto(_), .withdrawAddressToConfirm , .withdrawAddressToDetail(_) , .withdrawAddressFromDetail, .withdrawAddressInnerFromDetail ,.txid(_):
            cancelOffetWidth = 0.0
            textField.isUserInteractionEnabled = false
        default:
            cancelOffetWidth = 24.0
            textField.isUserInteractionEnabled = true
        }
        textField.isSecureTextEntry = isPasswordType
        topLabelString = inputViewMode.topString()
        placeHolderString = inputViewMode.textPlacehloder()
        invalidLabelString = inputViewMode.invalidString()
     
        if inputViewMode == .twoFAVerify ||
            inputViewMode == .copy
        {
            addSubview(verifyResentLabel)
            verifyResentLabel.text = inputViewMode.rightLabelString()
#if Approval_PRO || Approval_DEV || Approval_STAGE
            verifyResentLabel.textColor = Themes.green13BBB1
            verifyResentLabel.font = Fonts.PlusJakartaSansRegular(14)
#else
            verifyResentLabel.textColor = Themes.purple6149F6
            verifyResentLabel.font = Fonts.PlusJakartaSansBold(15)
#endif
            verifyResentLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-17)
                make.centerY.equalTo(textField)
            }
            rightLabelWidth = verifyResentLabel.intrinsicContentSize.width + 12
        }
        else if inputViewMode == .withdrawToAddress || inputViewMode == .address
        {
            addSubview(scanImageView)
            scanImageView.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalTo(textField)
                make.size.equalTo(20)
            }
            rightLabelWidth = 24 + 20
            if inputViewMode == .withdrawToAddress
            {
                // MC524 打開白名單
                addSubview(addressBookImageView)
                addressBookImageView.snp.makeConstraints { (make) in
                    make.right.equalTo(scanImageView.snp.left).offset(-10)
                    make.centerY.equalTo(textField)
                    make.size.equalTo(24)
                }
                rightLabelWidth = 24 + 24 + 20
            }
        }
        else if inputViewMode.isDropDownStyle()
        {
            textField.text = inputViewMode.dropDownStylePlaceHolder()
            let textFieldMulH = height(48/812)
            let tfWidth = width(361.0/414.0) - 40
            addSubview(dropDownImageView)
            addSubview(chooseButton)
            addSubview(anchorView)
            dropDownImageView.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-20)
                make.centerY.equalTo(textField)
                make.size.equalTo(20)
            }
            anchorView.snp.makeConstraints { (make) in
                make.top.equalTo(textField.snp.bottom)
                make.height.equalTo(textFieldMulH)
                make.centerX.equalToSuperview()
                make.width.equalTo(tfWidth)
            }
            chooseButton.snp.makeConstraints { (make) in
                make.edges.equalTo(textField)
            }
            rightLabelWidth = 18 + 20
            if inputViewMode.isDropDownStyleEnable()
            {
                setupChooseDropdown()
                bindChooseButton()
                dropDownImageView.isHidden = false
            }else
            {
                textField.textColor = #colorLiteral(red: 0.6397986412, green: 0.6825351715, blue: 0.8161025643, alpha: 1)
                tfMaskView.backgroundColor = #colorLiteral(red: 0.8788456917, green: 0.8972983956, blue: 0.9480333924, alpha: 1)
                dropDownImageView.isHidden = true
            }
        }
        else if inputViewMode == .withdrawAddressToDetail(true) || inputViewMode == .withdrawAddressFromDetail || inputViewMode == .withdrawAddressInnerFromDetail
        {
            addSubview(normalTextLabel)
            // MC524 打開白名單
            addSubview(addAddressImageView)
            addSubview(copyAddressImageView)
            normalTextLabel.snp.makeConstraints { (make) in
                make.left.top.bottom.equalTo(textField)
                make.right.equalToSuperview().offset(-35 - 46)
//                make.right.equalToSuperview().offset(-35 - 46 + 34)
            }
            copyAddressImageView.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-10)
                make.centerY.equalTo(textField)
                make.size.equalTo(24)
            }
            // MC524 打開白名單
            addAddressImageView.snp.makeConstraints { (make) in
                make.right.equalTo(copyAddressImageView.snp.left).offset(-10)
                make.centerY.equalTo(textField)
                make.size.equalTo(24)
            }
            // MC524 打開白名單
            rightLabelWidth = 18 + 18 + 10
//            rightLabelWidth = 18 + 18 + 10 - 34
            resetTopLabelAndMask()
            tfMaskView.layer.borderColor = UIColor.clear.cgColor
        }
        else if inputViewMode == .withdrawAddressToDetail(false)
        {
            addSubview(normalTextLabel)
            normalTextLabel.snp.makeConstraints { (make) in
                make.left.top.bottom.equalTo(textField)
                make.right.equalToSuperview().offset(-35)
            }
            resetTopLabelAndMask()
            tfMaskView.layer.borderColor = UIColor.clear.cgColor
        }
        else if inputViewMode == .withdrawAddressToConfirm
        {
            addSubview(normalTextLabel)
            normalTextLabel.snp.makeConstraints { (make) in
                make.left.top.bottom.equalTo(textField)
                make.right.equalToSuperview().offset(-20)
            }
            normalTextLabel.textColor = #colorLiteral(red: 0.6397986412, green: 0.6825351715, blue: 0.8161025643, alpha: 1)
            normalTextLabel.font = Fonts.PlusJakartaSansRegular(16)
            rightLabelWidth = 18 + 10
            resetTopLabelAndMask()
            tfMaskView.backgroundColor = Themes.grayF4F7FE
        }
        else
        {
            switch self.inputViewMode {
            case .txid(let tString):
                if tString.count < 3
                {
                    addSubview(normalTextLabel)
                    normalTextLabel.snp.makeConstraints { (make) in
                        make.left.top.bottom.equalTo(textField)
                        make.right.equalToSuperview().offset(-20)
                    }
                    normalTextLabel.textColor = #colorLiteral(red: 0.6397986412, green: 0.6825351715, blue: 0.8161025643, alpha: 1)
                }else
                {
                    addSubview(textLabel)
                    textLabel.snp.makeConstraints { (make) in
                        make.left.top.bottom.equalTo(textField)
                        make.right.equalToSuperview().offset(-35)
                    }
                    addSubview(normalTextLabel)
                    normalTextLabel.snp.makeConstraints { (make) in
                        make.left.top.bottom.equalTo(textField)
                        make.right.equalToSuperview().offset(-20)
                    }
                    normalTextLabel.textColor = #colorLiteral(red: 0.6397986412, green: 0.6825351715, blue: 0.8161025643, alpha: 1)
                    addSubview(copyAddressImageView)
                    copyAddressImageView.snp.makeConstraints { (make) in
                        make.right.equalToSuperview().offset(-10)
                        make.centerY.equalTo(textField)
                        make.size.equalTo(24)
                    }
                    rightLabelWidth = 18 + 10
                }
                resetTopLabelAndMask()
                tfMaskView.layer.borderColor = UIColor.clear.cgColor
            case .emailVerify(_):
                addSubview(verifyResentLabel)
                verifyResentLabel.text = inputViewMode.rightLabelString()
#if Approval_PRO || Approval_DEV || Approval_STAGE
                verifyResentLabel.textColor = Themes.green13BBB1
                verifyResentLabel.font = Fonts.PlusJakartaSansRegular(14)
#else
                verifyResentLabel.textColor = Themes.purple6149F6
                verifyResentLabel.font = Fonts.PlusJakartaSansBold(15)
#endif
                verifyResentLabel.snp.makeConstraints { (make) in
                    make.right.equalToSuperview().offset(-17)
                    make.centerY.equalTo(textField)
                }
                rightLabelWidth = verifyResentLabel.intrinsicContentSize.width + 12
            default:
                rightLabelWidth = 10
            }
        }
        
        topLabel.text = topLabelString
        invalidLabel.text = invalidLabelString
        textField.setPlaceholder(placeHolderString, with: Themes.grayA3AED0)
        
        addSubview(displayRightButton)
        displayRightButton.setTitle(nil, for: .normal)
        displayRightButton.setImage(displayPwdImg, for: .normal)
//        displayRightButton.setBackgroundImage(displayPwdImg, for: .normal)
        displayRightButton.snp.remakeConstraints { (make) in
            make.right.equalToSuperview().offset(-12 - rightLabelWidth)
            make.centerY.equalTo(textField)
            make.height.equalTo(24)
            make.width.equalTo(displayOffetWidth)
        }
        displayRightButton.imageView?.contentMode = .scaleAspectFill
        addSubview(cancelRightButton)
        //設定文字刪除
        cancelRightButton.setTitle(nil, for: .normal)
        cancelRightButton.setBackgroundImage(cancelImg, for: .normal)
        cancelRightButton.snp.remakeConstraints { (make) in
            make.right.equalTo(displayRightButton.snp.left).offset((displayOffetWidth > 0) ? -12:0)
            make.centerY.equalTo(textField)
            make.height.equalTo(24)
            make.width.equalTo(cancelOffetWidth)
        }
        cancelRightButton.isHidden = true
        let rightView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 12 + rightLabelWidth + displayOffetWidth + cancelOffetWidth , height: 10))
        textField.rightViewMode = .always
        textField.rightView = rightView
        bringSubviewToFront(topLabel)
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
            let isOn = KeychainManager.share.getWhiteListOnOff()
            if isOn == true , inputViewMode == .withdrawToAddress
            {
                self.onAddressBookClick.onNext(())
            }else
            {
                self.onScanClick.onNext(())
            }
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
        case .networkMethod(let array),.crypto(let array):
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
        displayRightButton.setImage(textField.isSecureTextEntry ? displayPwdImg : undisplayPwdImg , for: .normal)
    }
    private func cancelButtonPressed() {
        tvHeightConstraint.constant = 46.0
        withdrawInputViewFullHeight = false
        textView.text = ""
        textField.text = ""
        // 依照要求 點擊 X 之後還要有鍵盤
        //        textView.resignFirstResponder()
        //        textField.resignFirstResponder()
        textField.setPlaceholder(inputViewMode.textPlacehloder(), with: Themes.grayA3AED0)
        cancelRightButton.isHidden = true
        textField.sendActions(for: .valueChanged)
        onChangeHeightAction.onNext(46.0)
    }
 
    private func verifyResentPressed() {
        switch inputViewMode {
        case .emailVerify(_):
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
        if self.timer == nil, let idString = textField.text
        {
            verifyResentLabel.isUserInteractionEnabled = false
            setupTimer()
            onSendClick.onNext(())
        }
    }
    func resetDisplayBtnUI()
    {
        var rightLabelWidth : CGFloat = 0.0
        rightLabelWidth = verifyResentLabel.intrinsicContentSize.width + 12
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
        verifyResentLabel.textColor = UIColor(rgb: 0xDEE2E8)
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
        switch inputViewMode {
        case .withdrawAddressToDetail( _ ) , .withdrawAddressFromDetail , .withdrawAddressInnerFromDetail:
            UIPasteboard.general.string = normalTextLabel.text
            Toast.show(msg: "Copied")
        case .txid( _ ):
            UIPasteboard.general.string = textLabel.text
            Toast.show(msg: "Copied")
        default:
            UIPasteboard.general.string = textField.text
            Toast.show(msg: "Copied")
        }
    
    }
    func resetTimerAndAll()
    {
        verifyResentLabel.text = "Send".localized
#if Approval_PRO || Approval_DEV || Approval_STAGE
        verifyResentLabel.textColor = Themes.green13BBB1
        verifyResentLabel.font = Fonts.PlusJakartaSansRegular(14)
#else
        verifyResentLabel.textColor = Themes.purple6149F6
        verifyResentLabel.font = Fonts.PlusJakartaSansBold(15)
#endif
        resetDisplayBtnUI()
        timer?.invalidate()
        timer = nil
        countTime = 60
        verifyResentLabel.isUserInteractionEnabled = true
    }
    func setVisibleString(string : String)
    {
        switch self.inputViewMode {
        case .txid( _ ) :
            if string.count > 3
            {
                textLabel.text = string
                textLabel.isHidden = false
                normalTextLabel.isHidden = true
            }else
            {
                normalTextLabel.text = string
                textLabel.isHidden = true
                normalTextLabel.isHidden = false
                copyAddressImageView.isHidden = true
            }
        case .withdrawAddressToConfirm, .withdrawAddressToDetail(_) ,.address, .withdrawAddressFromDetail , .withdrawAddressInnerFromDetail:
            let theSame = KeychainManager.share.getAddressBookList().filter({$0.address == string})
            if theSame.count > 0
            {
                addAddressImageView.isHidden = true
            }
            normalTextLabel.text = string
        default:
            break
        }
    }
    func changeInvalidLabelAndMaskBorderColor(with invalidString:String)
    {
        if invalidString.isEmpty
        {
            invalidLabel.text = inputViewMode.invalidString()
            invalidLabel.textColor = Themes.grayA3AED0
            tfMaskView.layer.borderColor = Themes.grayE0E5F2.cgColor
        }else
        {
            invalidLabel.text = invalidString
            invalidLabel.textColor = .red
            invalidLabel.isHidden = false
            tfMaskView.layer.borderColor = UIColor.red.cgColor
        }
    }
    func setupCountTime(seconds:Int)
    {
        countTime = seconds
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
    func rxChooseClick() -> Observable<Bool>
    {
        return onChooseClick.asObserver()
    }
    func rxChangeHeightAction() -> Observable<CGFloat>
    {
        return onChangeHeightAction.asObserver()
    }
}
// MARK: -
// MARK: 延伸
extension InputStyleView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        cancelRightButton.isHidden = true
        onChooseClick.onNext(false)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        cancelRightButton.isHidden = true
#else
        if range.length == textField.text?.count , string == ""
        {
            cancelRightButton.isHidden = true
        }else
        {
            cancelRightButton.isHidden = false
        }
#endif
        switch inputViewMode {
        case .customLabel(_):
            guard let text = textField.text else {
                return true
            }
            if string == ""
            {
                return true
            }
            if text.count >= 20 {
                return false
            }
        default:
            break
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.placeholder = ""
        onChooseClick.onNext(true)
#if Approval_PRO || Approval_DEV || Approval_STAGE
        cancelRightButton.isHidden = true
#else
        if textField.text?.isEmpty == true
        {
            cancelRightButton.isHidden = true
        }else
        {
            cancelRightButton.isHidden = false
        }
#endif
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        cancelRightButton.isHidden = true
    }
}
extension InputStyleView : UITextViewDelegate
{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        onChooseClick.onNext(false)
        cancelRightButton.isHidden = false
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        let endDocument = textView.endOfDocument
        let currentRect = textView.caretRect(for: endDocument)
        if currentRect.origin.y > 7 ,withdrawInputViewFullHeight == false
        {
            Log.v("下一行")
            withdrawInputViewFullHeight = true
            onChangeHeightAction.onNext(72.0)
        }else if currentRect.origin.y == 7 ,withdrawInputViewFullHeight == true
        {
            withdrawInputViewFullHeight = false
            onChangeHeightAction.onNext(46.0)
        }
        
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        let isOn = KeychainManager.share.getWhiteListOnOff()
        if isOn == true , inputViewMode == .withdrawToAddress
        {
            self.onAddressBookClick.onNext(())
            return false
        }else
        {
            textField.placeholder = ""
            onChooseClick.onNext(true)
            cancelRightButton.isHidden = true
            return true
        }
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        cancelRightButton.isHidden = true
        return true
    }
    
}
