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
    static var dataArray : [WalletWithdrawDto] = []
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
    static var tempShare:AuditApprovalDto?
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
        
        // 混合 approval / cancelled
//        let group = DispatchGroup()
//        let dispatchQueue = DispatchQueue.global(qos: .default)
//        self.dataArray.removeAll()
//        group.enter()
//        dispatchQueue.async {
//            Beans.auditServer.auditApprovals(state: AuditShowMode.approved.caseString,pageable: PagePostDto()).subscribe { (configDto) in
//                if let data = configDto
//                {
//                    tempShare = data
//                    self.dataArray.append(contentsOf: data.content)
//                }
//                group.leave()
//            } onError: { error in
//                if let errorData = error as? ApiServiceError
//                {
//                    switch errorData {
//                    default:
//                        ErrorHandler.show(error: error)
//                    }
//                    group.leave()
//                }
//            }.disposed(by: disposeBag)
//        }
//        group.enter()
//        dispatchQueue.async {
//            Beans.auditServer.auditApprovals(state: AuditShowMode.cancelled.caseString,pageable: PagePostDto()).subscribe { (configDto) in
//                if let data = configDto
//                {
//                    tempShare = data
//                    self.dataArray.append(contentsOf: data.content)
//                }
//                group.leave()
//            } onError: { error in
//                if let errorData = error as? ApiServiceError
//                {
//                    switch errorData {
//                    default:
//                        ErrorHandler.show(error: error)
//                    }
//                    group.leave()
//                }
//            }.disposed(by: disposeBag)
//        }
//
//        group.notify(queue: DispatchQueue.main) {
//            print("jobs done by group")
//            tempShare?.content = self.dataArray
//            finishShare = tempShare
//             subject.onNext(())
//        }
        
        Beans.auditServer.auditApprovals(state: AuditShowMode.finished.caseString,pageable: PagePostDto()).subscribeSuccess({ (configDto) in
            finishShare = configDto
            subject.onNext(())
            // 0906 All State 過濾 pending
//            var newData:AuditApprovalDto = AuditApprovalDto()
//            if let data = configDto
//            {
//                    newData = data
//                    newData.content = data.content.filter {
//                        $0.state?.lowercased() != "pending"
//                        }
//                finishShare = newData
//                subject.onNext(())
//            }
        }).disposed(by: disposeBag)
        return subject.asObservable()
    }
            
    let size: Int
    var content: [WalletWithdrawDto]
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

