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
    private let onFetchDataAction = PublishSubject<Int>()
    private let dpg = DisposeBag()
//    var dataArray = [AuditTransactionDto]()
    var dataArray : [WalletWithdrawDto] = []
    var showMode : AuditShowMode = .pending
//    fileprivate let viewModel = SubListViewModel()
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
        view.backgroundColor = Themes.grayF7F8FC
//        bindViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        currentPage = 0
//        dataArray.removeAll()
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
        refresher.rx.controlEvent(.valueChanged).subscribeSuccess { [weak self] (_) in
            self?.startRefresh()
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

    func endFetchData()
    {
        refresher.endRefreshing()
        tableView.tableFooterView = nil
        reloadTableView()
    }
    func reloadTableView()
    {
        tableView.reloadData()
    }
    private func startRefresh() {
        loadData()
    }
    @objc func loadData(currentPage:Int = 0)
    {
        // 這邊我們用一個延遲讀取的方法，來模擬網路延遲效果（延遲3秒）
        LoadingViewController.show()
        self.currentPage = currentPage
        self.fetchData(currentPage: currentPage)
    }
    func fetchData(currentPage:Int)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
//            self.viewModel.fetch(currentPage: currentPage)
            self.onFetchDataAction.onNext(currentPage)
        }
    }

    func rxFetchDataAction() -> Observable<Int>
    {
        return onFetchDataAction.asObserver()
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
        if dataArray.count > 0
        {
            cell.setData(data: dataArray[indexPath.item] , showMode: showMode)            
        }
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
//            refreshing()
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
