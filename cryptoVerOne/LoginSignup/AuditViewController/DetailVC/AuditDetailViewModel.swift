//
//  AuditDetailViewModel.swift
//  cryptoVerOne
//
//  Created by BBk on 6/20/22.
//


import Foundation
import RxCocoa
import RxSwift

class AuditDetailViewModel: BaseViewModel {
    private var fetchSuccess = PublishSubject<Any>()
    
    override init() {
        super.init()
    }
    
    func fetch()
    {

    }
    func goApproval(approvalId :String , approvalNodeId: String,approvalState:String , memo:String)
    {
        Beans.auditServer.auditApproval(approvalId: approvalId, approvalNodeId: approvalNodeId, approvalState: approvalState, memo: memo).subscribe { [self] dto in
            if let data = dto
            {
                Log.v("Success : \(data)")
                fetchSuccess.onNext(())
            }
        } onError: { error in
            Log.v("資料異常 \(error)")
            ErrorHandler.show(error: error)
        }.disposed(by: disposeBag)
    }
    func rxFetchSuccess() -> Observable<Any> {
        return fetchSuccess.asObserver()
    }
}
