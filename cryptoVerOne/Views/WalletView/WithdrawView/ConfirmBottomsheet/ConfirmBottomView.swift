//
//  ConfirmBottomView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/13.
//

import Foundation
import RxCocoa
import RxSwift

class ConfirmBottomView: UIView {
    // MARK:業務設定
    private let onConfirmClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var confirmData : ConfirmWithdrawDto = ConfirmWithdrawDto() {
        didSet{
            resetUI()
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var confirmButton: CornerradiusButton!
    @IBOutlet weak var withdrawToView: UIView!
    @IBOutlet weak var currencyImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var tetherValueLabel: UILabel!
    @IBOutlet weak var networkValueLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var totalAmountValueLabel: UILabel!
    @IBOutlet weak var topListView: UIView!
    
    @IBOutlet weak var introduceLabel: UILabel!
    var withdrawToInputView : InputStyleView!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        withdrawToInputView = InputStyleView(inputViewMode: .withdrawAddressToConfirm)
        withdrawToView.addSubview(withdrawToInputView)
        withdrawToInputView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        topListView.layer.borderWidth = 1
        topListView.layer.borderColor = Themes.grayE0E5F2.cgColor
    }
    func resetUI()
    {
        totalAmountValueLabel.text = confirmData.totalAmount.numberFormatter(.decimal , 8)
        feeValueLabel.text = confirmData.fee
        networkValueLabel.text = confirmData.network
        tetherValueLabel.text = confirmData.tether
        withdrawToInputView.setVisibleString(string: confirmData.address.transToFour())
        let stringHeight = confirmData.address.transToFour().height(withConstrainedWidth: (Views.screenWidth - 80), font: Fonts.PlusJakartaSansRegular(16))
        withdrawToInputView.tvHeightConstraint.constant = (stringHeight + 13)
        
//        introduceLabel.snp.updateConstraints { (make) in
//            make.top.equalTo(withdrawToInputView.tfMaskView.snp.bottom).offset(10)
//        }
        let feeD = MemberAccountDto.share?.currentFee(withCurrency: confirmData.tether) ?? 1.0
        if let totalAmount = Double(confirmData.totalAmount)
        {
            let result = (totalAmount > feeD ?  totalAmount - feeD : 0.0)
            // 小數點兩位的寫法
//                receiveAmountLabel.text = String(format: "%.2f", result)
            amountLabel.text = String(format: "%.8f", result).numberFormatter(.decimal, 8)
        }
    }
    func bindUI()
    {
        withdrawToInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            withdrawToInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
        confirmButton.rx.tap.subscribeSuccess { [self](_) in
            onConfirmClick.onNext(())
        }.disposed(by: dpg)
    }
    func rxConfirmAction() -> Observable<Any>
    {
        return onConfirmClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
