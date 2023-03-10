//
//  WhiteListBottomSheet.swift
//  cryptoVerOne
//
//  Created by BBk on 5/31/22.
//


import Foundation
import RxCocoa
import RxSwift

class WhiteListBottomSheet: BaseBottomSheet {
    // MARK:業務設定
    private let onChangeWhiteListMode = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    var whiteListView = WhiteListBottomView.loadNib()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        defaultContainer.addSubview(whiteListView)
        whiteListView.rxSliderTrigger().subscribeSuccess { [self] _ in
            dismiss(animated: true)
            onChangeWhiteListMode.onNext(())
        }.disposed(by: dpg)
        whiteListView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    func bindUI()
    {
        
    }
    func rxChangeWhiteListMode() -> Observable<Any>
    {
        return onChangeWhiteListMode.asObserver()
    }
}
// MARK: -
// MARK: 延伸
