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
//        bindBalance()
    }
    
    func fetchBalances()
    {
//        _ = WalletAllBalancesDto.update()
        if UserStatus.share.isLogin
        {
            Beans.walletServer.walletBalances().subscribe { [self](balanceDto) in
                if let dto = balanceDto?.wallets
                {
                    fetchWalletBalancesSuccess.onNext(dto)
                }
            } onError: { (error) in
                _ = LoadingViewController.dismiss()
                ErrorHandler.show(error: error)
            }.disposed(by: disposeBag)
        }
    }
    func bindBalance()
    {
//        if UserStatus.share.isLogin
//        {
//            WalletAllBalancesDto.rxShare.subscribe { [self](balanceDto) in
//                if let dto = balanceDto?.wallets
//                {
//                    fetchWalletBalancesSuccess.onNext(dto)
//                }
//            } onError: { (error) in
//                _ = LoadingViewController.dismiss()
//                ErrorHandler.show(error: error)
//            }.disposed(by: disposeBag)
//        }
    }
    func rxFetchWalletBalancesSuccess() -> Observable<[WalletBalancesDto]> {
        return fetchWalletBalancesSuccess.asObserver()
    }
}
