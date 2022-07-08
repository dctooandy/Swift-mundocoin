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
    // MARK: -
    // MARK:UI 設定
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
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
    
    
    
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackUI()
        setupUI()
        bindTabbar()
        bindViewModel()
        bindTxIdLable()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.tabBarController?.tabBar.isHidden = true
        AuditTabbar.share.detailTabbarView.isHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.resetTabbarHeight()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AuditTabbar.share.detailTabbarView.isHidden = true
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
        scrollView.backgroundColor = Themes.grayF4F7FE
    }
    func setupUI()
    {
        stackView.layer.cornerRadius = 12
        stackView.layer.masksToBounds = true
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
        let popVC =  AuditTriggerAlertView(alertMode: accept) {[self](acceptValue , memoString) in
            
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
        popVC.start(viewController: self)
    }
    func setupDate(cellData:WalletWithdrawDto ,showMode:AuditShowMode)
    {
        if let userDto = cellData.issuer , let transDto = cellData.transaction , let chainDto = cellData.chain?.first
        {
            self.data = cellData
            Log.v("chain :\n\(String(describing: cellData.chain))")
            Log.v("issur :\n\(userDto)")
            Log.v("transDto :\n\(transDto)")
            userIDLabel.text = userDto.email
            cryptoLabel.text = transDto.currency
            networkLabel.text = "TRC20"
            if let transAmountString = transDto.amountIntWithDecimal?.stringValue?.numberFormatter(.decimal,8)
            {
                withdrawAmountLabel.text = transAmountString
                feeLabel.text = "\(transDto.fees ?? 1)".numberFormatter(.decimal,2)
                let actualAmountValue = (Double(transAmountString.filterDecimal()) ?? 0.00) - Double((transDto.fees ?? 1))
                actualAmountLabel.text = "\(actualAmountValue)".numberFormatter(.decimal,8)
            }
            addressLabel.text = transDto.toAddress
            dateLabel.text = transDto.createdDateString
            self.showMode = showMode
            
            finishedView.isHidden = (showMode == .pending ? true : false)
            statusLabel.textColor = transDto.stateColor
            statusLabel.text = chainDto.state
//            commentTitleLabel.isHidden = (showMode == .pending ? true : (chainDto.memo?.isEmpty == nil || chainDto.memo?.isEmpty == true))
            commentLabel.text = chainDto.memo
            txidTitleLabel.isHidden = (showMode == .pending ? true : (transDto.txId?.isEmpty == nil || transDto.txId?.isEmpty == true))
            txidLabel.text = transDto.txId ?? ""
            
        }
    }
    func resetTabbarHeight(toLeave :Bool = false)
    {
        if toLeave == false
        {
//            AuditTabbar.share.snp.updateConstraints { make in
//                make.top.equalToSuperview().offset(self.showMode == .finished ? Views.screenHeight + 30 :Views.screenHeight - Views.baseTabbarHeight)
//            }
            AuditTabbar.share.snp.remakeConstraints { (make) in
                make.leading.bottom.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(self.showMode == .finished ? Views.screenHeight + 30 :Views.screenHeight - Views.baseTabbarHeight)
            }
        }else
        {
            AuditTabbar.share.snp.remakeConstraints { make in
                make.leading.bottom.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(Views.screenHeight - Views.baseTabbarHeight)
            }
        }
    }
}
// MARK: -
// MARK: 延伸
