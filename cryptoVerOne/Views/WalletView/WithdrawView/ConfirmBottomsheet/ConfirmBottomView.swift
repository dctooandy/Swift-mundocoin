//
//  ConfirmBottomView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/13.
//

import Foundation
import RxCocoa
import RxSwift

class ConfirmBottomView: UIView {
    // MARK:業務設定
    private let onConfirmClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var confirmButton: CornerradiusButton!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindUI()
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
    func bindUI()
    {
        confirmButton.rx.tap.subscribeSuccess { [self](_) in
            onConfirmClick.onNext(())
        }.disposed(by: dpg)
    }
    func rxConfirmAction() -> Observable<Any>
    {
        return onConfirmClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
