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
    var dropDataSource = ["TRC20"]
    // MARK: -
    // MARK:UI 設定
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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        amountView = AmountInputView.loadNib()
        amountView.amountTextView.text = "0"
        amountInputView.addSubview(amountView)
        amountView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        feeTitle.text = "Fee (USDT)".localized
        receiveTitle.text = "Receive amount (USDT)".localized
        rangeLabel.text = "Min: 10 USDT - Max: 10,000 USDT".localized
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
    func bindAction()
    {
        withdrawToView.rxScanImagePressed().subscribeSuccess { [self](_) in
            Log.i("開鏡頭")
            let scanVC = ScannerViewController()
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
    }
    func bindTextField()
    {
        let isAmountValid = amountView.amountTextView.rx.text
            .map { [weak self] (str) -> Bool in
                guard let _ = self, let acc = str else { return false  }
                return RegexHelper.match(pattern: .moneyAmount, input: acc)
                    && acc != "0"
                    && acc != "0."
                    && acc != "0.0"
                    && acc != "0.00"
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
                return RegexHelper.match(pattern: .coinAddress, input: acc)
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
            if let amount = Float(amountView.amountTextView.text!)
            {
                let result = (amount > 1.0 ?  amount - 1.0 :0)
                
                receiveAmountLabel.text = String(format: "%.2f", result)
            }
        }.disposed(by: dpg)
    }
    func continueAction()
    {
        if let textString = withdrawToView.textField.text
        {
            confirmBottomSheet = ConfirmBottomSheet(address: textString)
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
        }.disposed(by: dpg)
        self.navigationController?.pushViewController(securityVerifyVC, animated: true)
    }
    func showTransactionDetailView()
    {
        if let textString = withdrawToView.textField.text
        {
            let detailVC = TDetailViewController.loadNib()
            detailVC.titleString = "Withdraw"
            detailVC.addressModel = textString
            self.navigationController?.pushViewController(detailVC, animated: true)
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
