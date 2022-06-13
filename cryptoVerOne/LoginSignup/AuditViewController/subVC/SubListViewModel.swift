//
//  SubListViewModel.swift
//  cryptoVerOne
//
//  Created by BBk on 6/13/22.
//


import Foundation
import RxCocoa
import RxSwift

class SubListViewModel: BaseViewModel {
    private var fetchSuccess = PublishSubject<Any>()
    
    override init() {
        super.init()
    }
    
    func fetch()
    {
//        Beans.walletServer.walletAddress().subscribe { [self](walletDto) in
//            _ = LoadingViewController.dismiss()
//            if let data = walletDto
//            {
//                fetchWalletAddressSuccess.onNext(data)
//            }
//        } onError: { (error) in
//            ErrorHandler.show(error: error)
//        }.disposed(by: disposeBag)
        fetchSuccess.onNext(())
    }
  
    func rxFetchSuccess() -> Observable<Any> {
        return fetchSuccess.asObserver()
    }
}
