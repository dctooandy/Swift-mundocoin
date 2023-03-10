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
    var historyType:TransactionShowMode = .all
    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var balanceFlagLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cellBackView: UIView!
    @IBOutlet weak var inOutImageView: UIImageView!
    @IBOutlet weak var inOutLabel: UILabel!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupUI()
        // 暫時拿掉頁面監聽Socket事件
//        bindUI()
    }
    // MARK: -
    // MARK:業務方法
    func setData(data:ContentDto , type:TransactionShowMode)
    {
        self.cellData = data
        currencyLabel.text = data.currency
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd,yyyy HH:mm:ss"
        // 將時間戳轉換成 TimeInterval
        let timeInterval = TimeInterval(data.createdDateTimeInterval)
        // 初始化一個 Date
        let date = Date(timeIntervalSince1970: timeInterval)
        let currentTimeString = dateFormatter.string(from: date)
        timeLabel.text = currentTimeString
//        self.historyType = type        
//        if data.type == "DEPOSIT"
//        {
//            statusLabel.isHidden = true
//        }else
//        {
//            statusLabel.isHidden = data.stateValue == "COMPLETE" ? true : false
//            statusLabel.text = data.stateValue.capitalizingFirstLetter()
//            labelWidthConstraint.constant = data.stateValue.customWidth(textSize: 11, spaceWidth: 10)
//            if data.stateValue == "FAILED"
//            {
//                statusLabel.textColor = Themes.grayA3AED0
//                statusLabel.backgroundColor = Themes.grayA3AED020
//            }else
//            {
//                statusLabel.textColor = Themes.blue0587FF
//                statusLabel.backgroundColor = Themes.blue0587FF10
//            }
//        }
//        if historyType == .withdrawals || historyType == .all
//        {
//            if let amountValue = data.walletAmountIntWithDecimal
//            {
//                amountLabel.text = amountValue.stringValue?.numberFormatter(.decimal, 8)
//            }
//        }else
//        {
//            if let amountValue = data.walletDepositAmountIntWithDecimal
//            {
//                amountLabel.text = amountValue.stringValue?.numberFormatter(.decimal, 8)
//            }
//        }
        if data.type == "DEPOSIT"
        {
            statusLabel.isHidden = true
            if let amountValue = data.walletDepositAmountIntWithDecimal
            {
                amountLabel.text = amountValue.stringValue?.numberFormatter(.decimal, 8)
            }
            amountLabel.textColor = UIColor(rgb: 0x0DC897)
            balanceFlagLabel.textColor = UIColor(rgb: 0x0DC897)
            balanceFlagLabel.text = "+"
            inOutImageView.image = UIImage(named: "icon-transfer-in")
            inOutLabel.text = "Deposit"
            if data.fromAddress.isEmpty
            {
                addressLabel.text = "--"
            }else
            {
                addressLabel.text = data.fromAddress
            }
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
            if let amountValue = data.walletAmountIntWithDecimal
            {
                amountLabel.text = amountValue.stringValue?.numberFormatter(.decimal, 8)
            }
            amountLabel.textColor = UIColor(rgb: 0xF33828)
            balanceFlagLabel.textColor = UIColor(rgb: 0xF33828)
            balanceFlagLabel.text = "-"
            inOutImageView.image = UIImage(named: "icon-transfer-out")
            inOutLabel.text = "Withdraw"
            if data.toAddress.isEmpty
            {
                addressLabel.text = "--"
            }else
            {
                addressLabel.text = data.toAddress
            }
        }
//        if let txidString = data.txId
//        {
//            txidLabel.text = txidString
//        }else
//        {
//            txidLabel.text = "-"
//        }
    }
    func setupUI()
    {
        cellBackView.applyCornerAndShadow(radius: 16)
    }
    func bindUI()
    {
        TXPayloadDto.rxShare.subscribeSuccess { [self] dto in
            if let statsValue = dto?.stateValue,
//               let amountValue = dto?.amountIntWithDecimal?.stringValue,
               let socketID = dto?.id
            {
                if cellData.id == socketID
//                    ,cellData.amountIntWithDecimal?.stringValue == amountValue
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

