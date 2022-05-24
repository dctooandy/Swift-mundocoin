//
//  PushNotiViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/11.
//

import Foundation
import RxCocoa
import RxSwift

class PushNotiViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static let share: PushNotiViewController = PushNotiViewController.loadNib()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var tableView: UITableView!
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Push notifications"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        setupUI()
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
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: UserMenuTableViewCell.self)
        tableView.separatorStyle = .none
    }
}
// MARK: -
// MARK: 延伸
extension PushNotiViewController:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueCell(type: UserMenuTableViewCell.self, indexPath: indexPath)
        switch indexPath.row {
        case 0:
            cell.cellData = .systemNotifications
        case 1:
            cell.cellData = .transactionNotifications
        default:
            break
        }
            return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            Log.i("systemNotifications")
        //systemNotifications
        case 1:
            Log.i("transactionNotifications")
        //transactionNotifications
        default:
            break
        }
      
//        guard let presentingVC = presentingViewController else {return}
//        DispatchQueue.main.async {
//            self.dismiss(animated: true) {
//                NewsDetailBottomSheet(newsDto: self.newsDtos[indexPath.row]).start(viewController: presentingVC)
//            }
//        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
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
