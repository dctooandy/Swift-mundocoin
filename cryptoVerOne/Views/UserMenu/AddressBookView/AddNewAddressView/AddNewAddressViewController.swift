//
//  AddNewAddressViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/7/22.
//

import Foundation
import RxCocoa
import RxSwift

class AddNewAddressViewController: BaseViewController {
    // MARK:業務設定
    private let onDismissClick = PublishSubject<Any>()
    private var dpg = DisposeBag()
    private var currentNetwotkMethod = ""
    var isScanPopAction = false
    var newAddressString :String = ""
    var isScanVCByAVCapture = false
    var isToSecurityVC = false
    var twoFAVC = SecurityVerificationViewController.loadNib()
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
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add new address".localized
        view.backgroundColor = Themes.grayF4F7FE
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        bindTextfield()
        bindDynamicView()
        bindSaveButton()
        bindSacnVC()
        setupUI()
        setupKeyboardNoti()
//        setupAddressStyleView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAddressStyleView()
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
        addressStyleView.withdrawInputViewFullHeight = false
        let style: WhiteListStyle = KeychainManager.share.getWhiteListOnOff() ? .whiteListOn:.whiteListOff
        if style == .whiteListOff
        {
            addToWhitelistView.isHidden = true
            checkBox.isSelected = false
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
            if ((nameStyleView?.textField.isFirstResponder) == true)
            {
                let diffHeight = Views.screenHeight - nameStyleView.frame.maxY
                if diffHeight < (keyboardHeight + 50)
                {
                    let upHeight = (keyboardHeight + 50) - diffHeight
                    if backgroundView.frame.origin.y == Views.navigationBarHeight {
                        backgroundView.frame.origin.y = Views.navigationBarHeight - upHeight
                    }
                }
            }
            if ((walletLabelStyleView?.textField.isFirstResponder) == true)
            {
                let diffHeight = Views.screenHeight - walletLabelStyleView.frame.maxY
                if diffHeight < (keyboardHeight + 50)
                {
                    let upHeight = (keyboardHeight + 50) - diffHeight
                    if backgroundView.frame.origin.y == Views.navigationBarHeight {
                        backgroundView.frame.origin.y = Views.navigationBarHeight - upHeight
                    }
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if backgroundView.frame.origin.y != Views.navigationBarHeight {
            backgroundView.frame.origin.y = Views.navigationBarHeight
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
        dropdownView.topLabel.font = Fonts.PlusJakartaSansMedium(14)
        addressStyleView.setMode(mode: .address)
        networkView.setData(type: .networkMethod)
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
            let address = createAddressDto()
            twoFAVC = SecurityVerificationViewController.loadNib()
            // 暫時改為 onlyEmail
//            twoFAVC.securityViewMode = .defaultMode
//            twoFAVC.rxVerifySuccessClick().subscribeSuccess { [self] (_) in
//                verifySuccessForChangeWhiteList()
//            }.disposed(by: dpg)
            twoFAVC.securityViewMode = .onlyEmail
            twoFAVC.rxVerifySuccessClick().subscribeSuccess { [self] (data) in
                verifySuccessForCreateAddressBook(code: data.0, withMode: data.1) {
                    
                }
//                if ((self.presentingViewController?.isKind(of: AddressBottomSheet.self)) != nil)
//                {
//                    self.dismiss(animated: true)
//                }else
//                {
//                    twoFAVC.navigationController?.popViewController(animated: false)
//                }
//
//                let group = DispatchGroup()
//                let dispatchQueue = DispatchQueue.global(qos: .background)
//                group.enter()
//                dispatchQueue.async {
//                    _ = AddressBookListDto.addNewAddress(address: address.address, name: address.name, label: address.label ,enabled: address.enabled ,verificationCode: data.0, done: {
//                        group.leave()
//                    })
//                }
//
//                group.notify(queue: DispatchQueue.main) {
//                    print("jobs done by group")
//                    dispatchQueue.async {
//                        _ = AddressBookListDto.update(done: {
//                            if ((self.presentingViewController?.isKind(of: AddressBottomSheet.self)) != nil)
//                            {
//                                self.dismiss(animated: true) {
//                                    self.onDismissClick.onNext(())
//                                }
//                            }else
//                            {
//                                self.navigationController?.popViewController(animated: true)
//                            }
//                        })
//                    }
//                }
            }.disposed(by: dpg)
            if ((self.presentingViewController?.isKind(of: AddressBottomSheet.self)) != nil)
            {
                self.present(twoFAVC, animated: true)
            }else
            {
                self.navigationController?.pushViewController(twoFAVC, animated: true)
            }
            
        }.disposed(by: dpg)
    }
    func verifySuccessForCreateAddressBook(code:String, withMode:String = "",done: @escaping () -> Void)
    {
        let address = createAddressDto()
        _ = AddressBookListDto.addNewAddress(address: address.address, name: address.name, label: address.label ,enabled: address.enabled ,verificationCode: code,
                                             done: { [self] in
            if ((self.presentingViewController?.isKind(of: AddressBottomSheet.self)) != nil)
            {
                self.dismiss(animated: true)
            }else
            {
                twoFAVC.navigationController?.popViewController(animated: false)
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
                        Log.i("驗證碼錯誤 :\(reason)")
                        if twoFAVC.securityViewMode == .onlyEmail
                        {
                            twoFAVC.twoFAVerifyView.emailInputView.invalidLabel.isHidden = false
                            twoFAVC.twoFAVerifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                        }else if twoFAVC.securityViewMode == .onlyTwoFA
                        {
                            twoFAVC.twoFAVerifyView.twoFAInputView.invalidLabel.isHidden = false
                            twoFAVC.twoFAVerifyView.twoFAInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                        }else if twoFAVC.securityViewMode == .selectedMode
                        {
                            if withMode == "onlyEmail" , let emailVC = twoFAVC.twoFAViewControllers.first
                            {
                                emailVC.verifyView.emailInputView.invalidLabel.isHidden = false
                                emailVC.verifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                            }else if withMode == "onlyTwoFA" , let twoFAVC = twoFAVC.twoFAViewControllers.last
                            {
                                twoFAVC.verifyView.twoFAInputView.invalidLabel.isHidden = false
                                twoFAVC.verifyView.twoFAInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                            }
                        }else if twoFAVC.securityViewMode == .defaultMode
                        {
                            if twoFAVC.twoFAVerifyView.twoFAViewMode == .both
                            {
                                ErrorHandler.show(error: error)
                            }
                        }
                    }
                }else
                {
                    ErrorHandler.show(error: error)
                }
            default:
                ErrorHandler.show(error: error)
            }
        })
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
                let scanVC = ScannerViewController()
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
            UIApplication.topViewController()?.present(alertVC, animated: true, completion: nil)
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
            middleViewHeight.constant = 80.0 + (constant - 46.0)
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
