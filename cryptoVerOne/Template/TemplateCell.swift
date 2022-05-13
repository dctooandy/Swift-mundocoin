//
//  TemplateCell.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/13.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class TemplateCell: UITableViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    
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
        
    }
    func bindUI()
    {
        
    }
}
// MARK: -
// MARK: 延伸
