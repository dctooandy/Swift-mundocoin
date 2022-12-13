//
//  BiologicalVerifyManager.swift
//  betlead
//
//  Created by Victor on 2019/6/13.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

class BioVerifyManager {
    
    static let share = BioVerifyManager()
    
    private var logedInList = [String]() {
        didSet {
            UserDefaults.Verification.set(value: logedInList, forKey: .loged_in)
        }
    }
    
    private var bioList = [String]() {
        didSet {
            UserDefaults.Verification.set(value: bioList, forKey: .BIOList)
        }
    }
    private var auditBioList = [String]() {
        didSet {
            UserDefaults.Verification.set(value: auditBioList, forKey: .AuditBIOList)
        }
    }
    
    init() {
        self.bioList = UserDefaults.Verification.stringArray(forKey: .BIOList)
        self.auditBioList = UserDefaults.Verification.stringArray(forKey: .AuditBIOList)
        self.logedInList = UserDefaults.Verification.stringArray(forKey: .loged_in)
    }
   
    func bioVerify(_ done: @escaping (Bool, Error?) -> ())  {
        // 創建 LAContext 實例
        let context = LAContext()
        // 設置取消按鈕標題
        context.localizedCancelTitle = "Cancel"
        context.localizedFallbackTitle = "Auth ID"
        // 宣告一個變數接收 canEvaluatePolicy 返回的錯誤
        var err: NSError?
        // 評估是否可以針對給定方案進行身份驗證
        // deviceOwnerAuthentication 支援 Face ID 、 Touch ID 驗證
        // deviceOwnerAuthenticationWithBiometrics 支援 Face ID 、 Touch ID 、 裝置密碼 驗證
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) { // face id
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Enable biometric ID",
                                   reply: done)
            
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication,error: &err) { // touch id
            
            context.evaluatePolicy(.deviceOwnerAuthentication,
                                   localizedReason: "Enable Auth ID",
                                   reply: done)
        } else {
            done(false, err)
        }
    }
    
    func usedBIOVeritfy(_ acc: String) -> Bool {
        return self.bioList.contains(acc.lowercased())
    }
    func usedAuditBIOVeritfy(_ acc: String) -> Bool {
        return self.auditBioList.contains(acc.lowercased())
    }
    
    func applyMemberInBIOList(_ account: String) {
        if self.bioList.contains(account.lowercased()) != true
        {
            bioList.append(account.lowercased())
        }
        UserDefaults.Verification.set(value: bioList, forKey: .BIOList)
    }
    func applyMemberInAuditBIOList(_ account: String) {
        if self.auditBioList.contains(account.lowercased()) != true
        {
            auditBioList.append(account.lowercased())
        }
        UserDefaults.Verification.set(value: auditBioList, forKey: .AuditBIOList)
    }
    
    func removeMemberFromBIOList(_ account: String) {
        if let index = self.bioList.firstIndex(of: account.lowercased()) {
            self.bioList.remove(at: index)
        }
    }
    func removeMemberFromAuditBIOList(_ account: String) {
        if let index = self.auditBioList.firstIndex(of: account.lowercased()) {
            self.auditBioList.remove(at: index)
        }
    }
    
    func didLoginAccount(_ acc: String) -> Bool {
        //print("logedin accs: \(self.logedInList)")
        return self.logedInList.contains(acc)
    }
    
    func applyLogedinAccount(_ acc: String) {
        logedInList.append(acc)
    }
    
    func updateLogedInList(by acc: String, oldAcc: String) {
        if acc.isEmpty { return }
        if oldAcc.isEmpty { return }
        if acc == oldAcc { return }
        if !logedInList.contains(oldAcc) {
            logedInList.append(acc.lowercased())
        }
    }
    
    func bioLoginSwitchState() -> Bool {
        return UserDefaults.Verification.optionBool(forKey: .bioSwitchState) ?? true
    }
    func auditBioLoginSwitchState() -> Bool {
        return UserDefaults.Verification.optionBool(forKey: .auditBioSwitchState) ?? true
    }
    
    func setBioLoginSwitch(to isOn: Bool) {
        UserDefaults.Verification.set(value: isOn, forKey: .bioSwitchState)
    }
    
    func setAuditBioLoginSwitch(to isOn: Bool) {
        UserDefaults.Verification.set(value: isOn, forKey: .auditBioSwitchState)
    }
    func didAskBioLogin() -> Bool {
        return UserDefaults.Verification.optionBool(forKey: .askedBioLogin) ?? false
    }
    func didAskAuditBioLogin() -> Bool {
        return UserDefaults.Verification.optionBool(forKey: .askedAuditBioLogin) ?? false
    }
    func setBioLoginAskStateToTrue(_ flag : Bool = true) {
        UserDefaults.Verification.set(value: flag, forKey: .askedBioLogin)
    }
    func setAuditBioLoginAskStateToTrue(_ flag : Bool = true) {
        UserDefaults.Verification.set(value: flag, forKey: .askedAuditBioLogin)
    }
    
    /// 確認此帳號是否曾經登入
    func checkDidLoginList(acc: String, tel: String) {
        let accLogedIn = logedInList.contains(acc)
        let telLogedIn = logedInList.contains(tel)
        if accLogedIn && !telLogedIn {
            logedInList.append(tel)
        } else if !accLogedIn && telLogedIn {
            logedInList.append(acc)
        }
        
    }
    
    /// 測試用
    func testFunctionRemoveAllBioList() {
        KeychainManager.share.deleteValue(at: .account)
        self.logedInList.removeAll()
        self.bioList.removeAll()
    }
    func removeAllBioList()
    {
        self.logedInList.removeAll()
        self.bioList.removeAll()
    }
    
    func testListLog() {
        print("bio list: \(bioList)")
        print("loged in list: \(logedInList)")
    }
    
    
}
