//
//  SocketIOManager.swift
//  cryptoVerOne
//
//  Created by BBk on 6/10/22.
//
import SocketIO
import Foundation
import JWTDecode

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
#if Approval_PRO || Approval_DEV || Approval_STAGE
    let manager = SocketManager(socketURL: URL(string: "https://dev.api.mundocoin.com:443")!, config: [.log(true), .compress])
#else
    let manager = SocketManager(socketURL: URL(string: "https://dev.api.mundocoin.com:443")!, config: [.log(true), .compress])
#endif
    var socket : SocketIOClient!
//    var socket: SocketIOClient = SocketIOClient(socketURL:  ,nsp: "")
    
    override init() {
        super.init()
        setup()
        bind()
    }
    func setup()
    {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        let token = KeychainManager.share.getAuditToken()
#else
        let token = KeychainManager.share.getToken()
#endif
        self.manager.config = SocketIOClientConfiguration(arrayLiteral: .connectParams(["Authorization": "Bearer \(token)"]), .secure(true)
        )
        socket = manager.socket(forNamespace: "/notification")
        socket.joinNamespace()
    }
    func bind()
    {
        var jwtValue :JWT!
        do {
            let token = KeychainManager.share.getToken()
            jwtValue = try decode(jwt: token)
        } catch {
            print("Failed to decode JWT: \(error)")
        }
        var idValue = ""
        if jwtValue != nil , let idString = jwtValue.body["Id"] as? String
        {
            idValue = idString
        }

        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.socket.emit("join", idValue) {
                Log.v("Join call back")
            }
        }
        
        socket.on(idValue) { data, ack in
            Log.v("data \(data)")
        }
        socket.on("joinResult") { resultData, ack in
            if let resultString = resultData.first as? String
            {
                Log.v("data \(resultString)")
#if Mundo_PRO || Approval_PRO

#else
                self.onTriggerLocalNotification(suvtitle: "joinResult", body: resultString)
#endif
            }
        }
        socket.on("message") { data, ark in
            print("Message received")
            Log.v("data \(data)")
            print(data)
        }
        
//        socket.on("currentAmount") { [self]data, ack in
//            guard let cur = data[0] as? Double else { return }
//
//            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
//                if data.first as? String ?? "passed" == SocketAckStatus.noAck.rawValue {
//                    // Handle ack timeout
//                }
//                socket.emit("update", ["amount": cur + 2.50])
//            }
//            ack.with("Got your currentAmount", "dude")
//        }
    }
    func connectStatus() -> SocketIOStatus
    {
        let socketConnectionStatus = SocketIOManager.sharedInstance.socket.status
        switch socketConnectionStatus {
        case .connected:
           print("socket connected")
        case .connecting:
           print("socket connecting")
        case .disconnected:
           print("socket disconnected")
        case .notConnected:
           print("socket not connected")
        }
        return socketConnectionStatus
    }
    func establishConnection() {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        if KeychainManager.share.getAuditToken().isEmpty != true
        {
            socket.connect()
        }
#else
        if KeychainManager.share.getToken().isEmpty != true
        {
            socket.connect()
        }
#endif
    }
     
    func closeConnection() {
        socket.disconnect()
    }
    func onTriggerLocalNotification(suvtitle:String , body:String)
    {
        let content = UNMutableNotificationContent()
        content.title = "Socket receive"
        content.subtitle = "\(suvtitle)"
        content.body = "\(body)"
//        content.badge = 1
        content.sound = UNNotificationSound.default
        
        // 設置通知的圖片
        
        let imageURL: URL = Bundle.main.url(forResource: "empty-notofications", withExtension: "png")!
        let attachment = try! UNNotificationAttachment(identifier: "image", url: imageURL, options: nil)
        content.attachments = [attachment]
        // 設置點擊通知後取得的資訊
//        content.userInfo = ["link" : "https://www.facebook.com/franksIosApp/"]
        content.userInfo = ["deeplink" : "wallet"]
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            print("成功建立通知...")
        })
    }
}
