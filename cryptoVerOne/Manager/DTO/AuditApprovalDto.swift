//
//  AuditApprovalDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/6/20.
//


import Foundation
import RxSwift
struct AuditApprovalDto :Codable {
    static var share:AuditApprovalDto?
    {
        didSet {
            guard let share = share else { return }
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<AuditApprovalDto?> = subject
        .do(onNext: { value in
            if share == nil {
                _ = update()
            }
    })
    static let disposeBag = DisposeBag()
    static private let subject = BehaviorSubject<AuditApprovalDto?>(value: nil)
    static func update() -> Observable<()>{
        let subject = PublishSubject<Void>()
        Beans.auditServer.auditApprovals(pageable: PagePostDto()).subscribeSuccess({ (configDto) in
            share = configDto
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

