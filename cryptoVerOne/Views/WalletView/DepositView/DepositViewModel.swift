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
        LoadingViewController.show()
        Beans.walletServer.walletAddress().subscribe { [self](walletDto) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                _ = LoadingViewController.dismiss()
                if let data = walletDto
                {
                    fetchWalletAddressSuccess.onNext(data)
                }
            }
        } onError: { (error) in
            _ = LoadingViewController.dismiss()
            ErrorHandler.show(error: error)
        }.disposed(by: disposeBag)
    }
  
    func rxFetchWalletAddressSuccess() -> Observable<WalletAddressDto> {
        return fetchWalletAddressSuccess.asObserver()
    }
}
