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
    var dataArray = [WalletWithdrawDto]()
    var showMode : AuditShowMode = .pending
    fileprivate let viewModel = SubListViewModel()
    let refreshControl = UIRefreshControl()
    // MARK: -
    // MARK:UI 設定    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        refreshControl.attributedTitle = NSAttributedString(string: "Pull To Refresh",
                                                            attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        refreshControl.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        tableView?.addSubview(refreshControl)
    }
    func modeTitle() -> String {
        switch  showMode {
        case .pending: return "Pending".localized
        case .finished: return "Finished".localized
        }
    }
    func fetchData()
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.viewModel.fetch()
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
        
        viewModel.rxFetchListSuccess().subscribeSuccess { dto in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                _ = LoadingViewController.dismiss()
                // 停止 refreshControl 動畫
                refreshControl.endRefreshing()
                dataArray.removeAll()
                var finishedData = dto.content.filter{($0.state == "DONE")}
                var pendingData = dto.content.filter{($0.state != "DONE")}
                finishedData = finishedData.sorted(by: { $0.transaction?.createdDateString ?? "" > $1.transaction?.createdDateString ?? "" })
                pendingData = pendingData.sorted(by: { $0.transaction?.createdDateString ?? "" < $1.transaction?.createdDateString ?? "" })
                if showMode == .pending
                {
                    dataArray = pendingData
                }else if showMode == .finished
                {
                    dataArray = finishedData
                }
                // 暫時拿來用
                //                    for indexName in 0...10 {
                //                        dataArray.append(AuditTransactionDto(userid: "00000\(indexName)", crypto: "USDT", network: "TRC20", withdrawAmount: "25556.213265", fee: "1", actualAmount: "25555.213265", address: "T123456789123456789123456789111321", date: "2022/06/01 18:55:55", beginDate: 0, status: "Confirm", comment: "Ok!!" , txid: "32145613113-\(indexName)"))
                //                    }
                tableView.reloadData()
                //                // 滾動到最下方最新的 Data
                //                self.tableView.scrollToRow(at: [0,0], at: UITableView.ScrollPosition.bottom, animated: true)
            }
     
        }.disposed(by: dpg)
    }
    @objc func loadData()
    {
        // 這邊我們用一個延遲讀取的方法，來模擬網路延遲效果（延遲3秒）
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            LoadingViewController.show()
            self.fetchData()
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
        let data = dataArray[indexPath.item]
//        onCellClick.onNext(data)
        let detailVC = AuditDetailViewController.loadNib()
        detailVC.setupDate(cellData: data, showMode: showMode)
        navigationController?.pushViewController(detailVC, animated: true)
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
        if refreshControl.isRefreshing {
            refreshing()
        }
    }
}
