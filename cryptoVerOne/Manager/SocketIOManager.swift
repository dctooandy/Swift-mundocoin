//
//  SocketIOManager.swift
//  cryptoVerOne
//
//  Created by BBk on 6/10/22.
//
import SocketIO
import Foundation
import JWTDecode
import Alamofire
class SocketIOManager: NSObject {
    // MARK:業務設定
    static let sharedInstance = SocketIOManager()
    var idValue:String!
    var alreadyJoin:Bool = false
#if Approval_PRO || Approval_DEV || Approval_STAGE
    let manager = SocketManager(socketURL: URL(string: BuildConfig.MUNDO_SITE_API_HOST)!, config: [.log(true), .compress])
#else
    let manager = SocketManager(socketURL: URL(string: BuildConfig.MUNDO_SITE_API_HOST )!, config: [.log(true), .compress])
#endif
    var socket : SocketIOClient!
    // MARK: -
    // MARK:Life cycle
    override init() {
        super.init()
        setup()
        
    }
    func setup()
    {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        let token = KeychainManager.share.getAuditToken()
#else
        let token = KeychainManager.share.getToken()
#endif
        // 準備好 id 資料
        var jwtValue :JWT!
        do {
            jwtValue = try decode(jwt: token)
        } catch {
            Log.v("Socket.io - Failed to decode JWT: \(error)")
            idValue = "123"
        }
        if jwtValue != nil , let idString = jwtValue.body["Id"] as? String
        {
            idValue = idString
        }
        // 準備好發射 manager header
        self.manager.config = SocketIOClientConfiguration(arrayLiteral: .connectParams(["Authorization": "Bearer \(token)"]), .secure(true)
        )
        // 掛鉤 NameSpace
        socket = manager.socket(forNamespace: "/notification")
//        socket.joinNamespace()
        if(socket != nil)
        {
            if(socket.status == .disconnected || socket.status == .notConnected)
            {
                socket.on(clientEvent: .disconnect) {data, ack in
                    Log.v("Socket.io - 接收到了 disconnect:\(data.description) )")
                    self.socketOffEvents()
                }
                socket.on(clientEvent: .connect) {data, ack in
                    Log.v("Socket.io - clientEvent connected")
                    
                    #if Approval_PRO || Approval_DEV || Approval_STAGE
                    if !KeychainManager.share.getAuditToken().isEmpty
                    {
//                        self.socket.joinNamespace()
                        self.alreadyJoin = false
                        self.sendJoin()
                    }
                    #else
                    if KeychainManager.share.getToken().isEmpty != true
                    {
//                        self.socket.joinNamespace()
                        self.alreadyJoin = false
                        self.sendJoin()
                    }
                    #endif
                    self.socketOnEvents()
                }
            }
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
        socket?.onAny { (data) in
            if data.event == "reconnectAttempt" {
                self.closeConnection()
                self.establishConnection()
            }
        }
    }
    func socketOffEvents()
    {
        socket.off("notification")
        socket.off("joinResult")
        socket.off("echoResult")
        socket.off(self.idValue)
        socket.off("message")
        socket.off("APPROVAL_DONE")
        socket.off("APPROVAL_PENDING")
        socket.off("APPROVAL_PROCESSING")
        socket.off("APPROVAL_FAILED")
    }
    func socketOnEvents()
    {
        socket.on("notification") { resultData, ack in
            self.onTriggerLocalNotification(suvtitle: "notification", body: resultData)
        }
        socket.on("joinResult") { resultData, ack in
            Log.v("Socket.io - joinResult Success")
            self.onTriggerLocalNotification(suvtitle: "joinResult", body: resultData)
        }
        socket.on("echoResult") { resultData, ack in
            Log.v("Socket.io - echoResult Success")
//            self.joinNameSpaceWithData(body: resultData)
//                    self.onTriggerLocalNotification(suvtitle: "echoResult", body: resultData)
        }
        socket.on(self.idValue) { [self] data, ack in
            Log.v("Socket.io - \(self.idValue) Success")
            self.onTriggerLocalNotification(suvtitle: self.idValue, body: data)
        }
        socket.on("message") { data, ark in
            Log.v("Socket.io - message Success")
            self.onTriggerLocalNotification(suvtitle: "message", body: data)
        }
        
        socket.on("APPROVAL_DONE") { data, ark in
            self.onTriggerLocalNotification(suvtitle: "APPROVAL_DONE", body: data)
        }
        socket.on("APPROVAL_PENDING") { data, ark in
            self.onTriggerLocalNotification(suvtitle: "APPROVAL_PENDING", body: data)
        }
        socket.on("APPROVAL_PROCESSING") { data, ark in
            self.onTriggerLocalNotification(suvtitle: "APPROVAL_PROCESSING", body: data)
        }
        socket.on("APPROVAL_FAILED") { data, ark in
            self.onTriggerLocalNotification(suvtitle: "APPROVAL_FAILED", body: data)
        }
    }
    func connectStatus() -> SocketIOStatus
    {
        let socketConnectionStatus = SocketIOManager.sharedInstance.socket.status
        switch socketConnectionStatus {
        case .connected:
            Log.v("Socket.io -  connected")
        case .connecting:
            Log.v("Socket.io -  connecting")
        case .disconnected:
            Log.v("Socket.io -  disconnected")
        case .notConnected:
            Log.v("Socket.io -  not connected")
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
        socket.leaveNamespace()
    }
    func reConnection() {
        self.manager.reconnect()
    }
}
extension SocketIOManager
{
    func sendMessage(event:String, para:String)
    {
        Log.v("Socket.io - 發送訊息 事件 \(event) ,參數 \(para)")
        var parameters: Parameters = [String: Any]()
        parameters["roomId"] = idValue
        parameters["message"] = para
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            socket.emit(event, jsonData) {
                Log.v("Socket.io - [\(event)] call back")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    func sendEchoEvent(event:String, para:String)
    {
        Log.v("Socket.io - 發送訊息 事件 \(event) ,參數 \(para)")
        var parameters: Parameters = [String: Any]()
        parameters["roomId"] = idValue
        parameters[event] = para
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            socket.emit("echo", jsonData) {
                Log.v("Socket.io - [\(event)] call back")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    func sendJoin()
    {
        if alreadyJoin == false
        {
            self.socket.emit("join", self.idValue) {
                Log.v("Socket.io - Join call back")
                self.alreadyJoin = true
            }
        }
    }
    func joinNameSpaceWithData(body:[Any])
    {
        if let resultString = body.first as? String
        {
            Log.v("Socket.io - receive :\(resultString)")
            if resultString.contains("join.room.first")
            {
                self.alreadyJoin = false
                self.sendJoin()
            }
        }
    }
    
    func onTriggerLocalNotification(suvtitle:String , body:[Any])
    {
#if Mundo_PRO || Approval_PRO
                
#else
//        joinNameSpaceWithData(body: body)
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
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            Log.v("Socket.io - 成功建立通知...")
        })
#endif
    }
}
