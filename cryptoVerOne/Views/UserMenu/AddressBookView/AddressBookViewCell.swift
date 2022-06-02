//
//  AddressBookViewCell.swift
//  cryptoVerOne
//
//  Created by BBk on 5/31/22.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class AddressBookViewCell: UITableViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var whiteListSwitch: UISwitch!
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
        Themes.whiteListSwitchAlpha.bind(to: whiteListSwitch.rx.alpha).disposed(by: dpg)
        Themes.whiteListSwitchEnable.bind(to: whiteListSwitch.rx.isUserInteractionEnabled).disposed(by: dpg)
        whiteListSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    func bindUI()
    {
        
    }
}
// MARK: -
// MARK: 延伸
