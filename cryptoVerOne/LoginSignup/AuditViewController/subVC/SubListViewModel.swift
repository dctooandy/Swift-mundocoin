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
        Beans.auditServer.auditApprovals().subscribe { (dto) in
            _ = LoadingViewController.dismiss()
            if let data = dto
            {
                //                fetchWalletAddressSuccess.onNext(data)
            }
        }onError: { [self] (error) in
            if let errorData = error as? ApiServiceError
            {
                switch errorData {
                case .errorDto(let dto):
                    let status = dto.httpStatus ?? ""
                    let code = dto.code
                    let reason = dto.reason
                    let errors = dto.errors
                    ErrorHandler.show(error: error)
                default:
                    break
                }
            }
        }.disposed(by: disposeBag)
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
