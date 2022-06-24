//
//  UserMenuViewModel.swift
//  cryptoVerOne
//
//  Created by BBk on 6/24/22.
//

import Foundation
//
//  TemplateViewModel.swift
//  cryptoVerOne
//
//  Created by BBk on 6/7/22.
//

import Foundation
import RxCocoa
import RxSwift

class UserMenuViewModel: BaseViewModel {
    private var fetchSuccess = PublishSubject<Any>()
    
    override init() {
        super.init()
    }
    
    func fetch()
    {
        Beans.loginServer.customerLoginHistory().subscribe { [self](walletDto) in
            _ = LoadingViewController.dismiss()
            if let data = walletDto
            {
                
            }
        } onError: { (error) in
            ErrorHandler.show(error: error)
        }.disposed(by: disposeBag)
    }
  
    func rxFetchSuccess() -> Observable<Any> {
        return fetchSuccess.asObserver()
    }
}
