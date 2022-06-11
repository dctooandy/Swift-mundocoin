//
//  UserMenuTableViewCell.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/10.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

enum cellData {
    // UserMenu
    case currency
    case security
    case pushNotifications
    case addressBook
    case language
    case faceID
    case helpSupport
    case termPolicies
    case about
    case logout
    
    // Security
    case twoFactorAuthentication
    case emailAuthemtication
    case changePassword
    
    // Push notifications
    case systemNotifications
    case transactionNotifications
    
    // Personal info
    case registrationInfo
    case memberSince
    
    var cellTitle:String? {
        switch self {
        case .currency:
            return "Currency".localized
        case .security:
            return "Security".localized
        case .pushNotifications:
            return "Push notifications".localized
        case .addressBook:
            return "Address book".localized
        case .language:
            return "Language".localized
        case .faceID:
            return "Face ID".localized
        case .helpSupport:
            return "Help & Support".localized
        case .termPolicies:
            return "Term & Policies".localized
        case .about:
            return "About".localized
        case .logout:
            return ""
        case .twoFactorAuthentication:
            return "Two-Factor Authentication".localized
        case .emailAuthemtication:
            return "E-Mail Authemtication".localized
        case .changePassword:
            return "Change Password".localized
        case .systemNotifications:
            return "System Notifications".localized
        case .transactionNotifications:
            return "Transaction Notifications".localized
        case .registrationInfo:
            return "Registration info".localized
        case .memberSince:
            return "Member since".localized
        default :
            return ""
        }
    }
    var subTitleLabel:String? {
        switch self {
        case .currency:
            return "USDT"
        case .security:
            return ""
        case .pushNotifications:
            return ""
        case .addressBook:
            return ""
        case .language:
            return "English"
        case .faceID:
            return "Unlock the app"
        case .helpSupport:
            return ""
        case .termPolicies:
            return ""
        case .about:
            guard let versionString = Bundle.main.releaseVersionNumber else { return "version 1.2.3"}
            guard let buildString = Bundle.main.buildVersionNumber else { return "1"}
#if Mundo_PRO
            return "version \(versionString)"
#else
            return "\(KeychainManager.share.getDomainMode().rawValue) version \(versionString) b-\(buildString)"
#endif
        case .logout:
            return ""
        case .twoFactorAuthentication,
             .emailAuthemtication,
             .changePassword,
             .systemNotifications,
             .transactionNotifications,
             .registrationInfo,
             .memberSince:
            return ""
        default :
            return ""
        }
    }
    var arrorColor:UIColor? {
        switch self {
        case .currency,.language,.faceID,.about,.emailAuthemtication:
            return UIColor(rgb: 0xe3e3e3)
        case .security,.pushNotifications,.addressBook,.helpSupport,.termPolicies,.twoFactorAuthentication,.changePassword:
            return .black
        case .logout,.systemNotifications,.transactionNotifications,.registrationInfo,.memberSince:
            return .clear
        default :
            return .clear
        }
    }
//    var subTitleHidden:Bool {
//        switch self {
//        case .currency,.language,.faceID,.about:
//            return false
//        case .security,.pushNotifications,.addressBook,.helpSupport,.termPolicies:
//            return true
//        case .logout:
//            return false
//        }
//    }
    var switchHidden:Bool {
        switch self {
        case .faceID,.systemNotifications,.transactionNotifications:
            return false
        default :
            return true
        }
    }
    var imageHidden:Bool {
        switch self {
        case .twoFactorAuthentication,
             .emailAuthemtication,
             .changePassword,
             .systemNotifications,
             .transactionNotifications,
             .registrationInfo,
             .memberSince:
            return true
        default :
            return false
        }
    }
    var checkBoxHidden:Bool {
        switch self {
        case .twoFactorAuthentication,
             .emailAuthemtication:
            return false
        default :
            return true
        }
    }
    var cellIconImageName:String
    {
        switch self {
        case .currency:
            return "icon-swap".localized
        case .security:
            return "icon-security".localized
        case .pushNotifications:
            return "icon-bell-usermenu".localized
        case .addressBook:
            return "icon-addressbook-line".localized
        case .language:
            return "icon-globe".localized
        case .faceID:
            return "icon-Faceid".localized
        case .helpSupport:
            return "icon-Info".localized
        case .termPolicies:
            return "icon-privacy".localized
        case .about:
            return "icon-logo".localized
        case .logout:
            return ""
        default :
            return ""
        }
    }
}
class UserMenuTableViewCell: UITableViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var cellData: cellData = .currency{
        didSet {
            setupByData()
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    
    @IBOutlet weak var logoutView: UIView!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupUI()
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        let image = UIImage(named:"back")?.reSizeImage(reSize: CGSize(width: Views.backImageHeight(), height: Views.backImageHeight())).withRenderingMode(.alwaysTemplate)
        arrowImageView.image = image
        arrowImageView.transform = arrowImageView.transform.rotated(by: .pi)
   
    }
    func setupByData()
    {
        if cellData == .logout
        {
            logoutView.isHidden = false
        }else
        {
            logoutView.isHidden = true
            cellTitleLabel.text = cellData.cellTitle
            subTitleLabel.text = cellData.subTitleLabel
            arrowImageView.tintColor = cellData.arrorColor
            switchButton.isHidden = cellData.switchHidden
            arrowImageView.isHidden = !cellData.switchHidden
            cellImageView.isHidden = cellData.imageHidden
            checkBoxImageView.isHidden = cellData.checkBoxHidden
            cellImageView.image = UIImage(named: cellData.cellIconImageName)
        }
        bindUI()
    }
    func managerBioList(isOn: Bool, acc: String) {
        BioVerifyManager.share.setBioLoginSwitch(to: isOn)
        if !BioVerifyManager.share.didAskBioLogin() {
            BioVerifyManager.share.setBioLoginAskStateToTrue()
        }
        if isOn {
            BioVerifyManager.share.applyMemberInBIOList(acc)
            KeychainManager.share.setLastAccount(acc)
            return
        }
        BioVerifyManager.share.removeMemberFromBIOList(acc)
        //KeychainManager.share.deleteValue(at: .account)
        
    }

    func bindUI()
    {
        switch cellData {
        case .faceID:
            switchButton.rx.isOn.subscribeSuccess { [self] switchFlag in
                if let account = KeychainManager.share.getLastAccount()?.account
                {
                    managerBioList(isOn: switchFlag, acc: account)                    
                }
            }.disposed(by: dpg)
        default:
            break
        }
    }
}
