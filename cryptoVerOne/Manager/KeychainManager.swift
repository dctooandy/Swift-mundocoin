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
        case auditReadable = "audit_readable"
        case auditEditable = "audit_editable"
        case domain = "domain"
        case addressBookList = "mundocoin_addressBook_list"
        case auditAccount = "audit_account"
        case auditAccList = "audit_acc_list"
        case auditRememberMeStatus = "audit_remember_me_status"
        case mundocoinRememberMeStatus = "mundocoin_remember_me_status"
        case mundocoinRememberMeEnable = "mundocoin_remember_me_enable"
        case mundocoinNetworkMethodEnable = "mundocoin_network_method_enable"
        case mundoCoinSelectCryptoEnable = "mundocoin_select_crypto_enable"
        case mundoCoinSioFeedbackEnable = "mundocoin_sio_feedback_enable"
        case registrationMode = "registration_Mode"
        case whiteListModeEnable = "whiteListMode_Enable"
        case faceIDModeStatus = "faceID_Mode_Status"
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
#if Approval_PRO || Approval_DEV || Approval_STAGE
        let success = self.setString(value.lowercased(), at: .auditAccount)
#else
        let success = self.setString(value.lowercased(), at: .account)
#endif
        return success
    }

    func getLastAccount(loginMode : LoginMode? = nil) -> LoginPostDto? {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        guard let accInKeychain = self.getString(from: .auditAccount) else { return nil }
#else
        guard let accInKeychain = self.getString(from: .account) else { return nil }
#endif
        let accList = getAccList()
        var accPwdString = ""
        if loginMode != nil
        {
            if loginMode == .emailPage
            {
                accPwdString = accList.filter({String($0.suffix(1)) == "/"}).last ?? ""
            }else
            {
                accPwdString = accList.filter({String($0.suffix(1)) != "/"}).last ?? ""
            }
        }else
        {
            guard let oldAccPwdString = accList.filter({$0.contains(accInKeychain)}).first else { return nil }
            accPwdString = oldAccPwdString
            
        }
        let accArr = accPwdString.components(separatedBy: "/")
        let acc = accArr[0]
        let pwd = (accArr.count > 1 ? accArr[1] : "")
        let phoneCode = (accArr.count > 2 ? accArr[2] : "")
        let phone = (accArr.count > 3 ? accArr[3] : "")
        let loginMode:LoginMode = (phone.isEmpty ? .emailPage : .phonePage)
        let showMode:ShowMode = (loginMode == .phonePage ? .loginPhone : .loginEmail)
        return LoginPostDto(account: acc,
                            password: pwd,
                            loginMode: loginMode ,
                            showMode: showMode ,
                            phoneCode: phoneCode ,
                            phone: phone)
    }
    /// 儲存帳號密碼電話 格式: acc.pwd.phoneCode.phone
    /// 遵循此格式： "acc.pwd.phoneCode.phone"
    /// - Parameters:
    ///   - acc: 帳號
    ///   - pwd: 密碼
    ///   - phoneCode: 電話區號
    ///   - phone: 電話
    func saveAccPwd(acc: String, pwd: String = "", phoneCode: String = "" , phone:String) {
        var isNewAccount = true
        let arr = getAccList()
        let acc = acc.lowercased()
        // 比對資料
        // 如果有相同就更新,沒有相同就放過
        var newArr = arr.map { (str) -> String in // update
            let accArr = str.components(separatedBy: "/")
            if accArr.contains(acc) || !accArr.last!.isEmpty && accArr.contains(phone) {
                isNewAccount = false
                let accString = acc.isEmpty ? accArr[0] : acc
                let passwordString = pwd.isEmpty ? accArr[1] : pwd
                let phoneCodeString = phoneCode.isEmpty ? accArr[2] : phoneCode
                let phoneString = phone.isEmpty ? accArr[3] : phone
                return "\(accString)/\(passwordString)/\(phoneCodeString)/\(phoneString)"
            } else {
                return str
            }
        }
        var newArrSet:Set<String> = []
        for itemString in newArr
        {
            newArrSet.insert(itemString)
        }
        newArr = Array(newArrSet)
        // 密碼如果不傳的時候,表示是舊帳號,直接回傳
        if !pwd.isEmpty
        {
            //從頭到尾都沒有出現,視為新帳號,加入keychain
            let accString = "\(acc)/\(pwd)/\(phoneCode)/\(phone)"
            if isNewAccount { // if false == new account
                newArr.append(accString)
            }
        }
        saveAccList(newArr)
    }
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
    func updateAccount(acc: String, pwd: String, phoneCode: String = "", phone:String = "") {
        var isNewAccount = true
        let arr = getAccList()
        let acc = acc.lowercased()
        var newArr = arr.map { (str) -> String in // update
            let accArr = str.components(separatedBy: "/")
            if accArr.contains(acc) || accArr.contains(phone) {
                isNewAccount = false
                return "\(acc)/\(pwd)/\(phoneCode)/\(phone)"
            } else {
                return str
            }
        }
        if isNewAccount {
            newArr.append("\(acc)/\(pwd)/\(phoneCode)/\(phone)")
        }
        saveAccList(newArr)
    }
    
    func saveAccList(_ list: [String]) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: list, requiringSecureCoding: false)
