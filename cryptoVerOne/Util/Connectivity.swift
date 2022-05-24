//
//  Connectivity.swift
//  cryptoVerOne
//
//  Created by BBk on 5/24/22.
//

import Foundation
import Alamofire

class Connectivity {
 
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
