//
//  TXPayloadDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/29/22.
//

import Foundation
import RxSwift
struct TXPayloadDto : Codable {
    static var share:TXPayloadDto?
    {
        didSet {
            guard let share = share else { return }
            subject.onNext(share)
        }
    }
    static var rxShare:Observable<TXPayloadDto?> = subject
        .do(onNext: { value in
            if share == nil {
                _ = update()
            }
    })
    static let disposeBag = DisposeBag()
    static private let subject = BehaviorSubject<TXPayloadDto?>(value: nil)
    static func update() -> Observable<()>{
        let subject = PublishSubject<Void>()
        return subject.asObservable()
    }
    
    
    var id : String? = ""
    var createdDate : TimeInterval? = 0.0
    var updatedDate : TimeInterval? = 0.0
    var type : String? = "" //DEPOSIT
    var orderId : String? = ""
    var currency : String? = ""
    var txId : String? = ""
    var blockHeight : Int? = 0
    var amount : Int? = 0
    var fees : Int? = 0
    var broadcastTimestamp : TimeInterval? = 0.0
    var chainTimestamp : TimeInterval? = 0.0
    var fromAddress : String? = ""
    var toAddress : String? = ""
    var associatedWalletId : String? = ""
    var state : String? = "" //COMPLETE
    var confirmBlocks : Int? = 0
    var processingState : String? = "" //COMPLETE
    var decimal : Int? = 0
    var currencyBip44 : Int? = 0
    var tokenAddress : String? = ""
    var memo : String? = ""
    var errorReason : String? = ""
    var amlScreenPass : String? = ""
    var feeDecimal : Int? = 0
//    var tindex : String? = ""
//    var voutIndex : String? = ""
    
    var amountIntWithDecimal : JSONValue?
    {
        if let intValue = amount
        {
            let doubleValue = Double(intValue) / pow(10, Double(decimal!))
            return JSONValue.double(doubleValue)
        }else
        {
            return JSONValue.double(0.00)
        }
    }
    var detailType:DetailType
    {
        if state == "PROCESSING"
        {
            return .processing
        }
        else if state == "COMPLETE"
        {
            return .done
        }
        else if state == "PENDING"
        {
            return .pending
        }else
        {
            return .failed
        }
    }
    var createdDateString : String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeValue =  (createdDate ?? 0) / 1000
        return dateFormatter.string(from: Date(timeIntervalSince1970: timeValue))
    }
}
