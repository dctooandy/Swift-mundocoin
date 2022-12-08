//
//  WithdrawNewViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import RxCocoa
import RxSwift
import DropDown

class WithdrawNewViewController: BaseViewController {
    // MARK:業務設定
    static let share: WithdrawNewViewController = WithdrawNewViewController.loadNib()
    private let onClick = PublishSubject<Any>()
    private var dpg = DisposeBag()
    private var sacnerDpg = DisposeBag()
    // 如果是一個 就灰色不給選,多個才會有下拉選單
    var defaultCurrency:[String]! = ["USDT"]
    var dropDataSource:[String]! = ["TRC20"]
    var isScanPopAction = false
    var isScanVCByAVCapture = false
    let scanVC = ScannerViewController()
    @IBOutlet weak var middleHeight: NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyIconImageView: UIImageView!
    @IBOutlet weak var withdrawToInputView: UIView!
//    @IBOutlet weak var methodInputView: UIView!
    @IBOutlet weak var feeTitle: UILabel!
    @IBOutlet weak var receiveTitle: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var receiveAmountLabel: UILabel!
    @IBOutlet weak var continueButton: CornerradiusButton!
    @IBOutlet weak var noticeLabel: UILabel!

    @IBOutlet weak var amountInputStyleView: AmountInputStyleView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topCryptoView: UIView!
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    var withdrawToView : InputStyleView!
//    var methodView : InputStyleView!
    var confirmBottomSheet : ConfirmBottomSheet!
    var securityVerifyVC : SecurityVerificationViewController!
    var detailVC : WDetailViewController!
    // MARK: -
    // MARK:Life cycle
    init(_ : Any?) {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if KeychainManager.share.getMundoCoinNetworkMethodEnable() == true
        {
            dropDataSource = ["TRC20","ERC20"]
        }
        title = "Withdraw"
        setupUI()
        bindAction()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:backBtn)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sacnerDpg = DisposeBag()
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
        let isOn = KeychainManager.share.getWhiteListOnOff()
        withdrawToView.scanImageView.image = UIImage(named:isOn ? "icon-unscan" : "icon-scan")
        withdrawToView.withdrawInputViewFullHeight = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bindTextField()
        if isScanVCByAVCapture == false
        {
            bindWhenAppear()
        }
        isScanVCByAVCapture = false
        amountInputStyleView.amountTextView.becomeFirstResponder()
        if withdrawToView.textView.text.isEmpty == true
        {
            withdrawToView.textField.placeholder = InputViewMode.withdrawToAddress.textPlacehloder()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isScanVCByAVCapture == false
        {
            self.sacnerDpg = DisposeBag()
//            clearAllData()
        }
        
        
    }
    @objc func touch() {
        self.view.endEditing(true)
        withdrawToView.tfMaskView.changeBorderWith(isChoose:false)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    // MARK: -
    // MARK:業務方法
    @objc override func popVC() {
        clearAllData()
        _ = self.navigationController?.popViewController(animated: true)
    }
    func setupAmountInputData()
    {
        
    }
    func setupUI()
    {
        view.backgroundColor = Themes.grayF4F7FE
        // 設定幣種
        let totalCryptoNetworkString = "\(defaultCurrency.first!)-\(dropDataSource.first!)"
        currencyLabel.text = totalCryptoNetworkString
        amountInputStyleView.setData(data: defaultCurrency.first!)
        feeTitle.text = "Fee (USDT)".localized
        receiveTitle.text = "Receive amount (USDT)".localized
        feeAmountLabel.text = "1.00"
        receiveAmountLabel.text = "0.00"
        noticeLabel.text = "Please ensure that the address is correct and on the same network.".localized
        let isOn = KeychainManager.share.getWhiteListOnOff()
        withdrawToView = InputStyleView(inputViewMode: .withdrawToAddress)
        withdrawToView.scanImageView.image = UIImage(named:isOn ? "icon-unscan" : "icon-scan")
//        methodView = InputStyleView(inputViewMode: .networkMethod(dropDataSource))
        
        withdrawToInputView.addSubview(withdrawToView)
//        methodInputView.addSubview(methodView)
        withdrawToView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
//        methodView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//        methodInputView.snp.makeConstraints { make in
//            make.height.equalTo(100)
//            make.leading.trailing.equalTo(withdrawToInputView)
//            make.top.equalTo(withdrawToView.textView.snp.bottom)
//        }
        continueButton.titleLabel?.font = Fonts.PlusJakartaSansRegular(16)
        continueButton.setTitle("Continue".localized, for: .normal)
        continueButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        continueButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
//        topAmountView.applyCornerAndShadow(radius: 16)
        topCryptoView.applyBorder(color: Themes.grayE0E5F2, borderWidth: 1)
    }
    func setUPData(withdrawDatas : [WalletBalancesDto])
    {
        let minString = "10"
        let maxString = "1000000"
        amountInputStyleView.rangeLabel.text = "Min: \(minString) USDT - Max: \(maxString.numberFormatter(.decimal, 0)) USDT".localized
        if let data = withdrawDatas.filter({ $0.currency == "USDT" }).first
        {
            let amountValue = data.amount.doubleValue ?? 0.0
            amountInputStyleView.availableBalanceAmountLabel.text = "\(String(describing: amountValue))"
            // 設定最高額度
            let availableString = amountInputStyleView.availableBalanceAmountLabel.text ?? "0"
            amountInputStyleView.maxAmount = ( (availableString.toDouble() > maxString.toDouble()) ? maxString :availableString)
        }else
        {
            amountInputStyleView.availableBalanceAmountLabel.text = "0.00"
            amountInputStyleView.maxAmount = "0"
        }
    }
    func bindWhenAppear()
    {
        AuthorizeService.share.rxShowAlert().subscribeSuccess { alertVC in
            if let _ = UIApplication.topViewController() as? WithdrawNewViewController
            {
                UIApplication.topViewController()?.present(alertVC, animated: true, completion: nil)
            }
        }.disposed(by: sacnerDpg)
    }
    func bindAction()
    {
        withdrawToView.rxScanImagePressed().subscribeSuccess { [self](_) in
            Log.i("開鏡頭")
            if AuthorizeService.share.authorizeAVCapture()
            {
                isScanVCByAVCapture = true
                Log.v("開始使用相機相簿")
                
                scanVC.rxSacnSuccessAction().subscribeSuccess { [self](stringCode) in
                    isScanPopAction = false
//                    withdrawToView.textField.text = stringCode
//                    withdrawToView.textField.sendActions(for: .valueChanged)
                    withdrawToView.textField.placeholder = ""
                    withdrawToView.textView.text = stringCode.transToFour()
                    changeWithdrawInputViewHeight(constant: 72.0)
                }.disposed(by: dpg)
                isScanPopAction = true
                self.navigationController?.pushViewController(scanVC, animated: true)
            }
        }.disposed(by: dpg)
        withdrawToView.rxAddressBookImagePressed().subscribeSuccess { [self](_) in
            Log.i("開地址簿")
            showAddressBottomSheet()
        }.disposed(by: dpg)
        continueButton.rx.tap.subscribeSuccess { [self](_) in
            Log.i("開confirm")
            continueAction()
        }.disposed(by: dpg)
        withdrawToView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            withdrawToView.tfMaskView.changeBorderWith(isChoose:isChoose)
            let oldString = withdrawToView.textView.text.transWithoutSpace()
            withdrawToView.textView.text = oldString?.transToFour()
        }.disposed(by: dpg)
        withdrawToView.rxChangeHeightAction().subscribeSuccess { [self] heightValue in
            changeWithdrawInputViewHeight(constant: heightValue)
        }.disposed(by: dpg)
        
//        methodView.rxSelectNetworkMethodSheetClick().subscribeSuccess { _ in
//            Log.i("點到選network sheet")
//            self.showNetWorkBottomSheet()
//        }.disposed(by: dpg)
    }
    func showAddressBottomSheet()
    {
        let addressBottomSheet = AddressBottomSheet()
        addressBottomSheet.rxCleanDataClick().subscribeSuccess { [self] _ in
            clearAllData()
        }.disposed(by: dpg)
        addressBottomSheet.rxCellSecondClick().subscribeSuccess { [self](dataDto) in
//                withdrawToView.textView.text = dataDto.address
            withdrawToView.textField.placeholder = ""
            withdrawToView.textView.text = dataDto.address.transToFour()
            changeWithdrawInputViewHeight(constant: 72.0)
        }.disposed(by: dpg)
        addressBottomSheet.rxAddNewAddressClick()
            .subscribeSuccess { [self] _ in
                let addVC = AddNewAddressViewController.loadNib()
                addVC.rxDismissClick().subscribeSuccess {[self] _ in
                    showAddressBottomSheet()
                }.disposed(by: dpg)
                addVC.modalPresentationStyle = .popover
                self.present(addVC, animated: true)
            }.disposed(by: dpg)
       
        DispatchQueue.main.async { [self] in
            addressBottomSheet.start(viewController: self, height: addressViewSheetHeight())
        }
    }
    func showNetWorkBottomSheet()
    {
        let networkBottomSheet = NetworkBottomSheet()
        networkBottomSheet.dataArray = transDataSourceToNetworkDto()
        networkBottomSheet.rxCellSecondClick().subscribeSuccess { [self](dataDto) in
//            methodView.textField.text = dataDto.name
        }.disposed(by: dpg)
    
        DispatchQueue.main.async { [self] in
            networkBottomSheet.start(viewController: self, height: networkViewSheetHeight())
        }
    }
    func addressViewSheetHeight() -> CGFloat
    {
        var sheetHeight = 251.0
        var cellCount = 0.0
        let isOn = KeychainManager.share.getWhiteListOnOff()
        var allAddressList:[AddressBookDto] = []
        if isOn == true
        {
            allAddressList = KeychainManager.share.getAddressBookList()
            allAddressList = allAddressList.filter({ $0.enabled == true })
        }else
        {
            allAddressList = KeychainManager.share.getAddressBookList()
        }
        cellCount = (allAddressList.count >= 3 ? 3 :(allAddressList.count == 2 ? 2:1))
        sheetHeight += 92.0 * (cellCount - 1)
        return sheetHeight
    }
    func networkViewSheetHeight() -> CGFloat
    {
        var sheetHeight = 251.0
        var cellCount = 0
        
        cellCount = dropDataSource.count
        sheetHeight += 92.0 * Double((cellCount - 1))
        return sheetHeight
    }
    func transDataSourceToNetworkDto() -> [SelectNetworkMethodDetailDto]
    {
        var newData : [SelectNetworkMethodDetailDto] = []
        for data in dropDataSource
        {
            let subData = SelectNetworkMethodDetailDto(name: data)
            newData.append(subData)
        }
        return newData
    }
    func changeWithdrawInputViewHeight(constant:CGFloat)
    {
        DispatchQueue.main.async(execute: { [self] in
            withdrawToView.tvHeightConstraint.constant = constant
            middleHeight.constant = 80.0 + (constant - 46.0)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        })
    }
    func bindTextField()
    {
        let isAmountValid = amountInputStyleView.amountTextView.rx.text
            .map { [weak self] (str) -> Bool in
                guard let _ = self, let acc = str else { return false  }
                return RegexHelper.match(pattern: .moneyAmount, input: acc)
                    && acc.toDouble() >= 10.0
            }
        let isAddressValid = withdrawToView.textView.rx.text
//        let isAddressValid = withdrawToView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let _ = self, let acc = str else { return false  }
                return RegexHelper.match(pattern: .coinAddress, input: acc.transWithoutSpace() ?? "")
        }
//        isAddressValid.skip(1).bind(to: withdrawToView.invalidLabel.rx.isHidden).disposed(by: dpg)
        
