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
    var authVC : AuthenticationViewController!
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        title = "Security"
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        // MC524 暫時隱藏
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueCell(type: UserMenuTableViewCell.self, indexPath: indexPath)
        switch indexPath.row {
        // MC524 暫時隱藏
//        case 0:
//            cell.cellData = .twoFactorAuthentication
//        case 1:
//            cell.cellData = .emailAuthenVerity
//        case 2:
//            cell.cellData = .changePassword
        case 0:
            cell.cellData = .smsAuthentication
        case 1:
            cell.cellData = .emailAuthentication
        case 2:
            cell.cellData = .changePassword
        default:
            break
        }
            return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        // MC524 暫時隱藏
//        case 0:
//            Log.i("twoFactorAuthentication")
//            // 初次使用未綁定
//            let twoFactorVC = TFBeginViewController.loadNib()
//            self.navigationController?.pushViewController(twoFactorVC, animated: true )
//            // 已綁定 要重綁
////            let twoFactorVC = TFFinishReViewController.loadNib()
////            twoFactorVC.viewMode = .reverify
////            self.navigationController?.pushViewController(twoFactorVC, animated: true )
//        case 1:
//            Log.i("emailAuthentication")
//        case 2:
//            Log.i("changePassword")
//            let ucPasswordVC = UCPasswordViewController()
//            self.navigationController?.pushViewController(ucPasswordVC, animated: true )

        case 0:
            Log.i("smsAuthentication")
            if let mobile = MemberAccountDto.share?.phone , mobile.isEmpty
            {
                authVC = AuthenticationViewController.loadNib()
                authVC.authenInputViewMode = .phone(withStar: false)
                self.navigationController?.pushViewController(authVC, animated: true)
            }
        case 1:
            Log.i("emailAuthentication")
            if let email = MemberAccountDto.share?.email , email.isEmpty
            {
                authVC = AuthenticationViewController.loadNib()
                authVC.authenInputViewMode = .email(withStar: false)
                self.navigationController?.pushViewController(authVC, animated: true)                
            }
        case 2:
            Log.i("changePassword")
            let ucPasswordVC = UCPasswordViewController()
            self.navigationController?.pushViewController(ucPasswordVC, animated: true )
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
