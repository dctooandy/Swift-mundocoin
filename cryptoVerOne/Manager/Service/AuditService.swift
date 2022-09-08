//
//  AuditService.swift
//  cryptoVerOne
//
//  Created by BBk on 6/13/22.
//

import Foundation
import Foundation
import RxCocoa
import RxSwift
import Alamofire

class AuditService {
    func auditAuthentication(with idString:String , password:String , verificationCode:String = "")  -> Single<AuthenticationDto?>
    {
        var parameters: Parameters = [String: Any]()
        parameters = ["id":idString,
                      "password":password]
        if !verificationCode.isEmpty
        {
            parameters["verificationCode"] = verificationCode
        }
        return Beans.requestServer.singleRequestPost(
            path: ApiService.auditAuthentication.path,
            parameters: parameters,
            modify: false,
            resultType: AuthenticationDto.self).map({
                return $0
            })
    }
    func auditApprovals(state :String = "",pageable :PagePostDto = PagePostDto()) -> Single<AuditApprovalDto?>
    {
        var parameters: Parameters = [String: Any]()

        parameters["page"] = pageable.page
        parameters["size"] = pageable.size
        if !state.isEmpty
        {
            parameters["state"] = state            
        }
        return Beans.requestServer.singleRequestGet(
            path: ApiService.approvals.path,
            parameters: parameters,
            modify: false,
            resultType: AuditApprovalDto.self).map({
                return $0
            })
    }
    func auditApproval(approvalId :String , approvalNodeId: String,approvalState:String , memo:String) -> Single<String?>
    {
        var parameters: Parameters = [String: Any]()
        parameters["approvalState"] = approvalState
        parameters["memo"] = memo
        return Beans.requestServer.singleRequestPut(
            path: ApiService.adminApproval(approvalId, approvalNodeId).path,
            parameters: parameters,
            modify: false,
            resultType: String.self).map({
                return $0
            })
    }
}
