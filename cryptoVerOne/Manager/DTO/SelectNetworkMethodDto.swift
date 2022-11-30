//
//  SelectNetworkMethodDto.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/30.
//


import Foundation
class SelectNetworkMethodDto :Codable {

    var methods : [SelectNetworkMethodDetailDto] = [SelectNetworkMethodDetailDto()]
    init(methods: [SelectNetworkMethodDetailDto] = [SelectNetworkMethodDetailDto()]) {
        self.methods = methods
    }
}
class SelectNetworkMethodDetailDto : Codable {
    var name: String = ""

    init(name: String = "") {
        self.name = name
    }
}
