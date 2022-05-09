//
//  MemberViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import UIKit
import UPCarouselFlowLayout
import SnapKit
import RxCocoa
import RxSwift
import UserNotifications
import SafariServices
import SDWebImage
class MemberViewController: BaseViewController {
    @IBOutlet weak var greetingLabelTopConstraint:NSLayoutConstraint!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var greetingLabel:UILabel!
    @IBOutlet weak var greetingSeciondLabel:UILabel!
    @IBOutlet weak var avator:UIImageView!
    @IBOutlet weak var securityProgressView:UIProgressView!
    @IBOutlet weak var messageBtn:BadgeBtn!
    @IBOutlet weak var securityLabel:UILabel!
    @IBOutlet weak var mailIcon:StatusImageView!
    @IBOutlet weak var phoneIcon:StatusImageView!
    @IBOutlet weak var lockIcon:StatusImageView!
    @IBOutlet weak var creditCardIcon:StatusImageView!
    private lazy var StatusImageViews = [mailIcon,phoneIcon,lockIcon,creditCardIcon]
    
    
    @IBOutlet weak var missionLabel:UILabel!
    @IBOutlet weak var missionBtn:UIButton!
    @IBOutlet weak var missionIcon:UIImageView!
    @IBOutlet weak var missionBgView:UIView!
    
    @IBOutlet weak var moneyStackView: UIStackView!
    @IBOutlet weak var moneyUpperBgView:UIView!
    @IBOutlet weak var moneyLowerBgView:UIView!
    @IBOutlet weak var amountMoneyLabel:UILabel!
    @IBOutlet weak var expandView:UIView!
    @IBOutlet weak var expandTitleLabel:UILabel!
    @IBOutlet weak var expandIcon:UIImageView!
    @IBOutlet weak var centerWallet:UILabel!
    @IBOutlet weak var gameWallet:UILabel!
    @IBOutlet weak var retrieveMoneyBtn:UIButton!
    @IBOutlet weak var infoIcon:UIImageView!
    
    @IBOutlet weak var bottomActionBgView:UIView!
    @IBOutlet weak var moneyRecordBtn:UIButton!
    @IBOutlet weak var personalInfoBtn:UIButton!
    @IBOutlet weak var promoteBtn:UIButton!
    @IBOutlet weak var securityBtn:UIButton!
    @IBOutlet weak var betRecordBtn:UIButton!
    @IBOutlet weak var versionInfoBtn:UIButton!
    @IBOutlet weak var gameWalletBtn: UIButton!
    private var isBind = false
    // MARK: - life cycle
    init() {
        super.init()
     
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setDefault() {
        isBind = false
    }
}
