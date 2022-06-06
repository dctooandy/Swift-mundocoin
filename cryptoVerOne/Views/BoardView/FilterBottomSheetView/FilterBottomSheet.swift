//
//  FilterBottomSheet.swift
//  cryptoVerOne
//
//  Created by BBk on 6/6/22.
//



import Foundation
import RxCocoa
import RxSwift

class FilterBottomSheet: BaseBottomSheet {
    // MARK:業務設定
    private let onConfirmClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var showModeAtSheet : TransactionShowMode = .deposits
    // MARK: -
    // MARK:UI 設定
    var filterBottomView = FilterBottomView.loadNib()
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
        defaultContainer.addSubview(filterBottomView)
        filterBottomView.rxConfirmTrigger().subscribeSuccess { [self] _ in
            dismiss(animated: true)
            onConfirmClick.onNext(())
        }.disposed(by: dpg)
        filterBottomView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    func bindUI()
    {
        
    }
    func rxConfirmClick() -> Observable<Any>
    {
        return onConfirmClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
