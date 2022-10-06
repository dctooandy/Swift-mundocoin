//
//  AddressBottomSheet.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/13.
//

import Foundation
import RxCocoa
import RxSwift

class AddressBottomSheet: BaseBottomSheet {
    // MARK:業務設定
    private let onCellSecondClick = PublishSubject<AddressBookDto>()
    private let onCleanDataClick = PublishSubject<Any>()
    private let onAddNewAddressClick = PublishSubject<Any>()
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
        addressView.rxAddNewAddressClick().subscribeSuccess { [self] _ in
            Log.i("增加錢包地址")
            dismissToTopVC(animation: false)
            onAddNewAddressClick.onNext(())
//            let addVC = AddNewAddressViewController.loadNib()
//            addVC.rxDismissClick().subscribeSuccess { _ in
//                self.addressView.setupData()
//            }.disposed(by: dpg)
//            addVC.modalPresentationStyle = .popover
//            self.present(addVC, animated: true)
//            self.navigationController?.pushViewController(addVC, animated: true)
        }.disposed(by: dpg)
        addressView.rxAddressBookClick().subscribeSuccess { [self] _ in
            Log.i("前往錢包地址")
            onCleanDataClick.onNext(())
            DeepLinkManager.share.handleDeeplink(navigation: .addressBook)
        }.disposed(by: dpg)
    }
    func rxCellSecondClick() -> Observable<AddressBookDto>
    {
        return onCellSecondClick.asObserver()
    }
    func rxCleanDataClick() -> Observable<Any>
    {
        return onCleanDataClick.asObserver()
    }
    func rxAddNewAddressClick() -> Observable<Any>
    {
        return onAddNewAddressClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
