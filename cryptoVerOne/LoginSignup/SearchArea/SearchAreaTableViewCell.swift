//
//  SearchAreaTableViewCell.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/15.
//


import Foundation
import UIKit
import RxCocoa
import RxSwift

class SearchAreaTableViewCell: UITableViewCell {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
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
