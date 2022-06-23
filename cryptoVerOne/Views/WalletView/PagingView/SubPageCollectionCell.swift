//
//  SubPageCollectionCell.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class SubPageCollectionCell: UICollectionViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var equelLabel: UILabel!
    @IBOutlet weak var persentLabel: UILabel!
    @IBOutlet weak var hiddenMoneyLabel: UILabel!
    @IBOutlet weak var hiddenequelLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
//        applyCornerRadius()
        setupUI()
    }
 
    // MARK: -
    // MARK:業務方法
    func setData(data: WalletBalancesDto) {
        amountLabel.text = "\(data.amount)".numberFormatter(.decimal, 8)
        equelLabel.text = "≈$"+"\(data.amount)".numberFormatter(.decimal, 2)
        coinLabel.text = data.token
        coinImageView.image = UIImage(named: "icon-usdt")
        currencyLabel.text = data.currency
    }
    
    func setupUI()
    {
        WalletSecurityThemes.moneyVisibleOrNotVisible.bind(to: amountLabel.rx.isHidden).disposed(by: dpg)
        WalletSecurityThemes.stringVisibleOrNotVisible.bind(to: hiddenMoneyLabel.rx.isHidden).disposed(by: dpg)
        WalletSecurityThemes.moneyVisibleOrNotVisible.bind(to: equelLabel.rx.isHidden).disposed(by: dpg)
        WalletSecurityThemes.stringVisibleOrNotVisible.bind(to: hiddenequelLabel.rx.isHidden).disposed(by: dpg)
    }

}
