//
//  SubListTableViewCell.swift
//  cryptoVerOne
//
//  Created by BBk on 6/13/22.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class SubListTableViewCell: UITableViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var showMode:AuditShowMode!
    
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var finishedIcon: UIImageView!
    
    @IBOutlet weak var rightArrowImageView: UIImageView!
    @IBOutlet weak var underLineView: UIView!
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
        
    }
    func bindUI()
    {
        
    }
    func setData(data : WalletWithdrawDto ,showMode:AuditShowMode)
    {
        self.showMode = showMode
        if let transDto = data.transaction , let userDto = data.issuer ,let _ = data.chain?.first
        {
#if Mundo_PRO || Mundo_STAGE || Approval_PRO || Approval_STAGE
            topTitleLabel.text = "Withdraw Request"
#else
            topTitleLabel.text = "Withdraw Request \(userDto.email)"
#endif
            timeLabel.text = self.showMode == .pending ? transDto.createdDateString : transDto.updatedDateString
            let iconImage = UIImage(named: data.detailType == .failed ? "icon-red-close-round-fill":"icon-check-round-fill")
            finishedIcon.image = iconImage
        }
        finishedIcon.isHidden = (showMode == .pending ? true : false)
        
        iconWidth.constant = (showMode == .pending ? 0 : 40)
    }
}
// MARK: -
// MARK: 延伸
