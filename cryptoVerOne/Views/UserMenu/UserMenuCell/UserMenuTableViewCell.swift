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
            guard let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "version 1.2.3"}
            return "version \(versionString)"
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
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupUI()
        bindUI()
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        let image = UIImage(named:"back")?.reSizeImage(reSize: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
        arrowImageView.image = image
        arrowImageView.transform = arrowImageView.transform.rotated(by: .pi)
   
    }
    func setupByData()
    {
        if cellData == .logout
        {
            logoutLabel.isHidden = false
        }else
        {
            logoutLabel.isHidden = true
            cellTitleLabel.text = cellData.cellTitle
            subTitleLabel.text = cellData.subTitleLabel
            arrowImageView.tintColor = cellData.arrorColor
            switchButton.isHidden = cellData.switchHidden
            arrowImageView.isHidden = !cellData.switchHidden
            cellImageView.isHidden = cellData.imageHidden
            checkBoxImageView.isHidden = cellData.checkBoxHidden
        }
    }
    func bindUI()
    {
        
    }
}
