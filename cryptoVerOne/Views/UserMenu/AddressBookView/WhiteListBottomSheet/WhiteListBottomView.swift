//
//  WhiteListBottomView.swift
//  cryptoVerOne
//
//  Created by BBk on 5/31/22.


import Foundation
import RxCocoa
import RxSwift

class WhiteListBottomView: BaseBottomSheet {
    // MARK:業務設定
    private let onCellSecondClick = PublishSubject<UserAddressDto>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    var addressView = AddressBottomView.loadNib()
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
        defaultContainer.addSubview(addressView)
        addressView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    func bindUI()
    {
        addressView.rxCellDidClick().subscribeSuccess { [self](dto) in
            dismiss(animated: true) { [self] in
                onCellSecondClick.onNext(dto)
            }
        }.disposed(by: dpg)
    }
    func rxCellSecondClick() -> Observable<UserAddressDto>
    {
        return onCellSecondClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
