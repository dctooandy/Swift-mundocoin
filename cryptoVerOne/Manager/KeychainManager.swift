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
        case token = "mundocoin_token"
        case auditToken = "audit_token"
        case domain = "domain"
        case addressBookList = "mundocoin_addressBook_list"
        case auditAccount = "audit_account"
        case auditAccList = "audit_acc_list"
        case auditRememberMeStatus = "audit_remember_me_status"
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
    func setLastAuditAccount(_ value: String) -> Bool {
        let success = self.setString(value.lowercased(), at: .auditAccount)
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
    func getLastAuditAccount() -> LoginPostDto? {
        guard let accInKeychain = self.getString(from: .auditAccount) else { return nil }
        let accList = getAuditAccList()
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
        var newArr = arr.map { (str) -> String in // update
            let accArr = str.components(separatedBy: "/")
            if accArr.contains(acc) || !accArr.last!.isEmpty && accArr.contains(tel) {
                isNewAccount = false
                let finalAcc = acc.isEmpty ? accArr[0] : acc
                let finalTel = tel.isEmpty ? accArr[2] : tel
                let finalPwd = pwd.isEmpty ? accArr[1] : pwd
                return "\(finalAcc)/\(finalPwd)/\(finalTel)"
            
            } else {
                return str
            }
        }
        
        let accString = "\(acc)/\(pwd)/\(tel)"
        if isNewAccount { // if false == new account
            newArr.append(accString)
        }
        saveAccList(newArr)
    }
    func saveAuditAccPwd(acc: String, pwd: String, tel: String) {
        let acc = acc.lowercased()
        let arr = getAuditAccList()
        var isNewAccount = true
        var newArr = arr.map { (str) -> String in // update
            let accArr = str.components(separatedBy: "/")
            if accArr.contains(acc) || !accArr.last!.isEmpty && accArr.contains(tel) {
                isNewAccount = false
                let finalAcc = acc.isEmpty ? accArr[0] : acc
                let finalTel = tel.isEmpty ? accArr[2] : tel
                let finalPwd = pwd.isEmpty ? accArr[1] : pwd
                return "\(finalAcc)/\(finalPwd)/\(finalTel)"
            
            } else {
                return str
            }
        }
        
        let accString = "\(acc)/\(pwd)/\(tel)"
        if isNewAccount { // if false == new account
            newArr.append(accString)
        }
        saveAuditAccList(newArr)
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
    func updateAuditAccount(acc: String, pwd: String) {
        var isNewAccount = true
        let arr = getAuditAccList()
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
        saveAuditAccList(newArr)
    }
    
    func saveAccList(_ list: [String]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: list)
        setData(data, at: .accList)
    }
    func saveAuditAccList(_ list: [String]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: list)
        setData(data, at: .auditAccList)
    }
    
    
    private func getAccList() -> [String] {
        guard let data = getData(from: .accList) else { return [] }
        guard let arr = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String] else { return [] }
        return arr
    }
    
    private func getAuditAccList() -> [String] {
        guard let data = getData(from: .auditAccList) else { return [] }
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
    func auditAccountExist(_ acc: String) -> Bool {
        var isExist = false
        for accInfo in getAuditAccList() {
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
#if Approval_PRO || Approval_DEV || Approval_STAGE
            return DomainMode.init(rawValue: domain) ?? .AuditStage
#else
            return DomainMode.init(rawValue: domain) ?? .Stage
#endif
        }
#if Approval_PRO || Approval_DEV || Approval_STAGE
        return .AuditStage
#else
        return .Stage
#endif
    }
    // 存取刪除 mundocoin token
    func getToken() -> String {
        return getString(from: .token) ?? ""
    }
    func setToken(_ token:String){
        _ = setString(token, at: .token)
    }
    func clearToken() {
       _ = setString("", at: .token)
    }
    // 存取刪除 audit token
    func getAuditToken() -> String {
        return getString(from: .auditToken) ?? ""
    }
    func setAuditToken(_ token:String){
        _ = setString(token, at: .auditToken)
    }
    func clearAuditToken() {
       _ = setString("", at: .auditToken)
    }

    // 存取白名單狀態
    func saveWhiteListOnOff(_ isOn :Bool ) {
        _ = setString(isOn == true ? "true":"false", at: .whiteListOnoff)
    }
    func getWhiteListOnOff() -> Bool {
        return getString(from: .whiteListOnoff) == "true" ? true:false
    }
    // 存取AddressBooks
    func deleteAddressbook(_ book: AddressBookDto )-> Bool{
        var addressBooks = getAddressBookList()
        let target = addressBooks.filter{ $0.name == book.name && $0.address == book.address && $0.network == book.network }.first! as AddressBookDto
        let targetIndex = addressBooks.indexOfObject(object: target)
        addressBooks.remove(at: targetIndex)
        if KeychainManager.share.saveAddressBookList(addressBooks) == true
        {
            return true
        }else
        {
            return false
        }
    }
    func updateAddressbook(_ book: AddressBookDto )-> Bool{
        var addressBooks = getAddressBookList()
        let target = addressBooks.filter{ $0.name == book.name && $0.address == book.address && $0.network == book.network }.first! as AddressBookDto
        let targetIndex = addressBooks.indexOfObject(object: target)
        addressBooks.remove(at: targetIndex)
        addressBooks.insert(book, at: targetIndex)
        if KeychainManager.share.saveAddressBookList(addressBooks) == true
        {
            return true
        }else
        {
            return false
        }
    }
    func saveAddressbook(_ book: AddressBookDto )-> Bool{
        var addressBooks = getAddressBookList()
        addressBooks.append(book)
        if KeychainManager.share.saveAddressBookList(addressBooks) == true
        {
            return true
        }else
        {
            return false
        }
    }
    func saveAddressBookList(_ list: [AddressBookDto] )-> Bool {
        let encoder = JSONEncoder()
        var success = false
        if let encoded = try? encoder.encode(list) {
            if let json = String(data: encoded, encoding: .utf8) {
                print(json)
                success = setString(json, at: .addressBookList)
            }
        }
        return success
    }
    func getAddressBookList() -> [AddressBookDto] {
        guard let data = getString(from: .addressBookList) else { return [] }
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([AddressBookDto].self, from: data.data(using: .utf8)!) {
            return decoded
        }else
        {
            return []
        }
    }
    func saveAuditRememberMeStatus(_ isOn :Bool )
    {
        _ = setString(isOn == true ? "true":"false", at: .auditRememberMeStatus)
    }
    func getAuditRememberMeStatus() -> Bool {
        return getString(from: .auditRememberMeStatus) == "true" ? true:false
    }
}
