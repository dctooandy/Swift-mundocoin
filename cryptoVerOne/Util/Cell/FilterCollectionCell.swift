//
//  FilterCollectionCell.swift
//  cryptoVerOne
//
//  Created by BBk on 6/6/22.
//


import Foundation
import UIKit
import RxCocoa
import RxSwift

class FilterCollectionCell: UICollectionViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var mode : FilterLabelType = .deposits
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var titleLabel: UILabel!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindUI()
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        contentView.backgroundColor = Themes.grayE0E5F2
        titleLabel.textColor = Themes.gray707EAE
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    func bindUI()
    {
        
    }
    func setData(mode :FilterLabelType)
    {
        self.titleLabel.text = mode.title
        self.mode = mode
    }
    
}
// MARK: -
// MARK: 延伸
extension FilterCollectionCell
{
    override var isSelected: Bool {
            didSet {

                if isSelected == true
                {
                    contentView.backgroundColor = Themes.gray707EAE
                    self.titleLabel.textColor = .white
                }else
                {
                    contentView.backgroundColor = Themes.grayE0E5F2
                    self.titleLabel.textColor = Themes.gray707EAE
                }
            }
        }
    
}
