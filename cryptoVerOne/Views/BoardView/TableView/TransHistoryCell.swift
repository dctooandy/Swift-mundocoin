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
    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
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
        let timeInterval = TimeInterval(data.createdDateTimeInterval)
        // 初始化一個 Date
        let date = Date(timeIntervalSince1970: timeInterval)
        let currentTimeString = dateFormatter.string(from: date)
        timeLabel.text = currentTimeString
        if let amountValue = data.amountIntWithDecimal {
            amountLabel.text = amountValue.stringValue?.numberFormatter(.decimal, 8)
        }
        self.historyType = type
        if historyType == .deposits
        {
            statusLabel.isHidden = true
        }else
        {
            statusLabel.isHidden = data.stateValue == "COMPLETE" ? true : false
            statusLabel.text = data.stateValue.capitalizingFirstLetter()
            labelWidthConstraint.constant = data.stateValue.customWidth(textSize: 11, spaceWidth: 10)
            if data.stateValue == "FAILED"
            {
                statusLabel.textColor = Themes.grayA3AED0
                statusLabel.backgroundColor = Themes.grayA3AED020
            }else
            {
                statusLabel.textColor = Themes.blue0587FF
                statusLabel.backgroundColor = Themes.blue0587FF10
            }
        }
    }
    func setupUI()
    {
        
    }
    func bindUI()
    {
        TXPayloadDto.rxShare.subscribeSuccess { [self] dto in
            if let statsValue = dto?.stateValue,
               let amountValue = dto?.amountIntWithDecimal?.stringValue,
               let socketID = dto?.id
            {
                if cellData.amountIntWithDecimal?.stringValue == amountValue,
                   cellData.id == socketID
                {
                    if statsValue == "COMPLETE"
                    {
                        statusLabel.isHidden = true
                    }
                    statusLabel.text = statsValue.capitalizingFirstLetter()
                    labelWidthConstraint.constant = statsValue.customWidth(textSize: 11, spaceWidth: 10)
                    if statsValue == "FAILED"
                    {
                        statusLabel.textColor = Themes.grayA3AED0
                        statusLabel.backgroundColor = Themes.grayA3AED020
                    }else
                    {
                        statusLabel.textColor = Themes.blue0587FF
                        statusLabel.backgroundColor = Themes.blue0587FF10
                    }
                }
            }
        }.disposed(by: dpg)
    }
}
// MARK: -
// MARK: 延伸

