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
    static private let subject = PublishSubject<TXPayloadDto?>()
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
    var amount : JSONValue? = JSONValue.int(0)
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
    
    var txAmountIntWithDecimal : JSONValue?
    {
        if let amountDoubleValue = amount?.doubleValue
        {
            let doubleValue = amountDoubleValue / pow(10, Double(decimal ?? 0))
            return JSONValue.double(doubleValue)
        }else if let intValue = amount?.intValue
        {
            let doubleValue = Double(intValue) / pow(10, Double(decimal!))
            return JSONValue.double(doubleValue)
        }else
        {
            return JSONValue.double(0.00)
        }
    }
    var detailType:DetailType {
        if self.state == "PENDING" || self.state == "Pending" || self.processingState == "PENDING"
        {
            return .pending
        }else if state == "TRANSACTION_FAILED" ||
                    self.state == "FAILED" ||
                    self.state == "Failed" ||
                    self.processingState == "FAILED"
        {
            return.failed
        }else if state == "PROCESSING" || state == "Processing" || self.processingState == "IN_CHAIN"
        {
            return .processing
        }else
        {
            return .done
        }
    }
    var stateValue:String
    {
        switch self.detailType
        {
        case .done:
            return "COMPLETE"
        case .pending:
            return "PENDING"
        case .failed:
            return "FAILED"
        case .processing:
            return "PROCESSING"
        }
    }
    var createdDateString : String
    {
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MMMM dd, yyyy HH:mm"
        let timeValue =  (createdDate ?? 0) / 1000
        return newDateFormatter.string(from: Date(timeIntervalSince1970: timeValue))
    }
}
