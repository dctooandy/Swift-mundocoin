//
//  KeychainManager.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import KeychainSwift

class KeychainManager {
    
    enum KeychainKey: String {
        case fingerID = "finger_id"
        case account = "mundocoin_account"
        case accList = "mundocoin_acc_list"
        case whiteListOnoff = "mundocoin_whiteListOnoff_list"
        case token = "bead_token"
        case domain = "domain"
    }
    
    static let share = KeychainManager()
    
    private func setString(_ value: String, at type: KeychainKey) -> Bool {
        return KeychainSwift().set(value, forKey: type.rawValue)
    }
    @discardableResult
    private func setData(_ value: Data, at type: KeychainKey) -> Bool {
        return KeychainSwift().set(value, forKey: type.rawValue)
    }
    
    private func getString(from type: KeychainKey) -> String? {
        return KeychainSwift().get(type.rawValue)
    }
    
    private func getData(from type: KeychainKey) -> Data? {
        return KeychainSwift().getData(type.rawValue)
    }
    
    func deleteValue(at type: KeychainKey) {
        KeychainSwift().delete(type.rawValue)
    }
    
    /// 儲存帳號到keychain
    ///
    /// - Parameter value: 帳號
    @discardableResult
    func setLastAccount(_ value: String) -> Bool {
        let success = self.setString(value.lowercased(), at: .account)
        return success
    }
    
    func getLastAccount() -> LoginPostDto? {
        guard let accInKeychain = self.getString(from: .account) else { return nil }
        let accList = getAccList()
        guard let accPwdString = accList.filter({$0.contains(accInKeychain)}).first else { return nil }
        let accArr = accPwdString.components(separatedBy: "/")
        let acc = accArr[0]
        let pwd = accArr[1]
        let tel = accArr[2]
        return LoginPostDto(account: acc.isEmpty ? tel : acc,
                            password: pwd,
                            loginMode: .emailPage ,
                            showMode: .loginEmail)
    }
    
    /// 儲存帳號密碼電話 格式: acc.pwd.tel
    /// 遵循此格式： "acc.pwd.tel"
    /// - Parameters:
    ///   - acc: 帳號
    ///   - pwd: 密碼
    ///   - tel: 電話
    func saveAccPwd(acc: String, pwd: String, tel: String) {
        let acc = acc.lowercased()
        let arr = getAccList()
        var isNewAccount = true
//        print("save acc list: \(arr)")
        var newArr = arr.map { (str) -> String in // update
            let accArr = str.components(separatedBy: "/")
            if accArr.contains(acc) || !accArr.last!.isEmpty && accArr.contains(tel) {
                isNewAccount = false
                let finalAcc = acc.isEmpty ? accArr[0] : acc
                let finalTel = tel.isEmpty ? accArr[2] : tel
                let finalPwd = pwd.isEmpty ? accArr[1] : pwd
//                print("old acc: \(acc).\(accArr[1]).\(tel)\nnew acc: \(finalAcc).\(finalPwd).\(finalTel)")
                return "\(finalAcc)/\(finalPwd)/\(finalTel)"
            
            } else {
                return str
            }
        }
        
        let accString = "\(acc)/\(pwd)/\(tel)"
//        print("save acc string: \(accString) , isnew: \(isNewAccount)")
        if isNewAccount { // if false == new account
            newArr.append(accString)
        }
//        print("save acc new final array: \(newArr)")
        saveAccList(newArr)
    }
    
    func updateAccount(acc: String, pwd: String) {
        var isNewAccount = true
        let arr = getAccList()
        let acc = acc.lowercased()
        var newArr = arr.map { (str) -> String in // update
            let accArr = str.components(separatedBy: "/")
            if accArr.contains(acc) {
                isNewAccount = false
                let phone = accArr[2]
                return "\(acc)/\(pwd)/\(phone)"
            } else {
                return str
            }
        }
        if isNewAccount {
            newArr.append("\(acc)/\(pwd)/")
        }
        saveAccList(newArr)
    }
    
    func saveAccList(_ list: [String]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: list)
        setData(data, at: .accList)
    }
    
    
    private func getAccList() -> [String] {
        guard let data = getData(from: .accList) else { return [] }
        guard let arr = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String] else { return [] }
        return arr
    }
    
    func accountExist(_ acc: String) -> Bool {
        var isExist = false
        for accInfo in getAccList() {
           isExist = (accInfo.hasPrefix(acc) && !accInfo.components(separatedBy: ".")[1].isEmpty)
            if isExist { return true }
        }
        return isExist
    }
    
    func getFingerID() -> String? {
        
        if let fingerID = getString(from: .fingerID) {
            return fingerID
        } else {
            let uuid = UUID().uuidString
            if setString(uuid, at: .fingerID) {
                //print("save fingerID: \(uuid)")
                return uuid
            } else {
                print("create fingerID fail.")
                return nil
            }
        }
    }
    func setDomainMode(_ value: DomainMode) -> Bool {
        let success = self.setString(value.rawValue, at: .domain)
        return success
    }
    func getDomainMode() -> DomainMode {
        if let domain = getString(from: .domain)
        {
            return DomainMode.init(rawValue: domain) ?? .Dev
        }
        return .Dev
    }

    func getToken() -> String {
        return getString(from: .token) ?? ""
    }
    func setToken(_ token:String){
        _ = setString(token, at: .token)
    }
    func clearToken() {
       _ = setString("", at: .token)
    }
    
    func saveWhiteListOnOff(_ isOn :Bool ) {
        
        _ = setString(isOn == true ? "true":"false", at: .whiteListOnoff)
    }
    func getWhiteListOnOff() -> Bool {
        return getString(from: .whiteListOnoff) == "true" ? true:false
    }
}
