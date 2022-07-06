//
//  BoardViewModel.swift
//  cryptoVerOne
//
//  Created by BBk on 6/7/22.
//


import Foundation
import RxCocoa
import RxSwift

class BoardViewModel: BaseViewModel {
    private var fetchWalletTransactionsSuccess = PublishSubject<WalletTransactionDto>()
    
    override init() {
        super.init()
    }
    
    func fetchWalletTransactions(currency:String = "" , stats : String = "",type : String = "",beginDate:TimeInterval = 0 , endDate:TimeInterval = 0 , pageable :PagePostDto = PagePostDto())
    {
        Beans.walletServer.walletTransactions(currency: currency, stats: stats,type: type, beginDate: beginDate, endDate: endDate, pageable: pageable).subscribe { [self](walletDto) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    _ = LoadingViewController.dismiss()
                    if let data = walletDto
                    {
                        fetchWalletTransactionsSuccess.onNext(data)
                    }
                }
            } onError: { (error) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    _ = LoadingViewController.dismiss().subscribeSuccess { _ in
                        ErrorHandler.show(error: error)
                    }
                }
            }.disposed(by: disposeBag)
    }
  
    func rxWalletTransactionsSuccess() -> Observable<WalletTransactionDto> {
        return fetchWalletTransactionsSuccess.asObserver()
    }
}
