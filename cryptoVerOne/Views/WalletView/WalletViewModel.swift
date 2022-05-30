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
    private var fetchWalletBalancesSuccess = PublishSubject<[WalletBalancesDto]>()
    
    override init() {
        super.init()
    }
    
    func fetchBalances()
    {
        if UserStatus.share.isLogin
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
    }

    func rxFetchWalletBalancesSuccess() -> Observable<[WalletBalancesDto]> {
        return fetchWalletBalancesSuccess.asObserver()
    }
}
