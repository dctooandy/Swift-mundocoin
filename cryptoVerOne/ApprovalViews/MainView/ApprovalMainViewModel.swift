//
//  ApprovalMainViewModel.swift
//  cryptoVerOne
//
//  Created by BBk on 6/9/22.
//


import Foundation
import RxCocoa
import RxSwift

class ApprovalMainViewModel: BaseViewModel {
    private var fetchSuccess = PublishSubject<Any>()
    
    override init() {
        super.init()
    }
    
    func fetch()
    {
        fetchSuccess.onNext(())
    }
  
    func rxFetchSuccess() -> Observable<Any> {
        return fetchSuccess.asObserver()
    }
}
