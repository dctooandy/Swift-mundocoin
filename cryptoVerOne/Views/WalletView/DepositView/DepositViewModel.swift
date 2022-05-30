//
//  DepositViewModel.swift
//  cryptoVerOne
//
//  Created by BBk on 5/30/22.
//


import Foundation
import RxCocoa
import RxSwift

class DepositViewModel: BaseViewModel {
    private var fetchWalletAddressSuccess = PublishSubject<WalletAddressDto>()
    
    override init() {
        super.init()
    }
    
    func fetchWalletForDeposit()
    {
        Beans.walletServer.walletAddress().subscribe { [self](walletDto) in
            _ = LoadingViewController.dismiss()
            if let data = walletDto
            {
                fetchWalletAddressSuccess.onNext(data)
            }
        } onError: { (error) in
            ErrorHandler.show(error: error)
        }.disposed(by: disposeBag)
    }
  
    func rxFetchWalletAddressSuccess() -> Observable<WalletAddressDto> {
        return fetchWalletAddressSuccess.asObserver()
    }
}
