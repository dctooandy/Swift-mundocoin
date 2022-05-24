//
//  UserMenuViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import RxCocoa
import RxSwift

class UserMenuViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var rightArrowImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topButton: UIButton!
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton()
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "User Menu"
        setupUI()
        bind()
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
        titleView.layer.cornerRadius = 20
        if #available(iOS 11.0, *) {
            titleView.layer.maskedCorners = [.layerMinXMinYCorner , .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        let image = UIImage(named:"back")?.reSizeImage(reSize: CGSize(width: Views.backImageHeight(), height: Views.backImageHeight())).withRenderingMode(.alwaysTemplate)
        rightArrowImage.image = image
        rightArrowImage.tintColor = .black
        rightArrowImage.transform = rightArrowImage.transform.rotated(by: .pi)

        tableView.tableFooterView = nil
        tableView.registerXibCell(type: UserMenuTableViewCell.self)
        tableView.registerXibCell(type: UserMenuGrayLineCell.self)
        tableView.separatorStyle = .none
        
    }
    func bind()
    {
//        currencyLabel.rx.click.subscribeSuccess { (_) in
//            if let url = URL(string: "itms-apps://apple.com/app/id388497605") {
//                UIApplication.shared.open(url)
//            }
//        }.disposed(by: dpg)
        topButton.rx.tap.subscribeSuccess { [self](_) in
            let personalVC = PersonalInfoViewController.loadNib()
            self.navigationController?.pushViewController(personalVC, animated: true)
        }.disposed(by: dpg)
    }
    func showLogotConfirmAlert()
    {
//        let popVC = ConfirmPopupView(iconMode: .showIcon("Close"), title: "Warning", message: "The verification code is incorrect or has expired, you could try 5 more times a day.") { [self](_) in
//
//        }
        let popVC =  ConfirmPopupView(iconMode: .nonIcon(["Cancel".localized,"Logout".localized]), title: "", message: "Are you sure you want to logout?") { [self] isOK in

            if isOK {
                Log.i("登出")
                directToViewController()
            }else
            {
                Log.i("不登出")
            }
        }
        popVC.start(viewController: self)
    }
}
func directToViewController() {
    if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {

        let loginNavVC = MuLoginNavigationController(rootViewController: LoginSignupViewController.share)
        mainWindow.rootViewController = loginNavVC
        mainWindow.makeKeyAndVisible()
    }
}
// MARK: -
// MARK: 延伸
extension UserMenuViewController:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0 ? 4 : 8)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && (indexPath.item == 2 || indexPath.item == 6)
        {
            let lineCell = tableView.dequeueCell(type: UserMenuGrayLineCell.self, indexPath: indexPath)
            return lineCell
        }else
        {
            let cell = tableView.dequeueCell(type: UserMenuTableViewCell.self, indexPath: indexPath)
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    cell.cellData = .currency
                case 1:
                    cell.cellData = .security
                case 2:
                    cell.cellData = .pushNotifications
                case 3:
                    cell.cellData = .addressBook
                default:
                    break
                }
            case 1:
                switch indexPath.row {
                case 0:
                    cell.cellData = .language
                case 1:
                    cell.cellData = .faceID
                case 3:
                    cell.cellData = .helpSupport
                case 4:
                    cell.cellData = .termPolicies
                case 5:
                    cell.cellData = .about
                case 7:
                    cell.cellData = .logout
                default:
                    break
                }
            default:
                break
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                Log.i("currency")
                //currency
            case 1:
                Log.i("security")
                let securityVC = SecurityViewController.share
                self.navigationController?.pushViewController(securityVC, animated: true)
                //security
            case 2:
                Log.i("pushNotifications")
                let pushVC = PushNotiViewController.loadNib()
                self.navigationController?.pushViewController(pushVC, animated: true)
                //pushNotifications
            case 3:
                Log.i("addressBook")
                //addressBook
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                Log.i("language")
                //language
            case 1:
                Log.i("faceID")
                //faceID
            case 3:
                Log.i("helpSupport")
                //helpSupport
            case 4:
                Log.i("termPolicies")
                //termPolicies
            case 5:
                Log.i("about")
                //about
            case 7:
                Log.i("logout")
                showLogotConfirmAlert()
                //logout
            default:
                break
            }
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
        if indexPath.section == 1 && indexPath.row == 7
        {
            return 80
        }else if indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 6)
        {
            return 1
        }else
        {
            return 56            
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        let titleLable = UILabel(frame: CGRect(x: 32, y: 20, width: 300, height: 24))
        titleLable.text = section == 0 ?  "Account" : "App Settings"
        titleLable.font = Fonts.pingFangTCRegular(18)
        header.addSubview(titleLable)
        header.backgroundColor = .clear
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}
