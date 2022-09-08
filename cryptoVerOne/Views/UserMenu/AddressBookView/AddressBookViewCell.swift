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
    private let onChangeWhiteListClick = PublishSubject<AddressBookDto>()
    private let dpg = DisposeBag()
    var cellData:AddressBookDto!
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var whiteListSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var networkMethodLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupUI()
        bindUI()
        shouldIndentWhileEditing = false
    }
    func setData(data:AddressBookDto)
    {
        self.cellData = data
        whiteListSwitch.isOn = cellData.enabled
        nameLabel.text = cellData.name
        walletLabel.text = cellData.label
        networkMethodLabel.text = cellData.network
        addressLabel.text = cellData.address
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        WhiteListThemes.whiteListSwitchAlpha.bind(to: whiteListSwitch.rx.alpha).disposed(by: dpg)
        WhiteListThemes.whiteListSwitchEnable.bind(to: whiteListSwitch.rx.isUserInteractionEnabled).disposed(by: dpg)
        whiteListSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    func bindUI()
    {
        whiteListSwitch.rx.isOn.subscribeSuccess { [self]isOn in
            if cellData != nil
            {
                cellData.enabled = isOn
                if KeychainManager.share.updateAddressbook(cellData) == true
                {
                    if isOn == true
                    {
                        Log.i("開啟單獨WhiteList")
                        onChangeWhiteListClick.onNext(cellData)
                    }else
                    {
                        Log.i("關閉單獨WhiteList")
                    }
                }else
                {
                }
            }
        }.disposed(by: dpg)
    }
    
    func rxChangeWhiteListClick() -> Observable<AddressBookDto>
    {
        return onChangeWhiteListClick.asObservable()
    }
}
// MARK: -
// MARK: 延伸
