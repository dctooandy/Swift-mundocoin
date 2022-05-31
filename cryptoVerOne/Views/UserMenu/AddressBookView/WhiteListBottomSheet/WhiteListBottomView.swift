//
//  WhiteListBottomView.swift
//  cryptoVerOne
//
//  Created by BBk on 5/31/22.


import Foundation
import RxCocoa
import RxSwift
import UIKit
import KNSwitcher

class WhiteListBottomView: UIView {
    // MARK:業務設定
    private let onCellClick = PublishSubject<UserAddressDto>()
    private let dpg = DisposeBag()
    
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!

    @IBOutlet weak var knzSwitcher: UIView!
    
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
//        let switcher = KNSwitcher(frame: CGRect(x: 100, y: 100, width: 200, height: 80), on: false)
//        switcher.setImages(onImage: UIImage(named: "Checkmark"), offImage: UIImage(named: "Delete"))
//        addSubview(switcher)
    }

    func rxCellDidClick() -> Observable<UserAddressDto>
    {
        return onCellClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸

