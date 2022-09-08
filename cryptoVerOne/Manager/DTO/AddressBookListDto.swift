//
//  AddressBookListDto.swift
//  cryptoVerOne
//
//  Created by BBk on 9/8/22.
//

import Foundation
import Foundation
import RxSwift

class AddressBookListDto :Codable {
    static var share:AddressBookListDto?
    {
        didSet {
            guard let share = share else { return }
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<AddressBookListDto?> = subject
        .do(onNext: { value in
            if share == nil {
                _ = update(done: {})
            }
        })
    static let disposeBag = DisposeBag()
    static private let subject = PublishSubject<AddressBookListDto?>()
    static func update(done: @escaping () -> Void) -> Observable<()>{
        let subject = PublishSubject<Void>()
        Beans.addressBookServer.queryAddressBooks().subscribeSuccess({ (addressData) in
            share = addressData
            if let addressBookList = addressData?.content
            {
                if KeychainManager.share.saveAddressBookList(addressBookList) == true
                {
                    done()
                    subject.onNext(())
                }
            }
        }).disposed(by: disposeBag)
        return subject.asObservable()
    }
            let size: Int
            let content: [AddressBookDto]
            let number: Int
            let sort : SortDto
            let pageable: PageableDto
            let first: Bool
            let last: Bool
            let numberOfElements:Int
            let empty:Bool
            
            init(size: Int = 0, content: [AddressBookDto] = [], number: Int = 0 , sort:SortDto = SortDto() ,pageable: PageableDto = PageableDto(), first: Bool = false, last: Bool = false, numberOfElements: Int = 0, empty: Bool = false) {
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
