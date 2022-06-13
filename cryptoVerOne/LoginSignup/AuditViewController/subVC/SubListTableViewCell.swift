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
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var finishedIcon: UIImageView!
    
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
    func setData(data : AuditTransactionDto ,showMode:AuditShowMode)
    {
        topTitleLabel.text = "Withdraw Request \(data.userid)"
        timeLabel.text = data.date
        self.showMode = showMode
        finishedIcon.isHidden = (showMode == .pending ? true : false)
    }
}
// MARK: -
// MARK: 延伸
