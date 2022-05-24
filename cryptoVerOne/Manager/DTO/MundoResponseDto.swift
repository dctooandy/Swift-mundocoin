//
//  MundoResponseDto.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//

import Foundation
class MundoResponseDto<T:Codable>:Codable
{
    let ret:Int?
    let msg:String?
    let data :T?
    init(ret:Int = 0,
         msg:String = "",
         status : Int = 0,
         code:Int = 0 ,
         message:String = "" ,
         ttl:Int = 0 ,
         data : T
    ){
        self.ret = ret
        self.msg = msg
        self.status = status
        self.code = code
        self.message = message
        self.ttl = ttl
        self.data = data
    }
    
    let status:Int?
    let code : Int?
    let message:String?
    let ttl : Int?
    
    var errorMSG :String {
        return "\(msg ?? message ?? "")(\(ret ?? code ?? 0))"
    }
}
