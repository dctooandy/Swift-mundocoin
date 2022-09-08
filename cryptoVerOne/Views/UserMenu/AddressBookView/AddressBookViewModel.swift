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
        _ = AddressBookListDto.update { [self] in
            let dtos = KeychainManager.share.getAddressBookList()
            fetchSuccess.onNext(dtos)
        }
    }
  
    func rxFetchSuccess() -> Observable<[AddressBookDto]> {
        return fetchSuccess.asObserver()
    }
}
