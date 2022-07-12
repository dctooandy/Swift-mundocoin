//
//  AuditApprovalDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/6/20.
//


import Foundation
import RxSwift
struct AuditApprovalDto :Codable {
    static let disposeBag = DisposeBag()
    static var pendingShare:AuditApprovalDto?
    {
        didSet {
            guard let share = pendingShare else { return }
            pendingSubject.onNext(share)
        }
    }
    static var rxPendingShare:Observable<AuditApprovalDto?> = pendingSubject
        .do(onNext: { value in
            if pendingShare == nil {
                _ = pendingUpdate()
            }
    })
    static private let pendingSubject = BehaviorSubject<AuditApprovalDto?>(value: nil)
    static func pendingUpdate() -> Observable<()>{
        let subject = PublishSubject<Void>()
        Beans.auditServer.auditApprovals(state: AuditShowMode.pending.caseString,pageable: PagePostDto()).subscribeSuccess({ (configDto) in
            pendingShare = configDto
            subject.onNext(())
        }).disposed(by: disposeBag)
        return subject.asObservable()
    }
            
    // finish
    static var finishShare:AuditApprovalDto?
    {
        didSet {
            guard let share = finishShare else { return }
            finishSubject.onNext(share)
        }
    }
    static var rxFinishShare:Observable<AuditApprovalDto?> = finishSubject
        .do(onNext: { value in
            if finishShare == nil {
                _ = finishUpdate()
            }
    })
    static private let finishSubject = BehaviorSubject<AuditApprovalDto?>(value: nil)
    static func finishUpdate() -> Observable<()>{
        let subject = PublishSubject<Void>()
        Beans.auditServer.auditApprovals(state: AuditShowMode.finished.caseString,pageable: PagePostDto()).subscribeSuccess({ (configDto) in
            finishShare = configDto
            subject.onNext(())
        }).disposed(by: disposeBag)
        return subject.asObservable()
    }
            
    let size: Int
    let content: [WalletWithdrawDto]
    let number: Int
    let sort : SortDto
    let pageable: PageableDto
    let first: Bool
    let last: Bool
    let numberOfElements:Int
    let empty:Bool

    init(size: Int = 0, content: [WalletWithdrawDto] = [], number: Int = 0 , sort:SortDto = SortDto() ,pageable: PageableDto = PageableDto(), first: Bool = false, last: Bool = false, numberOfElements: Int = 0, empty: Bool = false) {
        self.size = size
        self.content = content
        self.number = number
        self.sort = sort
        self.pageable = pageable
        self.first = first
        self.last = last
        self.numberOfElements = numberOfElements
        self.empty = empty
    }
}

