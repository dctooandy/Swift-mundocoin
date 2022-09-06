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
    private var fetchListSuccess = PublishSubject<(state:AuditShowMode,AuditApprovalDto, isUpdate:Bool)>()
    private var fetchListError = PublishSubject<(Any)>()
    // MARK: -
    // MARK:UI 設定
    // MARK: -
    // MARK:Life cycle
    init(state:AuditShowMode) {
        super.init()
        bindDto(state: state)
    }
    func bindDto(state:AuditShowMode)
    {
        if state == .pending
        {
            AuditApprovalDto.rxPendingShare.subscribe { (dto) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    _ = LoadingViewController.dismiss()
                    if let data = dto
                    {
                        self.fetchListSuccess.onNext((.pending,data , true))
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
        }else
        {
            AuditApprovalDto.rxFinishShare.subscribe { (dto) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                    _ = LoadingViewController.dismiss()
                    if let data = dto
                    {
                        self.fetchListSuccess.onNext((.finished,data , true))
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
    }
    func fetch(state :AuditShowMode = .pending , currentPage:Int = 0)
    {
        Beans.auditServer.auditApprovals(state: state.caseString, pageable: PagePostDto(size: "20", page: String(currentPage))).subscribe { (dto) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                _ = LoadingViewController.dismiss()
                if let data = dto
                {
                    if state == .pending
                    {
                        self.fetchListSuccess.onNext((.pending,data , false))
                    }else
                    {
                        self.fetchListSuccess.onNext((.finished,data , false))
                    }
                }
                // 0906 All State 過濾 pending
//                var newData:AuditApprovalDto = AuditApprovalDto()
//                if let data = dto
//                {
//                    if state == .pending
//                    {
//                        self.fetchListSuccess.onNext((.pending,data , false))
//                    }else
//                    {
//                        newData = data
//                        newData.content = data.content.filter {
//                            $0.state?.lowercased() != "pending"
//                            }
//                        self.fetchListSuccess.onNext((.finished,newData , false))
//                    }
//                }
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
 
    func rxFetchListSuccess() -> Observable<(state:AuditShowMode,AuditApprovalDto, isUpdate:Bool)> {
        return fetchListSuccess.asObserver()
    }
    func rxFetchListError() -> Observable<Any> {
        return fetchListError.asObserver()
    }
    // MARK: -
    // MARK:業務方法
}
