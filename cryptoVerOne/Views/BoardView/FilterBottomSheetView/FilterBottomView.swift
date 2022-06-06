//
//  FilterBottomView.swift
//  cryptoVerOne
//
//  Created by BBk on 6/6/22.
//


import Foundation
import RxCocoa
import RxSwift
import UIKit

class FilterBottomView: UIView {
    // MARK:業務設定
    private let onConfirmTrigger = PublishSubject<Any>()
    private let dpg = DisposeBag()

    // MARK: -
    // MARK:UI 設定
   
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
       
    }
    
  
    func rxConfirmTrigger() -> Observable<Any>
    {
        return onConfirmTrigger.asObserver()
    }
}
// MARK: -
// MARK: 延伸

