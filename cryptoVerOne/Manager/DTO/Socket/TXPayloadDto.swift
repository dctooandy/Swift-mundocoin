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
        var difValue = 1.0
        // socket 第三次回來時,blockHeight非 nil 時給fee 1
        if stateValue == "FAILED" || stateValue == "PENDING" || blockHeight == nil
        {
            if blockHeight != nil
            {
                difValue = 1.0
            }else
            {
                difValue = 0.0
            }
        }
        if type == "DEPOSIT"
        {
            difValue = 0.0
        }
        if let amountDoubleValue = amount?.doubleValue
        {
            let doubleValue = amountDoubleValue / pow(10, Double(decimal ?? 0))
            return JSONValue.double(doubleValue + difValue)
        }else if let intValue = amount?.intValue
        {
            let doubleValue = Double(intValue) / pow(10, Double(decimal ?? 0))
            return JSONValue.double(doubleValue + difValue)
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
            //暫時改為Inner
            return .failed
//            return .innerFailed
        }else if state == "PROCESSING" || state == "Processing" || self.processingState == "IN_CHAIN"
        {
            return .processing
        }else
        {
            //暫時改為Inner
            return .done
//            return .innerDone
        }
    }
    var stateValue:String
    {
        switch self.detailType
        {
        case .done,.innerDone:
            return "COMPLETE"
        case .pending:
            return "PENDING"
        case .failed,.innerFailed:
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
    var updatedDateString : String
    {
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MMMM dd, yyyy HH:mm"
        let timeValue =  (updatedDate ?? 0) / 1000
        return newDateFormatter.string(from: Date(timeIntervalSince1970: timeValue))
    }
}
