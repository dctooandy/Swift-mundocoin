//
//  TransHistoryCell.swift
//  cryptoVerOne
//
//  Created by BBk on 6/15/22.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class TransHistoryCell: UITableViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var cellData:ContentDto!
    var historyType:TransactionShowMode = .deposits
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
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
    func setData(data:ContentDto , type:TransactionShowMode)
    {
        self.cellData = data
        currencyLabel.text = data.currency
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        // 將時間戳轉換成 TimeInterval
        let timeInterval = TimeInterval(data.date)
        // 初始化一個 Date
        let date = Date(timeIntervalSince1970: timeInterval)

//        let startDate = dateFormatter.date(from: data.date)
        let currentTimeString = dateFormatter.string(from: date)
        timeLabel.text = currentTimeString
        amountLabel.text = data.amount
        self.historyType = type
        if historyType == .deposits
        {
            statusLabel.isHidden = true
        }else
        {
            statusLabel.isHidden = false
            statusLabel.text = data.status
        }
    }
    func setupUI()
    {
        
    }
    func bindUI()
    {
        
    }
}
// MARK: -
// MARK: 延伸

