//
//  AddNewAddressViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/7/22.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class AddNewAddressViewController: BaseViewController {
    // MARK:業務設定
    private let onDismissClick = PublishSubject<Any>()
    private var dpg = DisposeBag()
    private var currentNetwotkMethod = ""
    var isScanPopAction = false
    var newAddressString :String = ""
    var isScanVCByAVCapture = false
    var isToSecurityVC = false
    let scanVC = ScannerViewController()
    var twoWayVC = SecurityVerificationViewController.loadNib()
    @IBOutlet weak var coinLabelTopConstraint : NSLayoutConstraint!
    @IBOutlet weak var saveButtonTopConstraint : NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var dropdownView: DropDownStyleView!
    @IBOutlet weak var addressStyleView: InputStyleView!
    @IBOutlet weak var networkView: DynamicCollectionView!
    @IBOutlet weak var nameStyleView: InputStyleView!
    @IBOutlet weak var walletLabelStyleView: InputStyleView!
    @IBOutlet weak var checkBox: CheckBoxView!
    @IBOutlet weak var saveButton: CornerradiusButton!
    @IBOutlet weak var backgroundView: UIView!
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    @IBOutlet weak var middleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addToWhitelistView: UIView!
    // 上層 只有present 才會出現的頂層
    @IBOutlet weak var topWhiteView: UIView!
    @IBOutlet weak var topBorderView: UIView!
    @IBOutlet weak var topLeftBackImageView: UIImageView!
    @IBOutlet weak var topRightLabel: UILabel!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add new address".localized
        view.backgroundColor = Themes.grayF4F7FE
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
  
        setupUI()
        setupKeyboardNoti()