        let currencyArray = currencyLabel.text?.split(separator: "-") ?? [""]
//        let isProtocolValid = methodView.textField.rx.text
//            .map { [weak self] (str) -> Bool in
//                guard let _ = self, let acc = str else { return false  }
//                return !acc.isEmpty
//        }
        Observable.combineLatest(isAmountValid,isAddressValid)
            .map { return $0.0 && $0.1 && !currencyArray.last!.isEmpty } //reget match result
            .bind(to: continueButton.rx.isEnabled)
            .disposed(by: dpg)
        
//        let _ =  withdrawToView.textField.rx.text.map({$0 ?? ""})
//            .map({$0.isEmpty})
//            .bind(to: withdrawToView.cancelRightButton.rx.isHidden)
//            .disposed(by: dpg)
        amountInputStyleView.amountTextView.rx.text.changed.subscribeSuccess { [self](_) in
            if let amount = Double(amountInputStyleView.amountTextView.text!),
               let fee = Double(feeAmountLabel.text!)
            {
                let result = (amount > fee ?  amount - fee : 0.0)
                // 小數點兩位的寫法
//                receiveAmountLabel.text = String(format: "%.2f", result)
                receiveAmountLabel.text = String(format: "%.8f", result).numberFormatter(.decimal, 8)
            }
        }.disposed(by: dpg)
    }
    func continueAction()
    {
//        if let _ = withdrawToView.textField.text
        if let _ = withdrawToView.textView.text ,
           let cryptoString = currencyLabel.text?.split(separator: "-").first ,
           let networkString = currencyLabel.text?.split(separator: "-").last
        {
            let totleAmountText = amountInputStyleView.amountTextView.text ?? ""
            let tetherText = "\(cryptoString)"
            let networkText = "\(networkString)"
            let feeText = feeAmountLabel.text ?? ""
            let addressText = withdrawToView.textView.text.transWithoutSpace() ?? ""
            let confirmData = ConfirmWithdrawDto(totalAmount: totleAmountText,
                                                 tether: String(tetherText),
                                                 network: networkText,
                                                 fee: feeText,
                                                 address: addressText)
            
            confirmBottomSheet = ConfirmBottomSheet(confirmData:confirmData)
            confirmBottomSheet.rxSecondConfirmAction().subscribeSuccess { [self](_) in
                Log.i("開驗證")
                showSecurityVC()
            }.disposed(by: dpg)
            DispatchQueue.main.async { [self] in
                confirmBottomSheet.start(viewController: self,height: height(674.0/896.0))
            }
        }else
        {
            
        }
    }
    func showSecurityVC()
    {
        if let type = MemberAccountDto.share?.withdrawWhitelistSecurityType
        {
            securityVerifyVC = SecurityVerificationViewController.loadNib()
            //        securityVerifyVC.securityViewMode = .defaultMode
            securityVerifyVC.securityViewMode = type
            securityVerifyVC.rxVerifySuccessClick().subscribeSuccess { [self](emailVerifyString,_) in
                // 開啟驗證流程
                Log.i("驗證成功,開取款單")
                toCreateWithdrawal(emailVerifyValue: emailVerifyString)
            }.disposed(by: dpg)
            self.navigationController?.pushViewController(securityVerifyVC, animated: true)
        }
    }
    func toCreateWithdrawal(emailVerifyValue : String , twoFAValue:String = "")
    {
        // 目前API並沒有驗證 驗證碼,等API更新
//        if let textString = withdrawToView.textField.text,
        if let textString = withdrawToView.textView.text.transWithoutSpace(),
            let amountText = amountInputStyleView.amountTextView.text,
           let _ = feeAmountLabel.text
        {
            LoadingViewController.show()
            var fAddressString = ""
            if let fAddress = WalletAllBalancesDto.share?.wallets?.filter({$0.currency == "USDT"}).first?.address
            {
                fAddressString = fAddress
            }
            Beans.walletServer.walletWithdraw(amount: amountText,
                                              fAddress: fAddressString,
                                              tAddress: textString ,
                                              verificationCode: emailVerifyValue)
            .subscribe { [self] dto in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    _ = LoadingViewController.dismiss().subscribeSuccess({ [self] _ in
                        if let dataDto = dto
                        {
                            let combineData = combineDetailData(dataDto: dataDto)
                            // 測試錯誤
//                            let combineData = combineDetailData(withdrawStatus: false)
//                            combineData.address = textString
                            securityVCPopAction(animated: false)
                            showTransactionDetailView(detailData: combineData)
                        }
                    }).disposed(by: dpg)
                }
            } onError: { error in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    _ = LoadingViewController.dismiss().subscribeSuccess({ [self] _ in
                        if let error = error as? ApiServiceError {
                            switch error {
                            case .errorDto(let dto):
                                let status = dto.httpStatus ?? ""
                                let reason = dto.reason
                                if status == "400"
                                {
                                    if reason == "CODE_MISMATCH" || reason == "CODE_NOT_FOUND"
                                    {
                                        Log.i("驗證碼錯誤 :\(reason)")
                                        if securityVerifyVC.securityViewMode == .onlyEmail
                                        {
                                            securityVerifyVC.twoWayVerifyView.emailInputView.invalidLabel.isHidden = false
                                            securityVerifyVC.twoWayVerifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                                        }else if securityVerifyVC.securityViewMode == .onlyMobile
                                        {
                                            securityVerifyVC.twoWayVerifyView.mobileInputView.invalidLabel.isHidden = false
                                            securityVerifyVC.twoWayVerifyView.mobileInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                                        }else if securityVerifyVC.securityViewMode == .defaultMode
                                        {
                                            securityVerifyVC.twoWayVerifyView.emailInputView.invalidLabel.isHidden = false
                                            securityVerifyVC.twoWayVerifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                                            InputViewStyleThemes.share.emailAcceptInputHeightStyle(.emailInvalidShow)
                                        }
                                    }else if reason == "TO_ADDRESS_OWN_BY_CUSTOMER"
                                    { // 取款address是 自己的address
                                        securityVCPopAction(animated: true)
                                        let results = ErrorDefaultDto(code: "", reason: "Unable to withdraw own address", timestamp: 0, httpStatus: "", errors: [])
                                        ErrorHandler.show(error: ApiServiceError.errorDto(results))
                                    }else if reason == "INSUFFICIENT_FUND"
                                    {
                                        Log.i("資金不足 :\(reason)")
                                        securityVCPopAction(animated: true)
                                        ErrorHandler.show(error: error)
                                    }else if reason == "T0_ADDRESS_NOT_IN_WHITE_LIST"
                                    {
                                        Log.i("帳號在白名單內 :\(reason)")
                                        securityVCPopAction(animated: true)
                                        ErrorHandler.show(error: error)
                                    }
//                                    ErrorHandler.show(error: error)
                                }else
                                {
                                    securityVCPopAction(animated: true)
                                    ErrorHandler.show(error: error)
                                }
                            default:
                                let combineData = combineDetailData(withdrawStatus: false)
                                combineData.address = textString
                                securityVCPopAction(animated: true)
                                showTransactionDetailView(detailData: combineData)
                                ErrorHandler.show(error: error)
                            }
                        }
                    }).disposed(by: dpg)
                }
            }.disposed(by: dpg)
        }
        else
        {
            securityVCPopAction(animated: true)
            Log.i("輸入資訊有誤")
        }
    }
    func securityVCPopAction(animated:Bool)
    {
        clearAllData()
        securityVerifyVC.navigationController?.popViewController(animated: animated)
    }
    func combineDetailData(dataDto : WalletWithdrawDto = WalletWithdrawDto(),
                           withdrawStatus:Bool = true) -> DetailDto
    {
        if withdrawStatus == true ,
           let transDto = dataDto.transaction ,
           let amountText = transDto.walletAmountIntWithDecimal?.stringValue?.numberFormatter(.decimal , 8),
           let fee = feeAmountLabel.text
        {
            let conBlocks = dataDto.transaction?.confirmBlocks ?? 0
            let detailData = DetailDto(detailType: dataDto.detailType,
                                       amount: amountText,
                                       tether: transDto.currency ,
                                       network: "Tron(TRC20)",
                                       confirmations: "\(conBlocks)",
                                       fee:fee,
                                       date: dataDto.createdDateString,
                                       address: transDto.toAddress,
                                       fromAddress: transDto.fromAddress,
                                       txid: transDto.txId ?? "",
                                       id:transDto.id,
                                       orderId: transDto.orderId,
                                       confirmBlocks: transDto.confirmBlocks ?? 0,
                                       showMode: .withdrawals,
                                       type: transDto.type)
           return detailData
        }else
        {
            let detailData = DetailDto(detailType: .failed,
                                       amount: amountInputStyleView.amountTextView.text ?? "",
                                       tether: "USDT" ,
                                       network: "Tron(TRC20)",
                                       confirmations: "",
                                       fee: "",
                                       date: dataDto.createdDateString,
                                       address: "",
                                       fromAddress: "",
                                       txid: "",
                                       id: "",
                                       orderId: "",
                                       confirmBlocks: 0,
                                       showMode: .withdrawals,
                                       type: "WITHDRAW")
            return detailData
        }
    }
    func showTransactionDetailView(detailData : DetailDto)
    {
        detailVC = WDetailViewController.instance(titleString: "Withdraw",
                                                      dataDto: detailData)
//            // 0818 產品驗收 topView 隱藏
//            let detailVC = TDetailViewController.instance(titleString: "Withdraw".localized,
//                                                          mode: .topViewHidden ,
//                                                          buttonMode: .buttonShow,
//                                                          dataDto:detailData)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    func clearAllData ()
    {
        if isScanPopAction == false
        {
            amountInputStyleView.amountTextView.text = "0"
//            withdrawToView.textField.text = ""
//            withdrawToView.textField.sendActions(for: .valueChanged)
            withdrawToView.textField.placeholder = InputViewMode.withdrawToAddress.textPlacehloder()
            withdrawToView.textView.text = ""
            changeWithdrawInputViewHeight(constant: 46.0)
        }
    }
    func setDataFromTryAgain(amount:String , address:String)
    {
        amountInputStyleView.amountTextView.text = amount
        withdrawToView.textView.text = address.transWithoutSpace() ?? ""
        changeWithdrawInputViewHeight(constant: 72.0)
        withdrawToView.textField.placeholder = ""
    }
}
// MARK: -
// MARK: 延伸
extension WithdrawNewViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
