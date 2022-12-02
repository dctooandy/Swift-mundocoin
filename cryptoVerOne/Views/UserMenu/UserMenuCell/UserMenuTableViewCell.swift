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

enum UserMenuCellData {
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
    case email
    case mobile
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
            return "Face ID/Biometric".localized
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
            return "E-Mail Authentication".localized
        case .changePassword:
            return "Change Password".localized
        case .systemNotifications:
            return "System Notifications".localized
        case .transactionNotifications:
            return "Transaction Notifications".localized
        case .registrationInfo:
            return "Registration info".localized
        case .email:
            return "Email".localized
        case .mobile:
            return "Mobile".localized
        case .memberSince:
            return "Member since".localized
        }
    }
    var subTitleLabel:String? {
        switch self {
        case .registrationInfo:
            var infoString = ""
            if let mode = KeychainManager.share.getLastAccount()?.loginMode
            {
                infoString = (mode == .emailPage ? "E-mail":"Mobile")
            }
            return infoString
        case .currency:
            return "USD"
        case .security:
            return ""
        case .pushNotifications:
            return ""
        case .addressBook:
            return ""
        case .language:
            return "English"
        case .faceID:
            return ""
        case .helpSupport:
            return ""
        case .termPolicies:
            return ""
        case .about:
            guard let versionString = Bundle.main.releaseVersionNumber else { return "M 1.2.3"}
            guard let buildString = Bundle.main.buildVersionNumber else { return "1"}
#if Mundo_PRO
            return "M \(versionString).\(buildString)"
#else
            return "M \(versionString).\(buildString)"
//            return "\(KeychainManager.share.getDomainMode().rawValue) M \(versionString)"
#endif
        case .logout:
            return ""
        case .twoFactorAuthentication,
             .emailAuthemtication,
             .changePassword,
             .systemNotifications,
             .transactionNotifications:
            return ""
        case .email:
            var emailString = ""
            if let account = KeychainManager.share.getLastAccount()?.account , !account.isEmpty
            {
                emailString = account
            }
            return emailString
        case .mobile:
            var mobileString = ""
            if let mobile = KeychainManager.share.getLastAccount()?.phone
            {
                mobileString = mobile
            }
            return mobileString
        case .memberSince:
            if let time = MemberAccountDto.share?.memberSinceDate()
            {
                return time
            }
            return "111"
        }
    }
    var arrowAlpha:CGFloat {
        switch self {
        case .currency,.language,.faceID,.about,.logout,.systemNotifications,.transactionNotifications,.registrationInfo,.memberSince:
            return 0.0
        case .emailAuthemtication:
            return 0.3
        case .email:
            if self.subTitleLabel != ""
            {
                return 0.0
            }else
            {
                return 1.0
            }
        case .mobile:
            if self.subTitleLabel != ""
            {
                return 0.0
            }else
            {
                return 1.0
            }
        default :
            return 1.0
        }
    }
    var arrowHidden:Bool {
        switch self {
        case .currency,.language,.faceID,.about,.systemNotifications,.transactionNotifications,.registrationInfo,.memberSince:
            return true
        case .email:
            if self.subTitleLabel != ""
            {
                return true
            }else
            {
                return false
            }
        case .mobile:
            if self.subTitleLabel != ""
            {
                return true
            }else
            {
                return false
            }
        default :
            return false
        }
    }

    var switchHidden:Bool {
        switch self {
        case .faceID,
                .systemNotifications,
                .transactionNotifications:
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
             .memberSince,
             .email,
             .mobile:
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
    var cellData: UserMenuCellData = .currency{
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
        logoutLabel.layer.cornerRadius = height(37.0/812.0/2.0)
        logoutLabel.layer.masksToBounds = true
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
            cellImageView.isHidden = cellData.imageHidden
            checkBoxImageView.isHidden = cellData.checkBoxHidden
            cellImageView.image = UIImage(named: cellData.cellIconImageName)
            arrowImageView.alpha = cellData.arrowAlpha
            arrowImageView.isHidden = cellData.arrowHidden
            
            if BioVerifyManager.share.bioLoginSwitchState() == true
            {
                switchButton.isOn = true
            }else
            {
                switchButton.isOn = false
            }
            switchButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.75)
            switchButton.isHidden = cellData.switchHidden
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
