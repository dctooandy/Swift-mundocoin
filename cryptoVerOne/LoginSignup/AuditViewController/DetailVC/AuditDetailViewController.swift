//
//  AuditDetailViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/13/22.
//

import Foundation
import RxCocoa
import RxSwift
import SnapKit
import UIKit
class AuditDetailViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private var dpg = DisposeBag()
    fileprivate var viewModel = AuditDetailViewModel()
    var data : WalletWithdrawDto!
    var showMode:AuditShowMode!
    {
        didSet{
            self.buttonView.isHidden = (self.showMode == .finished ? true : false)
        }
    }
    // MARK: -
    // MARK:UI 設定
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "audit-icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var normalView: UIView!
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var cryptoLabel: UILabel!
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var withdrawAmountLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var actualAmountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var finishedView: UIView!
    @IBOutlet weak var txidTitleLabel: UILabel!
    @IBOutlet weak var txidLabel: UnderlinedLabel!
    @IBOutlet weak var auditorLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var commentTitleLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var stackBackView: UIView!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackUI()
        setupUI()
        bindButton()
        bindViewModel()
        bindTxIdLable()
        resetTabbarHeight()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,.font: Fonts.SFProDisplayBold(20)]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetTabbarHeight(toLeave: true)
        dpg = DisposeBag()
    }
    // MARK: -
    // MARK:業務方法
    func setupBackUI()
    {
        title = "Detail".localized
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        view.backgroundColor = Themes.black1B2559
        scrollView.backgroundColor = Themes.grayF7F8FC
    }
    func setupUI()
    {
        stackBackView.applyCornerAndShadow(radius: 16)
        stackView.layer.cornerRadius = 12
        stackView.layer.masksToBounds = true
        acceptBtn.layer.cornerRadius = 8
        acceptBtn.layer.masksToBounds = true
        acceptBtn.setTitleColor(.white, for: .normal)
        rejectBtn.setTitleColor(Themes.gray33617D, for: .normal)
        rejectBtn.backgroundColor = Themes.grayE3EbF3
        rejectBtn.layer.borderColor = UIColor(rgb: 0x004116 ,alpha: 0.08).cgColor
        rejectBtn.layer.borderWidth = 1
        rejectBtn.layer.cornerRadius = 8
        rejectBtn.layer.masksToBounds = true
    }
    func bindButton()
    {
        acceptBtn.rx.tap.subscribeSuccess { [self] _ in
            showAlertView(accept: .accept)
        }.disposed(by: dpg)
        rejectBtn.rx.tap.subscribeSuccess { [self] _ in
            showAlertView(accept: .reject)
        }.disposed(by: dpg)
    }
    func bindTabbar()
    {
        let tabbar = AuditTabbar.share
        tabbar.rxLabelClick().subscribeSuccess { [self] accept in
            Log.v("結果\(accept)")
            showAlertView(accept: accept)
        }.disposed(by: dpg)
    }
    func bindViewModel()
    {
        viewModel.rxFetchSuccess().subscribeSuccess { dto in
            Log.v("完成提案 \(dto)")
            self.navigationController?.popToRootViewController(animated: true)
        }.disposed(by: dpg)
    }
    func bindTxIdLable()
    {
        txidLabel.rx.click.subscribeSuccess { [self] _ in
            let txidString = txidLabel.text ?? ""
            Log.v("outapp url str: \(txidString)")
            UIApplication.shared.open((URL(string: "https://shasta.tronscan.org/#/transaction/\(txidString)")!), options: [:], completionHandler: nil)
        }.disposed(by: dpg)
    }
    func showAlertView(accept:AuditTriggerMode)
    {
        let alertBottomSheet = AuditTriggerBottomSheet(alertMode: accept) {[self](acceptValue , memoString) in
            
            if acceptValue == true , let firstChainData = data.chain?.first {
                Log.i("Confirm or Reject")
                let approvalId = data.id ?? ""
                let approvalNodeId = firstChainData.id
                let approvalState = (accept == .accept ? "APPROVED" : "REJECT")
                let memo = memoString
                viewModel.goApproval(approvalId: approvalId, approvalNodeId: approvalNodeId, approvalState: approvalState, memo: memo)
            }else
            {
                Log.i("Cancel")
            }
        }
        alertBottomSheet.start(viewController: self ,height: 360)
    }
    func setupDate(cellData:WalletWithdrawDto ,showMode:AuditShowMode)
    {
        if let userDto = cellData.issuer , let transDto = cellData.transaction , let chainDto = cellData.chain?.first,
           let approver = chainDto.approver
        {
            self.data = cellData
            Log.v("chain :\n\(String(describing: cellData.chain))")
            Log.v("issur :\n\(userDto)")
            Log.v("transDto :\n\(transDto)")
            auditorLabel.text = approver.email
            userIDLabel.text = userDto.email
            cryptoLabel.text = transDto.currency
            networkLabel.text = "TRC20"
//            if let transAmountString = transDto.walletAmountIntWithDecimal?.stringValue?.numberFormatter(.decimal,8)
            if let withdrawAmountString = transDto.walletAmountIntWithDecimal?.stringValue?.numberFormatter(.decimal,8)
            {
                let feesValue = (transDto.fees ?? 1) < 1 ? 1 : (transDto.fees ?? 1)
                feeLabel.text = "\(feesValue)".numberFormatter(.decimal,2)
                let actualAmountValue = (Double(withdrawAmountString.filterDecimal()) ?? 0.00) - Double((feesValue))
                withdrawAmountLabel.text = "\(withdrawAmountString)".numberFormatter(.decimal,8)
                actualAmountLabel.text = "\(actualAmountValue)".numberFormatter(.decimal,8)
            }
            addressLabel.text = transDto.toAddress
            dateLabel.text = transDto.createdDateString
            self.showMode = showMode
            
            finishedView.isHidden = (showMode == .pending ? true : false)
            statusLabel.textColor = self.data.stateColor
            statusLabel.text = self.data.state
//            commentTitleLabel.isHidden = (showMode == .pending ? true : (chainDto.memo?.isEmpty == nil || chainDto.memo?.isEmpty == true))
            commentLabel.text = chainDto.memo?.filter({$0 != "\n"})
            txidTitleLabel.isHidden = (showMode == .pending ? true : (transDto.txId?.isEmpty == nil || transDto.txId?.isEmpty == true))
            txidLabel.text = transDto.txId ?? ""
        }
    }
    func resetTabbarHeight(toLeave :Bool = false)
    {
        if toLeave == false
        {
            AuditTabbar.share.snp.remakeConstraints { (make) in
                make.leading.bottom.trailing.equalToSuperview()
//                make.top.equalToSuperview().offset(self.showMode == .finished ? Views.screenHeight + 30 :Views.screenHeight - Views.baseTabbarHeight)
                make.top.equalToSuperview().offset(Views.screenHeight + 40)
            }
        }else
        {
            AuditTabbar.share.snp.remakeConstraints { make in
                make.leading.bottom.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(Views.screenHeight - Views.baseTabbarHeight)
            }
        }
    }
    override var preferredStatusBarStyle:UIStatusBarStyle {
        if #available(iOS 13.0, *) {
#if Approval_PRO || Approval_DEV || Approval_STAGE
            return .lightContent
#else
            return .darkContent
#endif
        } else {
            return .default
        }
    }
}
// MARK: -
// MARK: 延伸
