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
    // MARK:業務設定
    private var fetchSuccess = PublishSubject<Any>()
    private var fetchListSuccess = PublishSubject<AuditApprovalDto>()
    // MARK: -
    // MARK:UI 設定
    // MARK: -
    // MARK:Life cycle
    override init() {
        super.init()
    }
    
    func fetch(currentPage:Int = 0)
    {
        Beans.auditServer.auditApprovals(pageable: PagePostDto(size: "10", page: String(currentPage))).subscribe { (dto) in
            _ = LoadingViewController.dismiss()
            if let data = dto
            {
                self.fetchListSuccess.onNext(data)
            }
        }onError: { (error) in
            if let errorData = error as? ApiServiceError
            {
                switch errorData {
                case .errorDto(_):
//                    let status = dto.httpStatus ?? ""
//                    let code = dto.code
//                    let reason = dto.reason
//                    let errors = dto.errors
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
    func rxFetchListSuccess() -> Observable<AuditApprovalDto> {
        return fetchListSuccess.asObserver()
    }
    // MARK: -
    // MARK:業務方法
}
