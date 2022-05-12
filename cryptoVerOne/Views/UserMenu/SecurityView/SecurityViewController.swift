//
//  SecurityViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/11.
//

import Foundation
import RxCocoa
import RxSwift

class SecurityViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static let share: SecurityViewController = SecurityViewController.loadNib()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Security"
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
extension SecurityViewController:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueCell(type: UserMenuTableViewCell.self, indexPath: indexPath)
        switch indexPath.row {
        case 0:
            cell.cellData = .twoFactorAuthentication
        case 1:
            cell.cellData = .emailAuthemtication
        case 2:
            cell.cellData = .changePassword
        default:
            break
        }
            return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            Log.i("twoFactorAuthentication")
            let twoFactorVC = TFBeginViewController.share
            self.navigationController?.pushViewController(twoFactorVC, animated: true )
        //twoFactorAuthentication
        case 1:
            Log.i("emailAuthemtication")
        //emailAuthemtication
        case 2:
            Log.i("changePassword")
        //changePassword
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