#if Approval_PRO || Approval_DEV || Approval_STAGE
            setData(data, at: .auditAccList)
#else
            setData(data, at: .accList)
#endif
        }catch{
            
        }
    }
    
    private func getAccList() -> [String] {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        guard let data = getData(from: .auditAccList) else { return [] }
#else
        guard let data = getData(from: .accList) else { return [] }
#endif
        do {
            guard let arr = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] else { return [] }
            return arr
        }
        catch{
            
        }
        return []
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
#if Approval_PRO || Approval_DEV || Approval_STAGE
        return getString(from: .auditToken) ?? ""
#else
        return getString(from: .token) ?? ""
#endif
    }
    func setToken(_ token:String){
#if Approval_PRO || Approval_DEV || Approval_STAGE
        _ = setString(token, at: .auditToken)
#else
        _ = setString(token, at: .token)
#endif
    }
    func clearToken() {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        _ = setString("", at: .auditToken)
#else
        _ = setString("", at: .token)
#endif
    }
    // 存取刪除 approval Readable
    func getReadable() -> String {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        return getString(from: .auditReadable) ?? ""
#else
        return ""
#endif
    }
    func setReadable(_ token:String){
#if Approval_PRO || Approval_DEV || Approval_STAGE
        _ = setString(token, at: .auditReadable)
#else
        
#endif
    }
    func clearReadable() {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        _ = setString("", at: .auditReadable)
#else
        
#endif
    }
    // 存取刪除 approval Editable
    func getEditable() -> String {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        return getString(from: .auditEditable) ?? ""
#else
        return ""
#endif
    }
    func setEditable(_ token:String){
#if Approval_PRO || Approval_DEV || Approval_STAGE
        _ = setString(token, at: .auditEditable)
#else
        
#endif
    }
    func clearEditable() {
#if Approval_PRO || Approval_DEV || Approval_STAGE
        _ = setString("", at: .auditEditable)
#else
        
#endif
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
    // 設定是否打開 新版Withdraw 功能
    func setMundoCoinSioFeedbackEnable(_ isOn: Bool) -> Bool {
        let success = setString(isOn == true ? "true":"false", at: .mundoCoinSioFeedbackEnable)
        return success
    }
    func getMundoCoinSioFeedbackEnable() -> Bool {
        if let modeValue = getString(from: .mundoCoinSioFeedbackEnable)
        {
            return (modeValue == "true" ? true : false)
        }
        return false
    }
    // 設定是否打開 Select Crypto View功能
    func setMundoCoinSelectCryptoEnable(_ isOn: Bool) -> Bool {
        let success = setString(isOn == true ? "true":"false", at: .mundoCoinSelectCryptoEnable)
        return success
    }
    func getMundoCoinSelectCryptoEnable() -> Bool {
        if let modeValue = getString(from: .mundoCoinSelectCryptoEnable)
        {
            return (modeValue == "true" ? true : false)
        }
        return false
    }
    // 設定是否打開 Filter NetWork Method功能
    func setMundoCoinNetworkMethodEnable(_ isOn: Bool) -> Bool {
        let success = setString(isOn == true ? "true":"false", at: .mundocoinNetworkMethodEnable)
        return success
    }
    func getMundoCoinNetworkMethodEnable() -> Bool {
        if let modeValue = getString(from: .mundocoinNetworkMethodEnable)
        {
            return (modeValue == "true" ? true : false)
        }
        return false
    }
    // 設定是否打開Remember Me功能
    func setMundoCoinRememberMeEnable(_ isOn: Bool) -> Bool {
        let success = setString(isOn == true ? "true":"false", at: .mundocoinRememberMeEnable)
        return success
    }
    func getMundoCoinRememberMeEnable() -> Bool {
        if let modeValue = getString(from: .mundocoinRememberMeEnable)
        {
            return (modeValue == "true" ? true : false)
        }
        return false
    }
    func saveMundoCoinRememberMeStatus(_ isOn :Bool )
    {
        _ = setString(isOn == true ? "true":"false", at: .mundocoinRememberMeStatus)
    }
    func getMundoCoinRememberMeStatus() -> Bool {
        return getString(from: .mundocoinRememberMeStatus) == "true" ? true:false
    }
    
    func saveAuditRememberMeStatus(_ isOn :Bool )
    {
        _ = setString(isOn == true ? "true":"false", at: .auditRememberMeStatus)
    }
    func getAuditRememberMeStatus() -> Bool {
        return getString(from: .auditRememberMeStatus) == "true" ? true:false
    }
    // 設定是否打開FaceID功能
    func setFaceIDStatus(_ isOn: Bool) -> Bool {
        let success = setString(isOn == true ? "true":"false", at: .faceIDModeStatus)
        return success
    }
    func getFaceIDStatus() -> Bool {
        if let modeValue = getString(from: .faceIDModeStatus)
        {
            return (modeValue == "true" ? true : false)
        }
        return false
    }
    // 設定是否出現邀請碼欄位
    func setRegistrationMode(_ isOn: Bool) -> Bool {
        let success = setString(isOn == true ? "true":"false", at: .registrationMode)
        return success
    }
    func getRegistrationMode() -> Bool {
        if let modeValue = getString(from: .registrationMode)
        {
#if Approval_PRO || Approval_DEV || Approval_STAGE
            return false
#else
            return (modeValue == "true" ? true : false)
#endif
        }
#if Approval_PRO || Approval_DEV || Approval_STAGE
        return false
#else
        return false
#endif
    }
    // 設定是否出現白名單功能
    func setWhiteListModeEnable(_ isOn: Bool) -> Bool {
        let success = setString(isOn == true ? "true":"false", at: .whiteListModeEnable)
        return success
    }
    func getWhiteListModeEnable() -> Bool {
        if let modeValue = getString(from: .whiteListModeEnable)
        {
#if Approval_PRO || Approval_DEV || Approval_STAGE
            return false
#else
            return (modeValue == "true" ? true : false)
#endif
        }
#if Approval_PRO || Approval_DEV || Approval_STAGE
        return false
#else
        return false
#endif
    }
    func getDefaultData() -> [CountryDetail]
    {
        guard let path = Bundle.main.path(forResource: "countries", ofType: "json") else { return CountriesDto().countries}
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let results = try decoder.decode(CountriesDto.self, from:data)
            return results.countries
        } catch {
            print(error)
            return CountriesDto().countries
        }
    }
}
