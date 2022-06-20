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
class AuditDetailViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private var dpg = DisposeBag()
    fileprivate var viewModel = AuditDetailViewModel()
    var data : WalletWithdrawDto!
    var showMode:AuditShowMode!
    // MARK: -
    // MARK:UI 設定
    lazy var auditBackBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left", title: "Back")
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var cryptoLabel: UILabel!
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var withdrawAmountLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var actualAmountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var commentTitleLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var txidLabel: UILabel!
    
    @IBOutlet var labelArray: [UILabel]!
    
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: auditBackBtn)
        bindTabbar()
        bindViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.tabBarController?.tabBar.isHidden = true
        AuditTabbar.share.detailTabbarView.isHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AuditTabbar.share.detailTabbarView.isHidden = true
        resetTabbarHeight(toLeave: true)
        dpg = DisposeBag()
    }
    // MARK: -
    // MARK:業務方法
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
            withdrawAmountLabel.text = "\(transDto.amount ?? 0)"
            feeLabel.text = "\(transDto.fees ?? 0)"
            let actualAmountValue = (transDto.amount ?? 0) - (transDto.fees ?? 0)
            actualAmountLabel.text = "\(actualAmountValue)"
            addressLabel.text = transDto.toAddress
            dateLabel.text = transDto.createdDateString
            self.showMode = showMode
            
            for item in labelArray {
                item.isHidden = (showMode == .pending ? true : false)
            }
            statusLabel.text = chainDto.state
            commentTitleLabel.isHidden = chainDto.memo.isEmpty
            commentLabel.text = chainDto.memo
            txidLabel.text = transDto.txId ?? ""
            resetTabbarHeight()
        }
    }
    func resetTabbarHeight(toLeave :Bool = false)
    {
        let tabbar = AuditTabbar.share
        if toLeave == false
        {
            tabbar.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(self.showMode == .finished ? Views.screenHeight + 30 :Views.screenHeight - Views.baseTabbarHeight)
            }
        }else
        {
            tabbar.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(Views.screenHeight - Views.baseTabbarHeight)
            }
        }
    }
}
// MARK: -
// MARK: 延伸
