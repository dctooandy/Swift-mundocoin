//
//  ApprovalMainViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/9/22.
//


import Foundation
import RxCocoa
import RxSwift

class ApprovalMainViewController: BaseViewController {
    // MARK:業務設定
    private let onCellClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static let share: ApprovalMainViewController = ApprovalMainViewController.loadNib()
    fileprivate let viewModel = ApprovalMainViewModel()
    var dataArray = [AddressBookDto]()
    // MARK: -
    // MARK:UI 設定
   
    @IBOutlet weak var tableView: UITableView!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.naviBackBtn.isHidden = true
        bindViewModel()
        setupUI()
        fetchData()
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
        title = "Approval".localized
        view.backgroundColor = Themes.grayE0E5F2
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: AddressBottomCell.self)
        tableView.separatorStyle = .none
    }
    func fetchData()
    {
        viewModel.fetch()
    }
    func bindViewModel()
    {
        viewModel.rxFetchSuccess().subscribeSuccess { [self] _ in
            // 暫時拿來用
            dataArray = KeychainManager.share.getAddressBookList()
            tableView.reloadData()
        }.disposed(by: dpg)
    }
    func pushToDetailView(data:AddressBookDto)
    {
        let detailVC = ApprovalDetailViewController.loadNib()
        detailVC.configData(data: data)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
// MARK: -
// MARK: 延伸
extension ApprovalMainViewController:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: AddressBottomCell.self, indexPath: indexPath)
        cell.setAccountData(data: dataArray[indexPath.item])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataArray[indexPath.item]
//        onCellClick.onNext(data)
        pushToDetailView(data: data)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
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
    
}
