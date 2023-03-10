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
    private let onChangeWhiteListClickWhenOpen = PublishSubject<AddressBookDto>()
    private let onChangeWhiteListClickWhenClose = PublishSubject<AddressBookDto>()
    private let dpg = DisposeBag()
    var cellData:AddressBookDto!
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var whiteListSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var walletLabel: UILabel!
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
        let onColor  = UIColor(rgb: 0x0DC897)
        let offColor = UIColor(rgb: 0xA3AED0)
        whiteListSwitch.isOn = cellData.enabled
        /*For on state*/
        whiteListSwitch.onTintColor = onColor

        /*For off state*/
        whiteListSwitch.tintColor = offColor
        whiteListSwitch.backgroundColor = offColor
        nameLabel.text = cellData.name
//        walletLabel.text = cellData.label
        networkMethodLabel.text = cellData.network ?? "TRC20"
        addressLabel.text = cellData.address
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        WhiteListThemes.whiteListSwitchAlpha.bind(to: whiteListSwitch.rx.alpha).disposed(by: dpg)
        WhiteListThemes.whiteListSwitchEnable.bind(to: whiteListSwitch.rx.isUserInteractionEnabled).disposed(by: dpg)
        whiteListSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        whiteListSwitch.layer.cornerRadius = 15.5
        whiteListSwitch.clipsToBounds = true
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
                        Log.v("開啟單獨WhiteList")
                        onChangeWhiteListClickWhenOpen.onNext(cellData)
                    }else
                    {
                        Log.v("關閉單獨WhiteList")
                        onChangeWhiteListClickWhenClose.onNext(cellData)
                    }
                }else
                {
                }
            }
        }.disposed(by: dpg)
    }
    
    func rxChangeWhiteListClickWhenOpen() -> Observable<AddressBookDto>
    {
        return onChangeWhiteListClickWhenOpen.asObservable()
    }
    func rxChangeWhiteListClickWhenClose() -> Observable<AddressBookDto>
    {
        return onChangeWhiteListClickWhenClose.asObservable()
    }
}
// MARK: -
// MARK: 延伸
