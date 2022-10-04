//
//  AddNewAddressCell.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/10/4.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class AddNewAddressCell: UITableViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var backView: UIView!
    

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
        backView.layer.borderColor = UIColor(rgb: 0xE0E5F2).cgColor
        backView.layer.borderWidth = 1
    }
    func bindUI()
    {
        
    }
}
// MARK: -
// MARK: 延伸
