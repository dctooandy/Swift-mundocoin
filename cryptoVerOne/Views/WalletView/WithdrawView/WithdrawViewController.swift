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
    var withdrawToView : InputStyleView!
    var methodView : InputStyleView!
    var confirmBottomSheet : ConfirmBottomSheet!
    var securityVerifyVC : SecurityVerificationViewController!
    // MARK: -
    // MARK:Life cycle
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
        feeTitle.text = "Fee (USDT)".localized
        receiveTitle.text = "Receive amount (USDT)".localized
        rangeLabel.text = "Min: 10 USDT - Max: 10,000 USDT".localized
        feeAmountLabel.text = "1.00"
        receiveAmountLabel.text = "499.0"
        noticeLabel.text = "Please ensure that the address is correct and on the same network.".localized
        withdrawToView = InputStyleView(inputViewMode: .withdrawTo)
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
            
            DispatchQueue.main.async {
                addressBottomSheet.start(viewController: self)
            }
        }.disposed(by: dpg)
        continueButton.rx.tap.subscribeSuccess { [self](_) in
            continueAction()
        }.disposed(by: dpg)
    }
    func bindTextField()
    {
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
        Observable.combineLatest(isAddressValid, isProtocolValid)
            .map { return $0.0 && $0.1 } //reget match result
            .bind(to: continueButton.rx.isEnabled)
            .disposed(by: dpg)
        
        let _ =  withdrawToView.textField.rx.text.map({$0 ?? ""})
            .map({$0.isEmpty})
            .bind(to: withdrawToView.cancelRightButton.rx.isHidden)
            .disposed(by: dpg)
    }
    func continueAction()
    {
        confirmBottomSheet = ConfirmBottomSheet()
        confirmBottomSheet.rxSecondConfirmAction().subscribeSuccess { [self](_) in
            showSecurityVC()
        }.disposed(by: dpg)
        DispatchQueue.main.async { [self] in
            confirmBottomSheet.start(viewController: self,height: height(674.0/896.0))
        }
    }
    func showSecurityVC()
    {
        securityVerifyVC = SecurityVerificationViewController.loadNib()
        securityVerifyVC.securityViewMode = .defaultMode
        securityVerifyVC.rxVerifySuccessClick().subscribeSuccess { (_) in
            Log.i("驗證成功")
        }.disposed(by: dpg)
        self.navigationController?.pushViewController(securityVerifyVC, animated: true)
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
