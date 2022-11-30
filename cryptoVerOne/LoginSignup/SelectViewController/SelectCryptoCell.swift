//
//  SelectCryptoCell.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/30.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class SelectCryptoCell: UITableViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var currencyIcon: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var networkLabel: UILabel!
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
        backView.layer.borderColor = Themes.grayE9EDF7.cgColor
        backView.layer.borderWidth = 1
    }
    func bindUI()
    {
        
    }
    func config(withData data:SelectCryptoDetailDto)
    {
        currencyIcon.image = UIImage(named: data.cryptoIconName)
        currencyLabel.text = data.cryptoName
        networkLabel.text = data.cryptoNetworkName
    }
}
// MARK: -
// MARK: 延伸
