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
    private let onConfirmClick = PublishSubject<WalletTransPostDto>()
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
        filterBottomView.rxConfirmTrigger().subscribeSuccess { [self] dto in
            dismiss(animated: true)
            onConfirmClick.onNext(dto)
        }.disposed(by: dpg)
        filterBottomView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        filterBottomView.showModeAtView = showModeAtSheet
    }
    func bindUI()
    {
        Themes.sheetHeightType.bind(to: heightConstraint.rx.constant).disposed(by: dpg)
    }
    func rxConfirmClick() -> Observable<WalletTransPostDto>
    {
        return onConfirmClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
