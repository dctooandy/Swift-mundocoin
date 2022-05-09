//
//  ResponseDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//

import Foundation


class ResponseDto<T:Codable ,U:Codable>:Codable
{
    let status:Int
    let data :[T]
    let meta :U?
    init(status : Int ,data : [T] ,meta:U){
        self.status = status
        self.data = data
        self.meta = meta
    }
}

class ResponseRequestErrorDto: Codable {
    let status:Int
    let message:String
    let code:Int
    
    init(status:Int,message:String,code:Int) {
        self.status = status
        self.message = message
        self.code = code
    }
}

class ResponseVertifyErrorDto: Codable {

    let status: Int
    let message: String
    let errors: [String:[String]]?
    let code:Int
    
    init(status: Int, message: String, errors: [String:[String]]?,code:Int) {

        self.status = status
        self.message = message
        self.errors = errors
        self.code = code
    }
}
