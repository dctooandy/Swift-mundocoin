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
    let manager = SocketManager(socketURL: URL(string: BuildConfig.MUNDO_SITE_API_HOST)!, config: [.log(false), .compress])
#else
    let manager = SocketManager(socketURL: URL(string: BuildConfig.MUNDO_SITE_API_HOST )!, config: [.log(false), .compress])
#endif
    var socket : SocketIOClient!
    // MARK: -
    // MARK:Life cycle
    override init() {
        super.init()
        setup()
        
    }
    func connectPrefix()
    {
        let token = KeychainManager.share.getToken()
        // 準備好 id 資料
        var jwtValue :JWT!
        do {
            jwtValue = try decode(jwt: token)
        } catch {
            Log.socket("Socket.io - Failed to decode JWT: \(error)")
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
    }
    func setup()
    {
        connectPrefix()
        if(socket != nil)
        {
            if(socket.status == .disconnected || socket.status == .notConnected)
            {
                socket.on(clientEvent: .connect) {data, ack in
                    Log.socket("Socket.io - clientEvent connected")
                    
                    if KeychainManager.share.getToken().isEmpty != true
                    {
                        self.alreadyJoin = false
                        self.sendJoin()
                    }
                    self.socketOnEvents()
                }
                socket.on(clientEvent: .disconnect) {data, ack in
                    Log.socket("Socket.io - 接收到了 disconnect:\(data.description)")
                    self.socketOffEvents()
                }
                socket.on(clientEvent: .reconnectAttempt) {data, ack in
                    self.closeConnection()
                    self.establishConnection()
                }
                socket.on(clientEvent: .statusChange) {data, ack in
                    Log.socket("Socket.io - 接收到了 statusChange:\(data.description) ")
                }
                socket.on(clientEvent: .error) {data, ack in
                    Log.socket("Socket.io - 接收到了 error:\(data.description) ")
                }
                socket.on(clientEvent: .ping) {data, _ in
                    Log.socket("Socket.io - 接收到了 ping:\(data.description) ")
                }
                socket.on(clientEvent: .pong) {data, _ in
                    Log.socket("Socket.io - 接收到了 pong:\(data.description) ")
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
        socket.on("notification") { [self] resultData, ack in
            onTriggerLocalNotification(subtitle: "notification", body: resultData)
        }
        socket.on("joinResult") { resultData, ack in
            Log.socket("Socket.io - joinResult Success")
            // 接上 socket 封印
//            onTriggerLocalNotification(subtitle: "joinResult", body: resultData)
        }
        socket.on("echoResult") { resultData, ack in
            Log.socket("Socket.io - echoResult Success")
        }
        socket.on(self.idValue) { [self] data, ack in
            Log.socket("Socket.io - \(idValue ?? "") Success")
//            onTriggerLocalNotification(subtitle: idValue, body: data)
        }
        socket.on("message") { [self] data, ack in
            Log.socket("Socket.io - message Success\n\(data)")
            Log.socket("接收到了: json Object")
            receiveMessage(data: data)
//            self.onTriggerLocalNotification(subtitle: "message", body: data!)
        }
        
        socket.on("APPROVAL_DONE") { data, ark in
            self.onTriggerLocalNotification(subtitle: "APPROVAL_DONE", body: data)
        }
        socket.on("APPROVAL_PENDING") { data, ark in
            self.onTriggerLocalNotification(subtitle: "APPROVAL_PENDING", body: data)
        }
        socket.on("APPROVAL_PROCESSING") { data, ark in
            self.onTriggerLocalNotification(subtitle: "APPROVAL_PROCESSING", body: data)
        }
        socket.on("APPROVAL_FAILED") { data, ark in
            self.onTriggerLocalNotification(subtitle: "APPROVAL_FAILED", body: data)
        }
    }
    func connectStatus() -> SocketIOStatus
    {
        let socketConnectionStatus = SocketIOManager.sharedInstance.socket.status
        switch socketConnectionStatus {
        case .connected:
            Log.socket("Socket.io -  connected")
        case .connecting:
            Log.socket("Socket.io -  connecting")
        case .disconnected:
            Log.socket("Socket.io -  disconnected")
        case .notConnected:
            Log.socket("Socket.io -  not connected")
        }
        return socketConnectionStatus
    }
    func establishConnection() {
        if KeychainManager.share.getToken().isEmpty != true
        {
            socket.connect()
        }
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
        Log.socket("Socket.io - 發送訊息 事件 \(event) ,參數 \(para)")
        var parameters: Parameters = [String: Any]()
        parameters["roomId"] = idValue
        parameters["message"] = para
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            socket.emit(event, jsonData) {
                Log.socket("Socket.io - [\(event)] call back")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    func sendEchoEvent(event:String, para:String)
    {
        Log.socket("Socket.io - 發送訊息 事件 \(event) ,參數 \(para)")
        var parameters: Parameters = [String: Any]()
        parameters["roomId"] = idValue
        parameters[event] = para
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            socket.emit("echo", jsonData) {
                Log.socket("Socket.io - [\(event)] call back")
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
                Log.socket("Socket.io - Join call back")
                self.alreadyJoin = true
            }
        }
    }
    func joinNameSpaceWithData(body:[Any])
    {
        if let resultString = body.first as? String
        {
            Log.socket("Socket.io - receive :\(resultString)")
            if resultString.contains("join.room.first")
            {
                self.alreadyJoin = false
                self.sendJoin()
            }
        }
    }
    
    func onTriggerLocalNotification(subtitle:String , body:[Any])
    {
#if Mundo_PRO || Approval_PRO
                
#else
//        joinNameSpaceWithData(body: body)
        let content = UNMutableNotificationContent()
        content.title = "Socket receive"
        content.subtitle = "\(subtitle)"
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
            Log.socket("Socket.io - 成功建立通知...")
        })
#endif
    }

    private func receiveMessage(data: Any?) {
        
        guard let innerData = data else {return }
        Log.i("InnerData : \(innerData)")
        let jsonData = try? JSONSerialization.data(withJSONObject:innerData)
        let responseJSON = try? JSONSerialization.jsonObject(with: jsonData!, options: [])
        let firstArray = (responseJSON as? Array<Any>)?.first
        
        if let resultString = (firstArray as? String),
        let resultData = resultString.data(using: .utf8)
        {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .millisecondsSince1970
            do {
                let results = try decoder.decode(SocketMessageDto.self, from:resultData)
                Log.socket("Socket.io - result: \(results)")
                if results.type == "APPROVAL_DONE"
                {
                    self.createTypeDto(valueToFind: SocketApprovalDoneDto.self, resultData: resultData)
                }else if results.type == "APPROVAL_INIT"
                {
                    self.createTypeDto(valueToFind: SocketApprovalDoneDto.self, resultData: resultData)
                }else if results.type == "TX_CALLBACK"
                {
                    self.createTypeDto(valueToFind: SocketTxCallBackDto.self, resultData: resultData)
                }else
                {
                    self.onTriggerLocalNotification(subtitle: "Message", body: [resultData])
                }
            } catch DecodingError.dataCorrupted( _) {
                Log.e("Socket.io -dataCorrupted")
            } catch DecodingError.keyNotFound( _,  _) {
                Log.e("Socket.io -keyNotFound")
            } catch DecodingError.typeMismatch( _, let context) {
                Log.e("Socket.io -typeMismatch : \(context)")
            } catch DecodingError.valueNotFound( _,  _) {
                Log.e("Socket.io -valueNotFound")
            } catch {
                Log.e(error.localizedDescription)
            }
        }else
        {
            Log.e("Socket.io -回傳Null ,innerData: \(innerData)")
        }
    }
    func createTypeDto<T : Codable>(valueToFind: T.Type, resultData: Data)
    {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsSince1970
        do {
            let resultsPayloadDto = try decoder.decode(T.self , from:resultData)
            if let resultsPayload = resultsPayloadDto as? SocketApprovalDoneDto
            {
                if let chainData = resultsPayload.payload.chain,
                   let currentChain = chainData.filter({(!$0.state.isEmpty)}).first,
                   let userData = resultsPayload.payload.issuer
                {
                    let bodyArray = ["\(currentChain.state)","\(currentChain.memo)"]
                    self.onTriggerLocalNotification(subtitle: userData.email, body: bodyArray)
#if Approval_PRO || Approval_DEV || Approval_STAGE
                    _ = AuditApprovalDto.pendingUpdate() // 更新清單列表
                    _ = AuditApprovalDto.finishUpdate() // 更新清單列表
#else

#endif
                }
            }else if let resultsPayload = resultsPayloadDto as? SocketTxCallBackDto
            {
                let txDto = resultsPayload.payload
                if let statsValue = txDto.state,
                   let typeValue = txDto.type,
                   let amountValue = txDto.txAmountIntWithDecimal?.stringValue,
                   let cryptotype = txDto.currency
                {
                    if statsValue == "COMPLETE"
                    {
                        var titleString = ""
                        var bodyString = ""
                        
                        if typeValue == "WITHDRAW"
                        {
                            titleString = "Withdraw Succesful"
                            bodyString = "You have withdrawn \(amountValue) \(cryptotype) at \(txDto.updatedDateString) (UTC)."
                             
                        }else
                        {
                            titleString = "Deposit Succesful"
                            bodyString = "You have deposited \(amountValue) \(cryptotype) at \(txDto.updatedDateString) (UTC)."
                        }
                        
                        self.onTriggerLocalNotification(subtitle: titleString, body: [bodyString])
                    }
#if Approval_PRO || Approval_DEV || Approval_STAGE
                    
#else
                    TXPayloadDto.share = txDto
#endif
                }
            }
        }catch{
            
        }
    }
}
