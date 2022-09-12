//
//  NotificationDto.swift
//  cryptoVerOne
//
//  Created by BBk on 6/8/22.
//

import Foundation
import RxSwift

class NotificationDto :Codable {

    var title: String = ""
    var message: String = ""
    var date: String = ""
    var type: String = ""
    var isRead:Bool = false

    init(title: String = "", message: String = "", date: String = "" , type: String = "",  isRead: Bool = false) {
        self.title = title
        self.message = message
        self.date = date
        self.type = type
        self.isRead = isRead
    }
}
