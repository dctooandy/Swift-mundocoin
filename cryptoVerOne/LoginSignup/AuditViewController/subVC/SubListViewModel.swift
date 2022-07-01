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
    private var fetchListSuccess = PublishSubject<(AuditApprovalDto, isUpdate:Bool)>()
    private var fetchListError = PublishSubject<(Any)>()
    // MARK: -
    // MARK:UI 設定
    // MARK: -
    // MARK:Life cycle
    override init() {
        super.init()
        bindDto()
    }
    func bindDto()
    {
        AuditApprovalDto.rxShare.subscribe { (dto) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                _ = LoadingViewController.dismiss()
                if let data = dto
                {
                    self.fetchListSuccess.onNext((data , true))
                }
            }
        }onError: { (error) in
            if let errorData = error as? ApiServiceError
            {
                switch errorData {
                case .errorDto(_):
                    ErrorHandler.show(error: error)
                default:
                    break
                }
            }
        }.disposed(by: disposeBag)
    }
    func fetch(currentPage:Int = 0)
    {
        Beans.auditServer.auditApprovals(pageable: PagePostDto(size: "20", page: String(currentPage))).subscribe { (dto) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                _ = LoadingViewController.dismiss()
                if let data = dto
                {
                    self.fetchListSuccess.onNext((data , false))
                }
            }
        }onError: { (error) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                Log.v("audit 過期")
                _ = LoadingViewController.dismiss()
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
                fetchListError.onNext(())
            }
        }.disposed(by: disposeBag)
    }
 
    func rxFetchListSuccess() -> Observable<(AuditApprovalDto , isUpdate:Bool)> {
        return fetchListSuccess.asObserver()
    }
    func rxFetchListError() -> Observable<Any> {
        return fetchListError.asObserver()
    }
    // MARK: -
    // MARK:業務方法
}
