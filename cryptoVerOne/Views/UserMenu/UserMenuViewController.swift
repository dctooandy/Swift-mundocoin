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
    private let viewModel = UserMenuViewModel()
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var userAccountLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
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
//        title = "User Menu"
        setupUI()
        fetchData()
        bindViewModel()
        bind()
//        self.transitioningDelegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        LoadingViewController.show()
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            _ = LoadingViewController.dismiss()
        }
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
        // MC524 暫時隱藏
        rightArrowImage.isHidden = true
//        let image = UIImage(named:"back")?.reSizeImage(reSize: CGSize(width: Views.backImageHeight(), height: Views.backImageHeight())).withRenderingMode(.alwaysTemplate)
//        rightArrowImage.image = image
//        rightArrowImage.tintColor = .black
//        rightArrowImage.transform = rightArrowImage.transform.rotated(by: .pi)

        tableView.tableFooterView = nil
        tableView.registerXibCell(type: UserMenuTableViewCell.self)
        tableView.registerXibCell(type: UserMenuGrayLineCell.self)
        tableView.registerXibCell(type: UserMenuWhiteLineCell.self)
        tableView.separatorStyle = .none
        
        let loginDto = KeychainManager.share.getLastAccount()
        if let userEmail = loginDto?.account , UserStatus.share.isLogin
        {
            userAccountLabel.text = userEmail
        }
    }
    func fetchData()
    {
//        viewModel.fetch()
    }
    func bind()
    {
//        currencyLabel.rx.click.subscribeSuccess { (_) in
//            if let url = URL(string: "itms-apps://apple.com/app/id388497605") {
//                UIApplication.shared.open(url)
//            }
//        }.disposed(by: dpg)
        // MC524 暫時隱藏
        // 人物訊息
//        topButton.rx.tap.subscribeSuccess { [self](_) in
//            let personalVC = PersonalInfoViewController.loadNib()
//            self.navigationController?.pushViewController(personalVC, animated: true)
//        }.disposed(by: dpg)
    }
    func bindViewModel()
    {
        
    }
    func showLogotConfirmAlert()
    {
//        let popVC = ConfirmPopupView(iconMode: .showIcon("Close"), title: "Warning", message: "The verification code is incorrect or has expired, you could try 5 more times a day.") { [self](_) in
//
//        }
        let popVC = ConfirmPopupView(viewHeight:170.0 ,iconMode: .nonIcon(["Cancel".localized,"Logout".localized]),
                                      title: "",
                                      message: "Are you sure you want \nto logout?") { [self] isOK in

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
    
    func socketEmit()
    {
#if Mundo_PRO || Mundo_STAGE || Approval_PRO || Approval_STAGE
                
#else  
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(WalletWithdrawDto())
        let json = String(data: jsonData ?? Data(), encoding: String.Encoding.utf8)
        SocketIOManager.sharedInstance.sendEchoEvent(event: "message", para: json!)
#endif
    }
    func directToViewController() {
        DeepLinkManager.share.handleDeeplink(navigation: .login)
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
        // MC524 打開白名單
//        return (section == 0 ? 4 : 6)
        return (section == 0 ? 3 : 6)// 打開白名單
//        return (section == 0 ? 2 : 6)// 隱藏地址簿
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // MC524 暫時隱藏
//        if indexPath.section == 1 && (indexPath.item == 2 || indexPath.item == 4)
        if indexPath.section == 1 && (indexPath.item == 2 || indexPath.item == 4)// 隱藏地址簿
        {// 線條View
            let lineCell = tableView.dequeueCell(type: UserMenuGrayLineCell.self, indexPath: indexPath)
            return lineCell
        }else if indexPath.section == 1 && indexPath.item == 1
        {// 白底View
            let lineCell = tableView.dequeueCell(type: UserMenuWhiteLineCell.self, indexPath: indexPath)
            return lineCell
        }
        else
        {
            let cell = tableView.dequeueCell(type: UserMenuTableViewCell.self, indexPath: indexPath)
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    cell.cellData = .currency
                case 1:
                    cell.cellData = .security
                // MC524 打開白名單
//                case 2:
//                    cell.cellData = .pushNotifications
                case 2:
                    cell.cellData = .addressBook
                default:
                    break
                }
            case 1:
                switch indexPath.row {
                case 0:
                    cell.cellData = .language
                // MC524 暫時隱藏
//                case 1:
//                    cell.cellData = .faceID
//                case 3:
//                    cell.cellData = .helpSupport
//                case 4:
//                    cell.cellData = .termPolicies
//                case 5:
//                    cell.cellData = .about
//                case 7:
//                    cell.cellData = .logout
                case 3:// MC524 暫時隱藏 原本3
                    cell.cellData = .about
                case 5:// MC524 暫時隱藏 原本5
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
//            case 2:
//                Log.i("pushNotifications")
//                let pushVC = PushNotiViewController.loadNib()
//                self.navigationController?.pushViewController(pushVC, animated: true)
                //pushNotifications
                // MC524 打開白名單
            case 2:
                Log.i("addressBook")
                let addressBookVC = AddressBookViewController.loadNib()
                self.navigationController?.pushViewController(addressBookVC, animated: true)
                //addressBook
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                Log.i("language")
                //language
            // MC524 暫時隱藏
//            case 1:
//                Log.i("faceID")
            
                //faceID
//            case 3:
//                Log.i("helpSupport")
//                //helpSupport
//            case 4:
//                Log.i("termPolicies")
//                //termPolicies
//            case 5:
//                Log.i("about")
//                socketEmit()
//                //about
//            case 7:
//                Log.i("logout")
//                showLogotConfirmAlert()
//                //logout
            case 3:// MC524 暫時隱藏 原本3
                Log.i("about")
                socketEmit()
                //about
            case 5:// MC524 暫時隱藏 原本5
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
// MC524 暫時隱藏
//        if indexPath.section == 1 && indexPath.row == 5
        if indexPath.section == 1 && indexPath.row == 5
        {
            return 80
// MC524 暫時隱藏
//        }else if indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 4)
        }else if indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 4)
        {
            return 1
        }else if indexPath.section == 1 && indexPath.row == 1
        {
            return 20
        }else if indexPath.section == 1 && indexPath.row == 3
        {
            return 92
        }else
        {
            return 52
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        let titleLable = UILabel(frame: CGRect(x: 25, y: 20, width: 300, height: 23))
        titleLable.text = section == 0 ?  "Account" : "App Settings"
        titleLable.font = Fonts.PlusJakartaSansBold(18)
        titleLable.textColor = Themes.gray1B2559
        header.addSubview(titleLable)
        header.backgroundColor = .clear
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}
