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
    private var fetchWalletBalancesSuccess = PublishSubject<[WalletBalancesDto]>()
    
    override init() {
        super.init()
        self.bind()
        self.fetchBalances()
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
    func fetchBalances()
    {
        Beans.walletServer.walletBalances().subscribe { [self](walletDto) in
            _ = LoadingViewController.dismiss()
            if let dto = walletDto
            {
                fetchWalletBalancesSuccess.onNext(dto)
            }
        } onError: { (error) in
            ErrorHandler.show(error: error)
        }.disposed(by: disposeBag)
    }
    func rxFetchWalletAddressSuccess() -> Observable<WalletAddressDto> {
        return fetchWalletAddressSuccess.asObserver()
    }
    func rxFetchWalletBalancesSuccess() -> Observable<[WalletBalancesDto]> {
        return fetchWalletBalancesSuccess.asObserver()
    }
}
