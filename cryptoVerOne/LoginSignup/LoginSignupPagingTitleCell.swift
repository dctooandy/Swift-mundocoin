//
//  LoginSignupPagingTitleCell.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/14.
//

import Foundation
import Parchment
import RxCocoa
import RxSwift
import SnapKit

class LoginSignupPagingTitleCell: PagingTitleCell {
    // MARK:業務設定
    // MARK: -
    var viewModel: PagingTitleCellViewModel?
    var cellHeight:CGFloat = 40
    var cellWidth:CGFloat = 90
    // MARK:UI 設定
    // MARK: -
    // MARK:Life cycle
    // MARK: -
    // MARK:業務方法
    open override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
      if let titleItem = pagingItem as? PagingTitleItem {
        viewModel = PagingTitleCellViewModel(
          title: titleItem.title,
          selected: selected,
          options: options)
      }
      configureNewTitleLabel()
    }
    open func configureNewTitleLabel() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.title
        titleLabel.textAlignment = .center
        if viewModel.selected {
            titleLabel.font = viewModel.selectedFont
            titleLabel.textColor = viewModel.selectedTextColor
            titleLabel.backgroundColor = viewModel.selectedBackgroundColor
 
//            contentView.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMaxXMinYCorner]
        } else {
            titleLabel.font = viewModel.font
            titleLabel.textColor = viewModel.textColor
            titleLabel.backgroundColor = viewModel.backgroundColor

//            contentView.layer.maskedCorners = [.layerMinXMinYCorner , .layerMinXMaxYCorner]
        }
    }
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
      super.apply(layoutAttributes)
        titleLabel.layer.borderColor = UIColor.white.cgColor
        titleLabel.layer.borderWidth = 3
        titleLabel.layer.cornerRadius = (Views.sHeight(value: cellHeight - 2) / 2)
        titleLabel.layer.masksToBounds = true
        self.backgroundColor = Themes.grayE0E5F2
        self.contentView.backgroundColor = .white
//        self.contentView.applyCornerAndShadow(radius: layoutAttributes.frame.height / 2)
//        self.applyCornerAndShadow(radius: layoutAttributes.frame.height / 2)
        self.layer.cornerRadius = layoutAttributes.frame.height / 2
        self.contentView.layer.cornerRadius = (Views.sHeight(value: cellHeight - 2) / 2)
        if layoutAttributes.indexPath.last == 1
        {
            contentView.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(-1)
                make.centerY.equalToSuperview()
                make.width.equalTo(Views.sWidth(value: cellWidth - 1))
                make.height.equalTo(Views.sHeight(value: cellHeight - 2))
            }
            titleLabel.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(-1)
                make.centerY.equalToSuperview()
                make.width.equalTo(Views.sWidth(value: cellWidth - 1))
                make.height.equalTo(Views.sHeight(value: cellHeight - 2))
            }
            self.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMaxXMinYCorner]
            self.contentView.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMaxXMinYCorner]
        }else
        {
            contentView.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(1)
                make.centerY.equalToSuperview()
                make.width.equalTo(Views.sWidth(value: cellWidth - 1))
                make.height.equalTo(Views.sHeight(value: cellHeight - 2))
            }
            titleLabel.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(1)
                make.centerY.equalToSuperview()
                make.width.equalTo(Views.sWidth(value: cellWidth - 1))
                make.height.equalTo(Views.sHeight(value: cellHeight - 2))
            }
            self.layer.maskedCorners = [.layerMinXMinYCorner , .layerMinXMaxYCorner]
            self.contentView.layer.maskedCorners = [.layerMinXMinYCorner , .layerMinXMaxYCorner]
        }
        self.layer.masksToBounds = true
        self.contentView.layer.masksToBounds = true
//        layer.cornerRadius = layoutAttributes.frame.height / 2
//        if self.isSelected == true
//        {
//            titleLabel.backgroundColor = Themes.gray2B3674
////            clipsToBounds = true
//            if #available(iOS 11.0, *) {
//                layer.maskedCorners = [.layerMinXMinYCorner , .layerMinXMaxYCorner]
//            } else {
//                // Fallback on earlier versions
//            }
//        }else
//        {
//            titleLabel.backgroundColor = .white
//            if #available(iOS 11.0, *) {
//                layer.maskedCorners = [.layerMaxXMinYCorner , .layerMaxXMaxYCorner]
//            } else {
//                // Fallback on earlier versions
//            }
//        }
    }
    open override func layoutSubviews() {
      super.layoutSubviews()
//        contentView.snp.remakeConstraints { (make) in
//            make.centerX.equalToSuperview().offset(viewModel!.selected ? 1: -1)
//            make.centerY.equalToSuperview()
//            make.width.equalTo(123)
//            make.height.equalTo(46)
//        }
//        titleLabel.snp.remakeConstraints { (make) in
//            make.centerX.equalToSuperview().offset(viewModel!.selected ? 1: -1)
//            make.centerY.equalToSuperview()
//            make.width.equalTo(123)
//            make.height.equalTo(44)
//        }
    }
}