//        setupAddressStyleView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dpg = DisposeBag()
        bindTextfield()
        bindDynamicView()
        bindSaveButton()
        bindSacnVC()
        bindTopView()
        setupAddressStyleView()
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
        addressStyleView.withdrawInputViewFullHeight = false
        let style: WhiteListStyle = KeychainManager.share.getWhiteListOnOff() ? .whiteListOn:.whiteListOff
        if style == .whiteListOff
        {
            addToWhitelistView.isHidden = true
            checkBox.isSelected = false
        }
        if self.navigationController != nil
        {
            coinLabelTopConstraint.constant = 64
            topWhiteView.isHidden = true
            
        }else
        {
            coinLabelTopConstraint.constant = 32
            topWhiteView.isHidden = false
//            topBorderView.layer.borderWidth = 1
//            topBorderView.layer.borderColor = UIColor(rgb: 0xF1F1F1).cgColor
        }
        addressStyleView.textField.sendActions(for: .valueChanged)
        nameStyleView.textField.sendActions(for: .valueChanged)
        walletLabelStyleView.textField.sendActions(for: .valueChanged)
        let navHeight = (self.navigationController == nil) ? 80.0 : 0.0
        let diffHeight = Views.screenHeight - saveButton.frame.maxY - navHeight
        if diffHeight < 100
        {
            saveButtonTopConstraint.constant = 15
        }else
        {
            saveButtonTopConstraint.constant = 44
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isScanVCByAVCapture == false && isToSecurityVC == false
        {
            bindWhenAppear()
        }
        isScanVCByAVCapture = false
        isToSecurityVC = false
        if addressStyleView.textView.text.isEmpty == true
        {
            addressStyleView.textField.placeholder = InputViewMode.withdrawToAddress.textPlacehloder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isScanVCByAVCapture == false && isToSecurityVC == false
        {
            self.dpg = DisposeBag()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        addressStyleView.tfMaskView.changeBorderWith(isChoose:false)
        nameStyleView.tfMaskView.changeBorderWith(isChoose:false)
        walletLabelStyleView.tfMaskView.changeBorderWith(isChoose:false)
    }
    // MARK: -
    // MARK:業務方法
    func setupKeyboardNoti()
    {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let navHeight = (self.navigationController == nil) ? 80.0 : 0.0
            if ((nameStyleView?.textField.isFirstResponder) == true)
            {
                let diffHeight = Views.screenHeight - nameStyleView.frame.maxY - navHeight
                if diffHeight < (keyboardHeight + 120 )
                {
                    UIView.animate(withDuration: 0.3, delay: 0) { [self] in
                        let upHeight = (keyboardHeight + 120 ) - diffHeight
                        backgroundView.frame.origin.y = Views.navigationBarHeight - upHeight
                        addressStyleView.alpha = 1.0
                        if upHeight > 50
                        {
                            coinLabel.alpha = 0.0
                            dropdownView.alpha = 0.0
                        }
                    }
                }
            }
            if ((walletLabelStyleView?.textField.isFirstResponder) == true)
            {
                let diffHeight = Views.screenHeight - walletLabelStyleView.frame.maxY - navHeight
                if diffHeight < (keyboardHeight + 135 )
                {
                    UIView.animate(withDuration: 0.3, delay: 0) { [self] in
                        let upHeight = (keyboardHeight + 135 ) - diffHeight
                        backgroundView.frame.origin.y = Views.navigationBarHeight - ((upHeight > 135) ? 200 : upHeight)
                        if upHeight > 50
                        {
                            coinLabel.alpha = 0.0
                            dropdownView.alpha = 0.0
                            if upHeight > 135
                            {
                                addressStyleView.alpha = 0.0
                            }
                        }
                    }
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if backgroundView.frame.origin.y != Views.navigationBarHeight {
            backgroundView.frame.origin.y = Views.navigationBarHeight
        }
        UIView.animate(withDuration: 0.3, delay: 0) { [self] in
            
            if coinLabel.alpha == 0.0
            {
                coinLabel.alpha = 1.0
                dropdownView.alpha = 1.0
            }
            if addressStyleView.alpha == 0.0
            {
                addressStyleView.alpha = 1.0
            }
        }
    }
    func setupUI()
    {
//        dropdownView.config(showDropdown: true, dropDataSource: ["USDT","USD"])
        dropdownView.config(showDropdown: false, dropDataSource: ["USDT"])
        dropdownView.layer.cornerRadius = 10
        dropdownView.layer.masksToBounds = true
        dropdownView?.layer.borderColor = #colorLiteral(red: 0.9058823529, green: 0.9254901961, blue: 0.968627451, alpha: 1)
        dropdownView?.layer.borderWidth = 1
        dropdownView.topLabel.font = Fonts.PlusJakartaSansBold(16)
        addressStyleView.setMode(mode: .address)
        networkView.setData(type: .addNewAddressNetworkMethod)
        nameStyleView.setMode(mode: .customLabel("Name"))
        walletLabelStyleView.setMode(mode: .customLabel("Wallet label (Optional)"))
        checkBox.checkType = .checkType
        checkBox.isSelected = true
        saveButton.setTitle("Save".localized, for: .normal)
    }
    func bindTextfield()
    {
        addressStyleView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            addressStyleView.tfMaskView.changeBorderWith(isChoose:isChoose)
            addressStyleView.changeInvalidLabelAndMaskBorderColor(with:"")
            addressStyleView.invalidLabel.isHidden = true
        }.disposed(by: dpg)
        addressStyleView.rxChangeHeightAction().subscribeSuccess { [self] heightValue in
            changeWithdrawInputViewHeight(constant: heightValue)
        }.disposed(by: dpg)
        
        nameStyleView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            nameStyleView.tfMaskView.changeBorderWith(isChoose:isChoose)
            nameStyleView.changeInvalidLabelAndMaskBorderColor(with:"")
            nameStyleView.invalidLabel.isHidden = true
            if isChoose == false
            {
                walletLabelStyleView.textField.becomeFirstResponder()
            }
        }.disposed(by: dpg)
        walletLabelStyleView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            walletLabelStyleView.tfMaskView.changeBorderWith(isChoose:isChoose)
            walletLabelStyleView.changeInvalidLabelAndMaskBorderColor(with:"")
            walletLabelStyleView.invalidLabel.isHidden = true
        }.disposed(by: dpg)
        let isAddressValid = addressStyleView.textView.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. coinAddress, input: acc)
        }
