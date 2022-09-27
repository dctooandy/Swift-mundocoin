//
//  AddressBottomCell.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/13.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class AddressBottomCell: UITableViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var protocolLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupUI()
        bindUI()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        bindUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        
    }
    func setAccountData(data:AddressBookDto)
    {
        nameLabel.text = data.name
        if let networkString = data.network
        {
            protocolLabel.text = networkString
        }else
        {
            protocolLabel.text = "(TRC20)"
        }
        addressLabel.text = data.address
    }
    func bindUI()
    {
        
    }
}
// MARK: -
// MARK: 延伸
