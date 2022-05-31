//
//  WhiteListBottomView.swift
//  cryptoVerOne
//
//  Created by BBk on 5/31/22.


import Foundation
import RxCocoa
import RxSwift
import UIKit
import Switches

class WhiteListBottomView: UIView {
    // MARK:業務設定
    private let onCellClick = PublishSubject<UserAddressDto>()
    private let dpg = DisposeBag()
    
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var customSwitch: Switcher!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        titleLabel.text = "Whitelist".localized
        topLabel.text = "When this function is turned on, your account will only be able to withdraw to whitelisted withdrawal addresses. When this function is turned off, your account is able to withdraw to any withdrawal addresses.".localized

        if KeychainManager.share.getWhiteListOnOff() == true
        {
            customSwitch.sendActions(for: .touchUpInside)
            turnLabel.text = "Turn Off".localized
            turnLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }else
        {
            self.turnLabel.text = "Turn On".localized
            self.turnLabel.textColor = #colorLiteral(red: 0.3803921569, green: 0.2862745098, blue: 0.9647058824, alpha: 1)
        }
        
        customSwitch.rx.tap.subscribeSuccess { [self](_) in
            if self.customSwitch.isOn == true
            {
                self.turnLabel.text = "Turn Off".localized
                self.turnLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                TwoSideStyle.share.acceptWhiteListTopImageStyle(.whiteListOn)
                KeychainManager.share.saveWhiteListOnOff(true)
            }else
            {
                self.turnLabel.text = "Turn On".localized
                self.turnLabel.textColor = #colorLiteral(red: 0.3803921569, green: 0.2862745098, blue: 0.9647058824, alpha: 1)
                TwoSideStyle.share.acceptWhiteListTopImageStyle(.whiteListOff)
                KeychainManager.share.saveWhiteListOnOff(false)
            }
        }.disposed(by: dpg)
    }
    
    func rxCellDidClick() -> Observable<UserAddressDto>
    {
        return onCellClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸

