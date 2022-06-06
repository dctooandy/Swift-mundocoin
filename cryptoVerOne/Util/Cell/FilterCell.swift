//
//  FilterCell.swift
//  cryptoVerOne
//
//  Created by BBk on 6/6/22.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class FilterCell: UITableViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var titleLabel: UILabel!

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
        backgroundColor = Themes.grayE0E5F2
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    func bindUI()
    {
        
    }
}
// MARK: -
// MARK: 延伸
extension FilterCell
{
    override open var isSelected: Bool {
        willSet {
            setSelected(newValue, animated: false)
            if isSelected == true
            {
                backgroundColor = Themes.gray707EAE
                self.titleLabel.textColor = .white
            }else
            {
                backgroundColor = Themes.grayE0E5F2
                self.titleLabel.textColor = Themes.gray707EAE
            }
        }
    }
}
