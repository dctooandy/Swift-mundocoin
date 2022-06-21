//
//  SubListViewcontroller.swift
//  cryptoVerOne
//
//  Created by BBk on 6/13/22.
//

import Foundation
import RxCocoa
import RxSwift

class SubListViewcontroller: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
//    var dataArray = [AuditTransactionDto]()
    var dataArray : [WalletWithdrawDto] = []
    var showMode : AuditShowMode = .pending
    fileprivate let viewModel = SubListViewModel()
    let refresher = UIRefreshControl()
    var currentPage: Int = 0
    // MARK: -
    // MARK:UI 設定    
    @IBOutlet weak var tableView: UITableView!
    var bottomRefrash: UIView?
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPage = 0
        dataArray.removeAll()
        viewModel.fetch()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    static func instance(mode: AuditShowMode) -> SubListViewcontroller {
        let vc = SubListViewcontroller.loadNib()
        vc.showMode = mode
        return vc
    }
    // MARK: -
    // MARK:業務方法
    func setupTableView()
    {
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: SubListTableViewCell.self)
        tableView.separatorStyle = .none
        refresher.attributedTitle = NSAttributedString(string: "Pull To Refresh",
                                                            attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
//        refreshControl.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        refresher.rx.controlEvent(.valueChanged).subscribeSuccess { [weak self] (_) in
            self?.endRefresh()
        }.disposed(by: disposeBag)
        tableView?.addSubview(refresher)
        self.bottomRefrash = tableView.footerRefrashView()
    }
    func modeTitle() -> String {
        switch  showMode {
        case .pending: return "Pending".localized
        case .finished: return "Finished".localized
        }
    }
    private func endRefresh() {
        loadData()
    }
    func fetchData(currentPage:Int)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.viewModel.fetch(currentPage: currentPage)
        }
    }
    func bindViewModel()
    {
//        viewModel.rxFetchSuccess().subscribeSuccess { [self] _ in
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
//                _ = LoadingViewController.dismiss()
//                // 停止 refreshControl 動畫
//                refreshControl.endRefreshing()
//                dataArray.removeAll()
//                // 暫時拿來用
//                for indexName in 0...10 {
//                    dataArray.append(AuditTransactionDto(userid: "00000\(indexName)", crypto: "USDT", network: "TRC20", withdrawAmount: "25556.213265", fee: "1", actualAmount: "25555.213265", address: "T123456789123456789123456789111321", date: "2022/06/01 18:55:55", beginDate: 0, status: "Confirm", comment: "Ok!!" , txid: "32145613113-\(indexName)"))
//                }
//                tableView.reloadData()
//            }
//        }.disposed(by: dpg)
        
        viewModel.rxFetchListSuccess().subscribeSuccess { [self] dto in
            DispatchQueue.main.async { [self] in
                if self.currentPage == 0
                {
                    self.dataArray.removeAll()
                }
                var finishedData = dto.content.filter{($0.state == "APPROVED" || $0.state == "REJECT")}
                var pendingData = dto.content.filter{($0.state != "APPROVED")}
                finishedData = finishedData.sorted(by: { $0.transaction?.createdDateString ?? "" > $1.transaction?.createdDateString ?? "" })
                pendingData = pendingData.sorted(by: { $0.transaction?.createdDateString ?? "" < $1.transaction?.createdDateString ?? "" })
                if showMode == .pending
                {
                    self.dataArray.append(contentsOf: pendingData)
                }else if showMode == .finished
                {
                    self.dataArray.append(contentsOf: finishedData)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                _ = LoadingViewController.dismiss()
                // 停止 refreshControl 動畫
                refresher.endRefreshing()
                tableView.tableFooterView = nil
//                if self.currentPage == 0
//                {
//                    self.dataArray.removeAll()
//                }
//                var finishedData = dto.content.filter{($0.state == "APPROVED" || $0.state == "REJECT")}
//                var pendingData = dto.content.filter{($0.state != "APPROVED")}
//                finishedData = finishedData.sorted(by: { $0.transaction?.createdDateString ?? "" > $1.transaction?.createdDateString ?? "" })
//                pendingData = pendingData.sorted(by: { $0.transaction?.createdDateString ?? "" < $1.transaction?.createdDateString ?? "" })
//                if showMode == .pending
//                {
//                    self.dataArray.append(contentsOf: pendingData)
//                }else if showMode == .finished
//                {
//                    self.dataArray.append(contentsOf: finishedData)
//                }
                // 暫時拿來用
                //                    for indexName in 0...10 {
                //                        dataArray.append(AuditTransactionDto(userid: "00000\(indexName)", crypto: "USDT", network: "TRC20", withdrawAmount: "25556.213265", fee: "1", actualAmount: "25555.213265", address: "T123456789123456789123456789111321", date: "2022/06/01 18:55:55", beginDate: 0, status: "Confirm", comment: "Ok!!" , txid: "32145613113-\(indexName)"))
                //                    }
                //                // 滾動到最下方最新的 Data
                //                self.tableView.scrollToRow(at: [0,0], at: UITableView.ScrollPosition.bottom, animated: true)
                reloadTableView()
            }
     
        }.disposed(by: dpg)
    }
    func reloadTableView()
    {
        tableView.reloadData()
    }
    @objc func loadData(currentPage:Int = 0)
    {
        // 這邊我們用一個延遲讀取的方法，來模擬網路延遲效果（延遲3秒）
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            LoadingViewController.show()
            self.currentPage = currentPage
            self.fetchData(currentPage: currentPage)
        }
    }
    func refreshing(){
        
    }
}
// MARK: -
// MARK: 延伸
extension SubListViewcontroller:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: SubListTableViewCell.self, indexPath: indexPath)
        cell.setData(data: dataArray[indexPath.item] , showMode: showMode)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataArray.count > indexPath.item
        {
            let data = dataArray[indexPath.item]
            let detailVC = AuditDetailViewController.loadNib()
            detailVC.setupDate(cellData: data, showMode: showMode)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refresher.isRefreshing {
            refreshing()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
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
//                currentPage += 1
//                self.loadData(currentPage: currentPage)
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
                let h:CGFloat = size.height
                let reloadDistence = 50.0
                let newH = size.height + CGFloat(reloadDistence) + Views.tabBarHeight
                if y > newH {
                    tableView.tableFooterView = bottomRefrash
                    currentPage += 1
                    self.loadData(currentPage: currentPage)
                }
            }
        }
    }
}
