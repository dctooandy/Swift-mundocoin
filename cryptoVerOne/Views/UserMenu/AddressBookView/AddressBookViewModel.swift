//
//  AddressBookViewModel.swift
//  cryptoVerOne
//
//  Created by BBk on 6/8/22.
//

import Foundation
import RxCocoa
import RxSwift

class AddressBookViewModel: BaseViewModel {
    private var fetchSuccess = PublishSubject<[AddressBookDto]>()
    
    override init() {
        super.init()
    }
    
    func fetchAddressBooks()
    {
        let dtos = KeychainManager.share.getAddressBookList()
        fetchSuccess.onNext(dtos)
//        Beans.walletServer.walletAddress().subscribe { [self](walletDto) in
//            _ = LoadingViewController.dismiss()
//            if let data = walletDto
//            {
//                fetchWalletAddressSuccess.onNext(data)
//            }
//        } onError: { (error) in
//            ErrorHandler.show(error: error)
//        }.disposed(by: disposeBag)
    }
  
    func rxFetchSuccess() -> Observable<[AddressBookDto]> {
        return fetchSuccess.asObserver()
    }
}