//        isAddressValid.skip(1).bind(to: addressStyleView.invalidLabel.rx.isHidden).disposed(by: dpg)
        let isNameValid = nameStyleView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. delegateName, input: acc)
        }
        isNameValid.skip(1).bind(to: nameStyleView.invalidLabel.rx.isHidden).disposed(by: dpg)
        Observable.combineLatest(isAddressValid,isNameValid)
            .map { return $0.0 && $0.1 } //reget match result
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: dpg)
        nameStyleView.textField.returnKeyType = .next
        walletLabelStyleView.textField.returnKeyType = .done
    }
    func bindDynamicView()
    {
        networkView.rxCellClick().subscribeSuccess { data in
            Log.v("NetworkMethod 點到 \(data.1)")
            self.currentNetwotkMethod = data.1
        }.disposed(by: dpg)
    }
    func bindSaveButton()
    {
        saveButton.rx.tap.subscribeSuccess { [self](_) in
            Log.v("點到Save")
            isToSecurityVC = true
            if let type = MemberAccountDto.share?.withdrawWhitelistSecurityType
            {
//                twoWayVC = SecurityVerificationViewController.loadNib()
                // 暫時改為 onlyEmail
//                twoFAVC.securityViewMode = .defaultMode
//                twoFAVC.rxVerifySuccessClick().subscribeSuccess { [self] (_) in
//                    verifySuccessForChangeWhiteList()
//                }.disposed(by: dpg)
                twoWayVC.securityViewMode = type
                twoWayVC.rxVerifySuccessClick().subscribeSuccess { [self] (data) in
                    verifySuccessForCreateAddressBook(code: data.0, withMode: data.1) {
                        
                    }
                }.disposed(by: dpg)
            }
            if ((self.presentingViewController?.isKind(of: AddressBottomSheet.self)) != nil)
            {
                self.present(twoWayVC, animated: true)
            }else
            {
                self.navigationController?.pushViewController(twoWayVC, animated: true)
            }
            
        }.disposed(by: dpg)
    }
    func verifySuccessForCreateAddressBook(code:String, withMode:String = "",done: @escaping () -> Void)
    {
        let address = createAddressDto()
        var codePara : [Parameters] = []
        if let accountArray = MemberAccountDto.share?.withdrawWhitelistAccountArray ,
           accountArray.first != nil
        {
            var parameters: Parameters = [String: Any]()
            parameters["id"] = accountArray.first ?? ""
            parameters["code"] = code
            codePara.append(parameters)
            if !withMode.isEmpty , accountArray.last != nil
            {
                var parameters: Parameters = [String: Any]()
                parameters["id"] = accountArray.last ?? ""
                parameters["code"] = withMode
                codePara.append(parameters)
            }
        }
        _ = AddressBookListDto.addNewAddress(address: address.address, name: address.name, label: address.label ,enabled: address.enabled ,verificationCodes: codePara,
                                             done: { [self] in
            if ((self.presentingViewController?.isKind(of: AddressBottomSheet.self)) != nil)
            {
                self.dismiss(animated: true)
            }else
            {
                twoWayVC.navigationController?.popViewController(animated: false)
            }
            _ = AddressBookListDto.update(done: {
                if ((self.presentingViewController?.isKind(of: AddressBottomSheet.self)) != nil)
                {
                    self.dismiss(animated: true) {
                        self.onDismissClick.onNext(())
                    }
                }else
                {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        } ,
                                             field: { [self] error in
            Log.e("有錯誤")
            switch error {
            case .errorDto(let dto):
                let status = dto.httpStatus ?? ""
                let reason = dto.reason
                if status == "400"
                {
                    if reason == "CODE_MISMATCH"
                    {
                        errorHandlerWithReason(code: dto.code, reason: reason, withMode: withMode, error: error)
                    } else
                    {
                        vcDetector(code:dto.code,reason: reason)
                    }
                }else if status == "404"
                {
                    vcDetector(code:dto.code,reason: reason)
                }else
                {
                    ErrorHandler.show(error: error)
                }
            default:
                ErrorHandler.show(error: error)
            }
        })
    }
    func vcDetector(code:String = "",reason:String)
    {// 需判斷是否 pusr或者 present
        if self.presentedViewController != nil
        {
            twoWayVC.dismiss(animated: true) { [self] in
                errorHandlerWithReason(code:code,reason: reason)
            }
        }else
        {
            if let navVC = twoWayVC.navigationController as? MDNavigationController
            {
                navVC.popViewControllerWithHandler(animated: true) { [self] in
                    errorHandlerWithReason(code:code,reason: reason)
                }
            }
        }
    }
    func errorHandlerWithReason(code:String = "",reason:String , withMode : String? = nil , error : Error? = nil)
    {
        if reason == "CODE_MISMATCH"
        {
            Log.i("驗證碼錯誤 :\(reason)")
            if twoWayVC.securityViewMode == .onlyEmail
            {
                twoWayVC.twoWayVerifyView.emailInputView.invalidLabel.isHidden = false
                twoWayVC.twoWayVerifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
            }else if twoWayVC.securityViewMode == .onlyMobile
            {
                twoWayVC.twoWayVerifyView.mobileInputView.invalidLabel.isHidden = false
                twoWayVC.twoWayVerifyView.mobileInputView.changeInvalidLabelAndMaskBorderColor(with: "The Mobile Code is incorrect. Please re-enter.")
            }else if twoWayVC.securityViewMode == .selectedMode
            {
                if withMode == "onlyEmail" , let emailVC = twoWayVC.twoWayViewControllers.first
                {
                    emailVC.verifyView.emailInputView.invalidLabel.isHidden = false
                    emailVC.verifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                }else if withMode == "onlyMobile" , let mobileVC = twoWayVC.twoWayViewControllers.last
                {
                    mobileVC.verifyView.mobileInputView.invalidLabel.isHidden = false
                    mobileVC.verifyView.mobileInputView.changeInvalidLabelAndMaskBorderColor(with: "The Mobile Code is incorrect. Please re-enter.")
                }
            }else if twoWayVC.securityViewMode == .defaultMode , let error = error
            {
                if twoWayVC.twoWayVerifyView.twoWayViewMode == .both
                {
                    ErrorHandler.show(error: error)
                }
            }
        } else if reason == "ADDRESS_ALREADY_EXISTS"
        { // 新增了重覆的address
            let results = ErrorDefaultDto(code: "", reason: "Unable to add exist address", timestamp: 0, httpStatus: "", errors: [])
            ErrorHandler.show(error: ApiServiceError.errorDto(results))
        }else if reason == "ADDRESS_OWNED_BY_CUSTOMER"
        { // 新增了自己的address
            let results = ErrorDefaultDto(code: "", reason: "Unable to add own address", timestamp: 0, httpStatus: "", errors: [])
            ErrorHandler.show(error: ApiServiceError.errorDto(results))
        }
    }
    func createAddressDto() -> AddressBookDto
    {
        let currencyString = dropdownView.topLabel.text ?? ""
        let addressString = addressStyleView.textView.text ?? ""
        let nameString = nameStyleView.textField.text ?? ""
        let walletLabelString = walletLabelStyleView.textField.text ?? ""
        let isAddToWhiteList = checkBox.isSelected
        let address = AddressBookDto(currency: currencyString, address: addressString, name: nameString, label: walletLabelString, enabled: isAddToWhiteList, network: currentNetwotkMethod)
        return address
    }
    func bindSacnVC()
    {
        addressStyleView.rxScanImagePressed().subscribeSuccess {[self] _ in
            Log.i("開鏡頭")
            if AuthorizeService.share.authorizeAVCapture()
            {
                isScanVCByAVCapture = true
                Log.v("開始使用相機相簿")
                scanVC.rxSacnSuccessAction().subscribeSuccess { [self](stringCode) in
                    isScanPopAction = false
                    newAddressString = stringCode
//                    addressStyleView.textField.text = stringCode
                    addressStyleView.textField.placeholder = ""
                    addressStyleView.textView.text = newAddressString
                    changeWithdrawInputViewHeight(constant: 72.0)
//                    addressStyleView.textField.sendActions(for: .valueChanged)
                }.disposed(by: dpg)
                isScanPopAction = true
                if ((self.presentingViewController?.isKind(of: AddressBottomSheet.self)) != nil)
                {
                    self.present(scanVC, animated: true)
                }else
                {
                    self.navigationController?.pushViewController(scanVC, animated: true)
                }
            }
        }.disposed(by: dpg)
    }
    func bindWhenAppear()
    {
        AuthorizeService.share.rxShowAlert().subscribeSuccess { alertVC in
            if let _ = UIApplication.topViewController() as? AddNewAddressViewController
            {
                UIApplication.topViewController()?.present(alertVC, animated: true, completion: nil)
            }
        }.disposed(by: dpg)
    }
    func bindTopView()
    {
        topLeftBackImageView.rx.click.subscribeSuccess { [self] _ in
            dismiss(animated: true){ [self] in
                onDismissClick.onNext(())
            }
        }.disposed(by: dpg)
        topRightLabel.rx.click.subscribeSuccess { [self] _ in
            dismiss(animated: true){ [self] in
                onDismissClick.onNext(())
            }
        }.disposed(by: dpg)
    }
    func setupAddressStyleView()
    {
//        addressStyleView.textField.text = newAddressString
        addressStyleView.textField.placeholder = ""
        addressStyleView.textView.text = newAddressString
        changeWithdrawInputViewHeight(constant: newAddressString.isEmpty ? 46.0 : 72.0)
//        addressStyleView.textField.sendActions(for: .valueChanged)
    }
    func changeWithdrawInputViewHeight(constant:CGFloat)
    {
        DispatchQueue.main.async(execute: { [self] in
            addressStyleView.tvHeightConstraint.constant = constant
            middleViewHeight.constant = 90.0 + (constant - 46.0)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        })
    }
    
    func rxDismissClick() -> Observable<Any>
    {
        return onDismissClick.asObserver()
    }
//    func clearAllData ()
//    {
//        if isScanPopAction == false
//        {
//            
//            addressStyleView.textField.text = ""
//            addressStyleView.textField.sendActions(for: .valueChanged)
//        }
//    }
}
// MARK: -
// MARK: 延伸
