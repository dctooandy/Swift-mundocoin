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
    let manager = SocketManager(socketURL: URL(string: "https://dev.api.mundocoin.com:443")!, config: [.log(true), .compress])
    var socket : SocketIOClient!
//    var socket: SocketIOClient = SocketIOClient(socketURL:  ,nsp: "")
    
    override init() {
        super.init()
        setup()
        bind()
    }
    func setup()
    {
        let token = KeychainManager.share.getToken()        
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
        socket.on("joinResult") { data, ack in
            Log.v("data \(data)")
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
        if KeychainManager.share.getToken().isEmpty != true
        {
            socket.connect()            
        }
    }
     
    func closeConnection() {
        socket.disconnect()
    }
}
