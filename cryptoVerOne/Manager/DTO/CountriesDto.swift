//
//  CountriesDto.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/15.
//

import Foundation

class CountriesDto :Codable {

    var countries : [CountryDetail] = [CountryDetail()]

    init(countries: [CountryDetail] ) {
        self.countries = countries
    }
}
class CountryDetail : Codable {
    var code: String = ""
    var name: String = ""

    init(code: String = "",name: String = "") {
        self.code = code
        self.name = name
    }
}
