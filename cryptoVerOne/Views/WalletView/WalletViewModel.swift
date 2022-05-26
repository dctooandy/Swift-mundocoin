//
//  WalletViewModel.swift
//  cryptoVerOne
//
//  Created by BBk on 5/26/22.
//

import Foundation
import RxCocoa
import RxSwift

class WalletViewModel: BaseViewModel {
    private var fetchWalletAddressSuccess = PublishSubject<WalletAddressDto>()
    
    override init() {
        super.init()
        self.bind()
    }
    func bind() {
        WalletAddressDto.rxShare.subscribe(onNext: { [self] dto in
            if let data = dto
            {
                fetchWalletAddressSuccess.onNext(data)
            }
        }, onError: { [self](error) in
            // 暫時先用空白代替
            fetchWalletAddressSuccess.onNext(WalletAddressDto())
            ErrorHandler.show(error: error)
        }).disposed(by: disposeBag)
    
       
    }
    func rxFetchWalletAddressSuccess() -> Observable<WalletAddressDto> {
        return fetchWalletAddressSuccess.asObserver()
    }
}
