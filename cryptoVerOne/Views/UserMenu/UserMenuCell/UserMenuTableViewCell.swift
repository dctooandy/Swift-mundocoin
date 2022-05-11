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
//    case twoFactorAuthentication
//    case emailAuthemtication
//    case changePassword
    
    var cellTitle:String? {
        switch self {
        case .currency:
            return "Currency"
        case .security:
            return "Security"
        case .pushNotifications:
            return "Push notifications"
        case .addressBook:
            return "Address book"
        case .language:
            return "Language"
        case .faceID:
            return "Face ID"
        case .helpSupport:
            return "Help & Support"
        case .termPolicies:
            return "Term & Policies"
        case .about:
            return "About"
        case .logout:
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
            guard let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "version 1.2.3"}
            return "version \(versionString)"
        case .logout:
            return ""
        }
    }
    var arrorColor:UIColor? {
        switch self {
        case .currency,.language,.faceID,.about:
            return UIColor(rgb: 0xe3e3e3)
        case .security,.pushNotifications,.addressBook,.helpSupport,.termPolicies:
            return .black
        case .logout:
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
        case .faceID:
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
    @IBOutlet weak var checkBox: CheckBox!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
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
        }
    }
    func bindUI()
    {
        
    }
}
