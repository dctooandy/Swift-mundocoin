//
//  WithdrawViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import RxCocoa
import RxSwift
import DropDown

class WithdrawViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let onConfirmClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // 如果是一個 就灰色不給選,多個才會有下拉選單
    var dropDataSource = ["TRC20"]
    var isScanPopAction = false
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var availableBalanceAmountLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyIconImageView: UIImageView!
    @IBOutlet weak var withdrawToInputView: UIView!
    @IBOutlet weak var methodInputView: UIView!
    @IBOutlet weak var feeTitle: UILabel!
    @IBOutlet weak var receiveTitle: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var receiveAmountLabel: UILabel!
    @IBOutlet weak var continueButton: CornerradiusButton!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var amountInputView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var amountView : AmountInputView!
    var withdrawToView : InputStyleView!
    var methodView : InputStyleView!
    var confirmBottomSheet : ConfirmBottomSheet!
    var securityVerifyVC : SecurityVerificationViewController!
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
        title = "Withdraw"
        setupUI()
        bindAction()
        bindTextField()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        clearAllData()
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
    func setupUI()
    {
        view.backgroundColor = Themes.grayF4F7FE
        let minString = "10"
        let maxString = "10000"
        amountView = AmountInputView.loadNib()
//        // 設定最高額度
//        let availableString = availableBalanceAmountLabel.text ?? "0"
//        amountView.maxAmount = ( (availableString.toDouble() > maxString.toDouble()) ? maxString :availableString)
        // 設定幣種
        amountView.currency = currencyLabel.text ?? "USDT"

        amountView.amountTextView.text = "0"
        amountInputView.addSubview(amountView)
        amountView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        feeTitle.text = "Fee (USDT)".localized
        receiveTitle.text = "Receive amount (USDT)".localized
        rangeLabel.text = "Min: \(minString) USDT - Max: \(maxString.numberFormatter(.decimal, 0)) USDT".localized
        feeAmountLabel.text = "1.00"
        receiveAmountLabel.text = "0.00"
        noticeLabel.text = "Please ensure that the address is correct and on the same network.".localized
        withdrawToView = InputStyleView(inputViewMode: .withdrawToAddress)
        methodView = InputStyleView(inputViewMode: .networkMethod(dropDataSource))
        
        withdrawToInputView.addSubview(withdrawToView)
        methodInputView.addSubview(methodView)
        withdrawToView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        methodView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        continueButton.titleLabel?.font = Fonts.pingFangTCRegular(16)
        continueButton.setTitle("Continue".localized, for: .normal)
        continueButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        continueButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
    }
    func setUPData(withdrawDatas : [WalletBalancesDto])
    {
        let maxString = "10000"
        if let data = withdrawDatas.filter({ $0.token == "USDT" }).first
        {
            availableBalanceAmountLabel.text = "\(String(describing: data.amount))"
            // 設定最高額度
            let availableString = availableBalanceAmountLabel.text ?? "0"
            amountView.maxAmount = ( (availableString.toDouble() > maxString.toDouble()) ? maxString :availableString)
        }
    }
    func bindAction()
    {
        withdrawToView.rxScanImagePressed().subscribeSuccess { [self](_) in
            Log.i("開鏡頭")
            let scanVC = ScannerViewController()
            scanVC.rxSacnSuccessAction().subscribeSuccess { [self](stringCode) in
                isScanPopAction = false
                withdrawToView.textField.text = stringCode
                withdrawToView.textField.sendActions(for: .valueChanged)
            }.disposed(by: dpg)
            isScanPopAction = true
            self.navigationController?.pushViewController(scanVC, animated: true)
        }.disposed(by: dpg)
        withdrawToView.rxAddressBookImagePressed().subscribeSuccess { [self](_) in
            Log.i("開地址簿")
            let addressBottomSheet = AddressBottomSheet()
            addressBottomSheet.rxCellSecondClick().subscribeSuccess { [self](dataDto) in
                withdrawToView.textField.text = dataDto.address
                withdrawToView.textField.sendActions(for: .valueChanged)
            }.disposed(by: dpg)
            DispatchQueue.main.async {
                addressBottomSheet.start(viewController: self)
            }
        }.disposed(by: dpg)
        continueButton.rx.tap.subscribeSuccess { [self](_) in
            Log.i("開confirm")
            continueAction()
        }.disposed(by: dpg)
        withdrawToView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            withdrawToView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
    }
    func bindTextField()
    {
        let isAmountValid = amountView.amountTextView.rx.text
            .map { [weak self] (str) -> Bool in
                guard let _ = self, let acc = str else { return false  }
                return RegexHelper.match(pattern: .moneyAmount, input: acc)
                    && acc.toDouble() >= 10.0
            }
        
        let isAddressValid = withdrawToView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let _ = self, let acc = str else { return false  }
                return RegexHelper.match(pattern: .coinAddress, input: acc)
        }
        isAddressValid.skip(1).bind(to: withdrawToView.invalidLabel.rx.isHidden).disposed(by: dpg)
        let isProtocolValid = methodView.textField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let _ = self, let acc = str else { return false  }
                return !acc.isEmpty
        }
        Observable.combineLatest(isAmountValid,isAddressValid, isProtocolValid)
            .map { return $0.0 && $0.1 && $0.2 } //reget match result
            .bind(to: continueButton.rx.isEnabled)
            .disposed(by: dpg)
        
        let _ =  withdrawToView.textField.rx.text.map({$0 ?? ""})
            .map({$0.isEmpty})
            .bind(to: withdrawToView.cancelRightButton.rx.isHidden)
            .disposed(by: dpg)
        amountView.amountTextView.rx.text.changed.subscribeSuccess { [self](_) in
            if let amount = Double(amountView.amountTextView.text!),
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
        if let _ = withdrawToView.textField.text
        {
            let totleAmountText = amountView.amountTextView.text ?? ""
            let tetherText = currencyLabel.text  ?? ""
            let networkText = methodView.textField.text ?? ""
            let feeText = feeAmountLabel.text ?? ""
            let addressText = withdrawToView.textField.text ?? ""
            let confirmData = ConfirmWithdrawDto(totalAmount: totleAmountText,
                                                 tether: tetherText,
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
        securityVerifyVC = SecurityVerificationViewController.loadNib()
        securityVerifyVC.securityViewMode = .defaultMode
        securityVerifyVC.rxVerifySuccessClick().subscribeSuccess { [self](_) in
            Log.i("驗證成功,開Detail")
            showTransactionDetailView()
            clearAllData()
        }.disposed(by: dpg)
        self.navigationController?.pushViewController(securityVerifyVC, animated: true)
    }
    func showTransactionDetailView()
    {
        if let textString = withdrawToView.textField.text,
            let amountText = amountView.amountTextView.text,
           let fee = feeAmountLabel.text
        {
            let detailData = DetailDto(defailType: .done,
                                       amount: amountText,
                                       tether: "USDT",
                                       network: "Tron(TRC20)",
                                       confirmations: "50/1",
                                       fee:fee,
                                       date: "April18,2022 11:01",
                                       address: textString,
                                       txid: "37f5d6c3d1c4408a47e34601febd78 ad9be79473df71742805a8b2a339c25b9e")
            let detailVC = TDetailViewController.loadNib()
            detailVC.titleString = "Withdraw"
            detailVC.detailDataDto = detailData
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    func clearAllData ()
    {
        if isScanPopAction == false
        {
            amountView.amountTextView.text = "0"
            withdrawToView.textField.text = ""
            withdrawToView.textField.sendActions(for: .valueChanged)
        }
    }
    func rxConfirmClick() -> Observable<Any>
    {
        return onConfirmClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
extension WithdrawViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
