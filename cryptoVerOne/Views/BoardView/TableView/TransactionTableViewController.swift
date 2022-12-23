//
//  TransactionTableViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/6/22.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class TransactionTableViewController: BaseViewController {
    // MARK:業務設定
    private let onPullUpToAddRow = PublishSubject<Any>()
    private let onPullDownToRefrash = PublishSubject<Any>()
    private let dpg = DisposeBag()
    private var didSelectCell : Bool = false
    var isFilterAction : Bool = false
    var showModeAtTableView : TransactionShowMode = .deposits{
        didSet{
            setup()
        }
    }
    var data:[ContentDto] = [] {
        didSet{
            createData()
            tableViewEndRefreshAction()
        }
    }
    var sectionDic:[String:[ContentDto]] = [:]
    let refresher = UIRefreshControl()
    // MARK: -
    // MARK:UI 設定
    var verifyView = TwoFAVerifyView()
    var headerView: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var bottomRefrash: UIView?
    // MARK: -
    // MARK:Life cycle
    // MARK: instance
    static func instance(mode: TransactionShowMode) -> TransactionTableViewController {
        let vc = TransactionTableViewController.loadNib()
        vc.showModeAtTableView = mode
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Themes.grayF4F7FE
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if didSelectCell == false , isFilterAction == false
        {
            startRefresh()
        }
        isFilterAction = false
        didSelectCell = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        verifyView.cleanTimer()
    }
    // MARK: -
    // MARK:業務方法

    func setup()
    {
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: TransHistoryCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundView = NoDataView(image: UIImage(named: "empty-list"), title: "No records found" , subTitle: "You have no transactions")
        tableView.backgroundView?.isHidden = false
        refresher.rx.controlEvent(.valueChanged).subscribeSuccess { [weak self] (_) in
            self?.startRefresh()
        }.disposed(by: disposeBag)
        tableView?.addSubview(refresher)
        self.bottomRefrash = tableView.footerRefrashView()
    }
    private func startRefresh() {
        clearData()
        onPullDownToRefrash.onNext(())
    }
    func clearData()
    {
        sectionDic.removeAll()
        tableView.backgroundView?.isHidden = false
        tableView.reloadData()
    }
    func createData()
    {
//        sectionDic.removeAll()
        var daySactionStringArray:[String] = []
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "MMMM dd,yyyy"
        for dataDto in data {
            // 將時間戳轉換成 TimeInterval
            let timeInterval = TimeInterval(dataDto.createdDateTimeInterval)
            // 初始化一個 Date
            let date = Date(timeIntervalSince1970: timeInterval)
            let currentTimeString = newFormatter.string(from: date )
            let newTimeInt = newFormatter.date(from: currentTimeString)?.timeIntervalSince1970
            if let timeString = newTimeInt?.intervalToString()
            {
                if !daySactionStringArray.contains(timeString)
                {
                    daySactionStringArray.append(timeString)
                }
                if sectionDic[timeString] != nil
                {
                    sectionDic[timeString]?.append(dataDto)
                }else
                {
                    sectionDic[timeString] = [dataDto]
                }
            }
        }
    }
    func tableViewEndRefreshAction()
    {
        refresher.endRefreshing()
        tableView.tableFooterView = nil
        tableView.backgroundView?.isHidden = sectionDic.keys.count > 0 ? true : false
        tableView.reloadData()
    }
    func modeTitle() -> String {
        switch showModeAtTableView
        {
        case .all:
            return  "All".localized
        case .deposits:
            return  "Deposits".localized
        case .withdrawals:
            return  "Withdrawals".localized
        }
    }
    func pushToDetailVC(contentDto:ContentDto)
    {
        
        if let amountValue = (contentDto.type != "DEPOSIT" ?  contentDto.walletAmountIntWithDecimal?.stringValue?.numberFormatter(.decimal , 8) :contentDto.walletDepositAmountIntWithDecimal?.stringValue?.numberFormatter(.decimal , 8)),
           let feeString = contentDto.fees != nil ? (contentDto.fees! > 0 ? "\(contentDto.fees!)": "1")  : "\(MemberAccountDto.share?.fee ?? 1.0)"
        {
            let conBlocks = contentDto.confirmBlocks ?? 0
            let detailData = DetailDto(detailType: contentDto.detailType,
                                       amount:amountValue,
                                       tether: contentDto.currency,
                                       network: "Tron(TRC20)",
                                       confirmations: "\(conBlocks)",
                                       fee:feeString,
                                       date: contentDto.createdDateString,
                                       address: contentDto.toAddress,
                                       fromAddress: contentDto.fromAddress,
                                       txid: contentDto.txId ?? "",
                                       id: contentDto.id,
                                       orderId: contentDto.orderId,
                                       confirmBlocks: contentDto.confirmBlocks ?? 0,
                                       showMode: showModeAtTableView,
                                       type: contentDto.type)
            let detailVC = TDetailViewController.instance(titleString: contentDto.showTitleString,
                                                          mode: .topViewHidden ,
                                                          buttonMode: .buttonHidden,
                                                          dataDto:detailData)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    func rxPullUpToAddRow() -> Observable<Any>
    {
        return onPullUpToAddRow.asObserver()
    }
    func rxPullDownToRefrash() -> Observable<Any>
    {
        return onPullDownToRefrash.asObserver()
    }
}
// MARK: -
// MARK: 延伸
extension TransactionTableViewController:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionCount = sectionDic.keys.count
        return sectionCount
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let keyArray = Array(sectionDic.keys).sorted(by: >)
        if let rowNumber = sectionDic[keyArray[section]]?.count
        {
            return rowNumber
        }else
        {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: TransHistoryCell.self, indexPath: indexPath)
        let keyArray = Array(sectionDic.keys).sorted(by: >)
        if let rowData = sectionDic[keyArray[indexPath.section]]
        {
            let currentData = rowData.sorted(by: { $0.createdDateTimeInterval > $1.createdDateTimeInterval })
            cell.setData(data: currentData[indexPath.item] ,type: showModeAtTableView)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keyArray = Array(sectionDic.keys).sorted(by: >)
        if let rowData = sectionDic[keyArray[indexPath.section]]
        {
            didSelectCell = true
            let currentData = rowData.sorted(by: { $0.createdDateTimeInterval > $1.createdDateTimeInterval })
            Log.v("currentData \(currentData[indexPath.item])")
            pushToDetailVC(contentDto: currentData[indexPath.item])
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.headerView = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 24))
        let keyArray = Array(sectionDic.keys).sorted(by: >)
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "MMMM dd,yyyy"
        let timeInterval = TimeInterval(keyArray[section])
        // 初始化一個 Date
        let date = Date(timeIntervalSince1970: timeInterval!)
        //            let startDate = oldFormatter.date(from: dataDto.date)
        let currentTimeString = newFormatter.string(from: date )
        self.headerView.text = currentTimeString
        self.headerView.textAlignment = .center
        self.headerView.backgroundColor = .clear
        self.headerView.textColor = Themes.gray707EAE
        self.headerView.font = Fonts.PlusJakartaSansMedium(14)
        return self.headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refresher.isRefreshing {
//            refreshing()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        
//        if scrollView == self.tableView{
//            let offset = scrollView.contentOffset
//            let bouns = scrollView.bounds
//            let size = scrollView.contentSize
//            let inset = scrollView.contentInset
//            let y = offset.y + bouns.size.height - inset.bottom
//            let h = size.height
//            let reloadDistence = 50.0
//            if y > h + CGFloat(reloadDistence){
//                tableView.tableFooterView = self.bottomRefrash
//                print("底部刷新資料")
//                 self.onPullUpToAddRow.onNext(())
//            }
//        }
        if scrollView == tableView {
            let offset = scrollView.contentOffset
            if offset.y > 0
            {
                let bouns = scrollView.bounds
                let size = scrollView.contentSize
                let inset = scrollView.contentInset
                let y:CGFloat = offset.y + bouns.size.height - inset.bottom
//                let h:CGFloat = size.height
                let reloadDistence = 50.0
                let newH = size.height + CGFloat(reloadDistence) + Views.tabBarHeight
                if y > newH {
                    tableView.tableFooterView = bottomRefrash
                    print("底部刷新資料")
                    self.onPullUpToAddRow.onNext(())
                }
            }
        }
    }
}
