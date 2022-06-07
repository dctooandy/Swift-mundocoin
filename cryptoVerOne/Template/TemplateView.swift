//
//  TemplateView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/13.
//

import Foundation
import RxCocoa
import RxSwift

class TemplateView: UIView ,NibOwnerLoadable{
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
   
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func customInit()
    {
        loadNibContent()
    }
    // MARK: -
    // MARK:業務方法
}
// MARK: -
// MARK: 延伸
