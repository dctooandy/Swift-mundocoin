//
//  NetworkBottomSheet.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/13.
//

import Foundation
import RxCocoa
import RxSwift

class NetworkBottomSheet: BaseBottomSheet {
    // MARK:業務設定
    private let onCellSecondClick = PublishSubject<SelectNetworkMethodDetailDto>()
    private let dpg = DisposeBag()
    var dataArray : [SelectNetworkMethodDetailDto] = [] {
        didSet {
            networkMethodView.dataArray = dataArray
        }
    }
    // MARK: -
    // MARK:UI 設定
    var networkMethodView = NetworkBottomView.loadNib()
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        defaultContainer.addSubview(networkMethodView)
        networkMethodView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    func bindUI()
    {
        networkMethodView.rxCellDidClick().subscribeSuccess { [self](dto) in
            dismiss(animated: true) { [self] in
                onCellSecondClick.onNext(dto)
            }
        }.disposed(by: dpg)
    }
    func rxCellSecondClick() -> Observable<SelectNetworkMethodDetailDto>
    {
        return onCellSecondClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
