//
//  WhiteListBottomView.swift
//  cryptoVerOne
//
//  Created by BBk on 5/31/22.


import Foundation
import RxCocoa
import RxSwift
import UIKit
import OOSwitch

class WhiteListBottomView: UIView {
    // MARK:業務設定
    private let onCellClick = PublishSubject<UserAddressDto>()
    private let dpg = DisposeBag()
    
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var customOOSwitch: OOSwitch!

    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSwitch()
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
            let switchSender = OOSwitch()
            switchSender.isOn = true
            switchValueChange(switchSender)
        }else
        {
            let switchSender = OOSwitch()
            switchSender.isOn = false
            switchValueChange(switchSender)
        }
    }
    @IBAction func switchValueChange(_ sender: OOSwitch) {
        if sender.isOn == true
        {
            customOOSwitch.isOn = true
            self.turnLabel.text = "Turn Off".localized
            self.turnLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            TwoSideStyle.share.acceptWhiteListTopImageStyle(.whiteListOn)
            KeychainManager.share.saveWhiteListOnOff(true)
        }else
        {
            customOOSwitch.isOn = false
            self.turnLabel.text = "Turn On".localized
            self.turnLabel.textColor = #colorLiteral(red: 0.3803921569, green: 0.2862745098, blue: 0.9647058824, alpha: 1)
            TwoSideStyle.share.acceptWhiteListTopImageStyle(.whiteListOff)
            KeychainManager.share.saveWhiteListOnOff(false)
        }
    }
    func setupSwitch()
    {
        customOOSwitch.translatesAutoresizingMaskIntoConstraints = false
        customOOSwitch.onTintColor = #colorLiteral(red: 0.3803921569, green: 0.2862745098, blue: 0.9647058824, alpha: 1)
        customOOSwitch.offTintColor = #colorLiteral(red: 0.8795114756, green: 0.8701208234, blue: 0.9882549644, alpha: 1)
        customOOSwitch.imageCornerRadius = 0.5
        customOOSwitch.thumbCornerRadius = 0.5
        customOOSwitch.thumbTintColor = #colorLiteral(red: 0.3803921569, green: 0.2862745098, blue: 0.9647058824, alpha: 1)
        customOOSwitch.animationDuration = 0.5
        customOOSwitch.onImage = #imageLiteral(resourceName: "Rectangle14")
        customOOSwitch.offImage = #imageLiteral(resourceName: "Rectangle14")
        customOOSwitch.labelOn.text = "Turn Off"
        customOOSwitch.labelOff.text = "Turn On"
        customOOSwitch.areLabelsShown = false
        customOOSwitch.isOn = false
    }

    func rxCellDidClick() -> Observable<UserAddressDto>
    {
        return onCellClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸

