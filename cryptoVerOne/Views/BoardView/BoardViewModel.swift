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
    
    func fetchWalletTransactions(currency:String = "" , stats : String = "", beginDate:TimeInterval = 0 , endDate:TimeInterval = 0 , pageable :String = "")
    {
        LoadingViewController.show()
        Beans.walletServer.walletTransactions(currency: currency, stats: stats, beginDate: beginDate, endDate: endDate, pageable: pageable).subscribe { [self](walletDto) in
            _ = LoadingViewController.dismiss()
            if let data = walletDto
            {
                fetchWalletTransactionsSuccess.onNext(data)
            }
        } onError: { (error) in
            _ = LoadingViewController.dismiss()
            ErrorHandler.show(error: error)
        }.disposed(by: disposeBag)
    }
  
    func rxWalletTransactionsSuccess() -> Observable<WalletTransactionDto> {
        return fetchWalletTransactionsSuccess.asObserver()
    }
}