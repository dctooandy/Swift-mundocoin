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
    @IBOutlet weak var rightArrowImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topButton: UIButton!
    private lazy var backBtn:UIButton = {
        let btn = UIButton(type: .custom)
        let image = UIImage(named:"back")?.reSizeImage(reSize: CGSize(width: Views.backImageHeight(), height: Views.backImageHeight())).withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        btn.setTitle("", for:.normal)
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
        let image = UIImage(named:"back")?.reSizeImage(reSize: CGSize(width: Views.backImageHeight(), height: Views.backImageHeight())).withRenderingMode(.alwaysTemplate)
        rightArrowImage.image = image
        rightArrowImage.tintColor = .black
        rightArrowImage.transform = rightArrowImage.transform.rotated(by: .pi)

        tableView.tableFooterView = nil
        tableView.registerXibCell(type: UserMenuTableViewCell.self)
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
        let popVC =  ConfirmPopupView(title: "Important".localized,
                                      message: "For security purposes, no withdrawals are permitted for 24 hours after modification of security methods.".localized ,
                                      iconMode: .important) { [weak self] isOK in
                                        if isOK {
                                            Log.i("登出")
                                        }else
                                        {
                                            Log.i("不登出")
                                        }
        }
        popVC.start(viewController: self)
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
        return (section == 0 ? 4 : 6)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            case 2:
                cell.cellData = .helpSupport
            case 3:
                cell.cellData = .termPolicies
            case 4:
                cell.cellData = .about
            case 5:
                cell.cellData = .logout
            default:
                break
            }
        default:
            break
        }
            return cell
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
            case 2:
                Log.i("helpSupport")
                //helpSupport
            case 3:
                Log.i("termPolicies")
                //termPolicies
            case 4:
                Log.i("about")
                //about
            case 5:
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
        return 56
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
