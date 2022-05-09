//
//  ValueDto.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation

class ValueIntDto:Codable {
    let value:Int
    let display:String?
}

class ValueStringDto:Codable {
    let value:String
    let display:String?
}

class ValueOptionIntDto:Codable {
    let value:Int?
    let display:String?
}

class ValueOptionStringDto:Codable {
    let value:String?
    let display:String?
}

class ValueOptionBoolDto:Codable {
    let value:Bool?
    let display:String?
}
