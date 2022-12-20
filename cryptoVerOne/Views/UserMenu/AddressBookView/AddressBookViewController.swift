//
//  AddressBookViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 5/31/22.
//

import Foundation
import RxCocoa
import RxSwift
import DropDown
import UIKit
import Alamofire

class AddressBookViewController: BaseViewController {
    // MARK:業務設定
    var viewModel = AddressBookViewModel()
    private let onClick = PublishSubject<Any>()
//    private let dpg = DisposeBag()
    private var cellDpg = DisposeBag()
    var sheetDpg = DisposeBag()
    var addresBookDtos : [AddressBookDto] = []
    var twoWayVC = SecurityVerificationViewController.loadNib()
    var isShowSecurityVC : Bool = false
    // MARK: -
    // MARK:UI 設定

    @IBOutlet weak var customDrowDownView: DropDownStyleView!
    @IBOutlet weak var tableView: UITableView!
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    private lazy var whiteListButton:UIButton = {
        let backToButton = UIButton(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
        let image = UIImage(named:"icon-Chield_check2")
        backToButton.setImage(image, for: .normal)
        backToButton.addTarget(self, action:#selector(whiteListAction), for:.touchUpInside)
        return backToButton
    }()
    private lazy var addAddressBookButton:UIButton = {
        let backToButton = UIButton(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
        let image = UIImage(named:"icon-math-plus")
        backToButton.setImage(image, for: .normal)
        backToButton.addTarget(self, action:#selector(addAddressBookAction), for:.touchUpInside)
        return backToButton
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Address book".localized
        setupUI()
        bindUI()
        bindViewModel()
        setLongPressGesture()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cellDpg = DisposeBag()
        isShowSecurityVC = false
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
        fetchDatas()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setEditing(false, animated: true)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        let rightBarItems = [UIBarButtonItem(customView: addAddressBookButton),UIBarButtonItem(customView: whiteListButton)]
        self.navigationItem.rightBarButtonItems = rightBarItems
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: AddressBookViewCell.self)
        tableView.separatorStyle = .none
        // 暫時打開
//        customDrowDownView.config(showDropdown: true, dropDataSource: ["USDT","USD"])
        customDrowDownView.config(showDropdown: false, dropDataSource: ["USDT"])
        customDrowDownView.topLabel.font = Fonts.PlusJakartaSansBold(20.8)
    }
    func bindUI()
    {
        WhiteListThemes.topWhiteListImageIconType.bind(to: whiteListButton.rx.image(for: .normal)).disposed(by: disposeBag)
        let style: WhiteListStyle = KeychainManager.share.getWhiteListOnOff() ? .whiteListOn:.whiteListOff
        WhiteListThemes.share.acceptWhiteListTopImageStyle(style)
    }
    func bindViewModel()
    {
        viewModel.rxFetchSuccess().subscribeSuccess { dtos in
            Log.v("取得地址簿")
            self.addresBookDtos = dtos
            self.tableView.reloadData()
        }.disposed(by: disposeBag)
    }
    func setLongPressGesture()
    {
        // 0927 刪除交互修改
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
    }
    func fetchDatas()
    {
        viewModel.fetchAddressBooks()
    }
    @objc func whiteListAction() {
        Log.i("開啟白名單警告Sheet")
        sheetDpg = DisposeBag()
        let whiteListBottomSheet = WhiteListBottomSheet()
        whiteListBottomSheet.rxChangeWhiteListMode().subscribeSuccess { [self] _ in
            if let type = MemberAccountDto.share?.withdrawWhitelistSecurityType
            {
                twoWayVC.securityViewMode = type
                twoWayVC.rxVerifySuccessClick().subscribeSuccess { [self] data in
                    verifySuccessForChangeWhiteList(code: data.0,withMode: data.1, done: {
                        self.twoWayVC.navigationController?.popViewController(animated: true)
                    })
                }.disposed(by: sheetDpg)
                if KeychainManager.share.getMundoCoinTwoWaySecurityEnable() == false
                {
                    twoWayVC.rxSelectedModeSuccessClick().subscribeSuccess { [self](stringData) in
                        verifySuccessForChangeWhiteList(code: stringData.0,withMode: stringData.1, done: {
                            self.twoWayVC.navigationController?.popViewController(animated: true)
                        })
                    }.disposed(by: sheetDpg)
                }
                self.navigationController?.pushViewController(twoWayVC, animated: true)
            }
        }.disposed(by: sheetDpg)
        DispatchQueue.main.async {
            whiteListBottomSheet.start(viewController: self ,height: 283)
        }
    }
    func verifySuccessForChangeWhiteList(code:String, withMode:String = "",done: @escaping () -> Void)
    {
        var codePara : [Parameters] = []
        if KeychainManager.share.getMundoCoinTwoWaySecurityEnable() == false, withMode != ""
        {
            let emailString = MemberAccountDto.share?.email ?? ""
            let phoneString = MemberAccountDto.share?.phone ?? ""
            let idString = (withMode == "onlyEmail" ? emailString : phoneString)
            var parameters: Parameters = [String: Any]()
            parameters = ["id":idString,
                          "code":code]
            codePara.append(parameters)
        }else
        {
            if let accountArray = MemberAccountDto.share?.withdrawWhitelistAccountArray ,
               accountArray.first != nil
            {
                var parameters: Parameters = [String: Any]()
                parameters["id"] = accountArray.first ?? ""
                parameters["code"] = code
                codePara.append(parameters)
                if !withMode.isEmpty , accountArray.last != nil
                {
                    var parameters: Parameters = [String: Any]()
                    parameters["id"] = accountArray.last ?? ""
                    parameters["code"] = withMode
                    codePara.append(parameters)
                }
            }
        }
        let isOn = KeychainManager.share.getWhiteListOnOff()
        Beans.addressBookServer.enableAddressBookWhiteList(enabled: !isOn, verificationCodes:codePara ).subscribe { _ in
            KeychainManager.share.saveWhiteListOnOff(!isOn)
            WhiteListThemes.share.acceptWhiteListTopImageStyle(!isOn == true ? .whiteListOn : .whiteListOff)
            done()
        } onError: { [self] error in
            if let error = error as? ApiServiceError
            {
                switch error {
                case .errorDto(let dto):
                    let status = dto.httpStatus ?? ""
                    let reason = dto.reason
                    let emailMessage = "The Email Code is incorrect. Please re-enter."
                    let mobileMessage = "The Mobile Code is incorrect. Please re-enter."
                    if status == "400"
                    {
                        if reason == "CODE_MISMATCH"
                        {
                            Log.i("驗證碼錯誤 :\(reason)")
                            if twoWayVC.securityViewMode == .onlyEmail
                            {
                                twoWayVC.twoWayVerifyView.emailInputView.invalidLabel.isHidden = false
                                twoWayVC.twoWayVerifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: emailMessage)
                            }else if twoWayVC.securityViewMode == .onlyMobile
                            {
                                twoWayVC.twoWayVerifyView.mobileInputView.invalidLabel.isHidden = false
                                twoWayVC.twoWayVerifyView.mobileInputView.changeInvalidLabelAndMaskBorderColor(with: mobileMessage)
                            }else if twoWayVC.securityViewMode == .selectedMode
                            {
                                if withMode == "onlyEmail" , let emailVC = twoWayVC.twoWayViewControllers.first
                                {
                                    emailVC.verifyView.emailInputView.invalidLabel.isHidden = false
                                    emailVC.verifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: emailMessage)
                                }else if withMode == "onlyMobile" , let mobileVC = twoWayVC.twoWayViewControllers.last
                                {
                                    mobileVC.verifyView.mobileInputView.invalidLabel.isHidden = false
                                    mobileVC.verifyView.mobileInputView.changeInvalidLabelAndMaskBorderColor(with: mobileMessage)
                                }
                            }else if twoWayVC.securityViewMode == .defaultMode
                            {
                                if twoWayVC.twoWayVerifyView.twoWayViewMode == .both
                                {
                                    ErrorHandler.show(error: error)
                                }
                            }
                        }else
                        {
                            ErrorHandler.show(error: error)
                        }
                    }else
                    {
                        ErrorHandler.show(error: error)
                    }
                default:
                    ErrorHandler.show(error: error)
                }
            }
        }.disposed(by: disposeBag)

       
    }
    @objc func addAddressBookAction() {
        Log.i("增加錢包地址")
        let addVC = AddNewAddressViewController.loadNib()
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    func showAlert(indexpath:IndexPath)
    {
        let popVC =  ConfirmPopupView(viewHeight: 176,
                                      iconMode: .nonIcon(["Cancel".localized,"Confirm".localized]),
                                      title: "",
                                      message: "Are you sure you want to delete this address?") { [self] isOK in

            if isOK {
                Log.i("刪除此行 \(indexpath)")
                let addressData = addresBookDtos[indexpath.item]
                Beans.addressBookServer.deleteAddressBookStatus(addressBookID: addressData.id).subscribeSuccess { [self] _ in
                    _ = AddressBookListDto.update { [self] in
                        addresBookDtos = KeychainManager.share.getAddressBookList()
                        tableView.deleteRows(at: [indexpath], with: .fade)
                    }
                }.disposed(by: disposeBag)

            }else
            {
                Log.i("不刪除")
            }
        }
        popVC.start(viewController: self)
    }
    func toSecurityByType(data:AddressBookDto)
    {
        if isShowSecurityVC == false
        {
            if let type = MemberAccountDto.share?.withdrawWhitelistSecurityType
            {
                twoWayVC.securityViewMode = type
                twoWayVC.rxVerifySuccessClick().subscribeSuccess { [self] (codeData) in
                    Log.i("返回Security並打API")
                    // 需要填入修改白名單API
                    changeCellWhiteListType(addressData: data , code: codeData.0,withMode: codeData.1, done: { isOnValue in
                        if codeData.0 != "" // 如果codeData.0 不是 "" ,即為開啟,會帶驗證碼
                        {
                            self.twoWayVC.navigationController?.popViewController(animated: true)
                        }
                        _ = AddressBookListDto.update { [self] in
                            addresBookDtos = KeychainManager.share.getAddressBookList()
                            cellDpg = DisposeBag()
                            tableView.reloadData()
                        }
                    })
                }.disposed(by: disposeBag)
                if KeychainManager.share.getMundoCoinTwoWaySecurityEnable() == false
                {
                    twoWayVC.rxSelectedModeSuccessClick().subscribeSuccess { [self](stringData) in
                        Log.i("返回Security並打API")
                        // 需要填入修改白名單API
                        changeCellWhiteListType(addressData: data , code: stringData.0,withMode: stringData.1, done: { isOnValue in
                            if isOnValue == true
                            {
                                if stringData.0 != "" // 如果codeData.0 不是 "" ,即為開啟,會帶驗證碼
                                {
                                    self.twoWayVC.navigationController?.popViewController(animated: true)
                                }
                            }
                            _ = AddressBookListDto.update { [self] in
                                addresBookDtos = KeychainManager.share.getAddressBookList()
                                cellDpg = DisposeBag()
                                tableView.reloadData()
                            }
                        })
                    }.disposed(by: sheetDpg)
                }
                isShowSecurityVC = true
                self.navigationController?.pushViewController(twoWayVC, animated: true)
            }
        }else
        {
//            isShowSecurityVC = false
        }
    }
    func changeCellWhiteListType(addressData:AddressBookDto , code:String = "" , withMode:String = "",done: @escaping (Bool) -> Void)
    {
        var codePara : [Parameters] = []
        if KeychainManager.share.getMundoCoinTwoWaySecurityEnable() == false, withMode != ""
        {
            if addressData.enabled == true
            {
                let emailString = MemberAccountDto.share?.email ?? ""
                let phoneString = MemberAccountDto.share?.phone ?? ""
                let idString = (withMode == "onlyEmail" ? emailString : phoneString)
                var parameters: Parameters = [String: Any]()
                parameters = ["id":idString,
                              "code":code]
                codePara.append(parameters)
            }
        }else
        {
            if let accountArray = MemberAccountDto.share?.withdrawWhitelistAccountArray ,
               accountArray.first != nil , addressData.enabled == true
            {
                var parameters: Parameters = [String: Any]()
                parameters["id"] = accountArray.first ?? ""
                parameters["code"] = code
                codePara.append(parameters)
                if !withMode.isEmpty , accountArray.last != nil
                {
                    var parameters: Parameters = [String: Any]()
                    parameters["id"] = accountArray.last ?? ""
                    parameters["code"] = withMode
                    codePara.append(parameters)
                }
            }
        }
        Beans.addressBookServer.updateAddressBookStatus(addressBookID: addressData.id , enabled: addressData.enabled , verificationCodes: codePara).subscribe { _ in
            done(true)
        } onError: { [self] error in
            if let error = error as? ApiServiceError
            {
                switch error {
                case .errorDto(let dto):
                    let status = dto.httpStatus ?? ""
                    let reason = dto.reason
                    let emailMessage = "The Email Code is incorrect. Please re-enter."
                    let mobileMessage = "The Mobile Code is incorrect. Please re-enter."
                    var redBorderMessage = ""
                    done(false)
                    if status == "400"
                    {
                        if reason == "CODE_MISMATCH"
                        {
                            Log.i("驗證碼錯誤 :\(reason)")
                            var showAlert = true
                            if twoWayVC.securityViewMode == .onlyEmail
                            {
                                redBorderMessage = emailMessage
                            }else if twoWayVC.securityViewMode == .onlyMobile
                            {
                                redBorderMessage = mobileMessage
                            }else if twoWayVC.securityViewMode == .selectedMode
                            {
                                if withMode == "onlyEmail"
                                {
                                    redBorderMessage = emailMessage
                                }else if withMode == "onlyMobile"
                                {
                                    redBorderMessage = mobileMessage
                                }
                            }else if twoWayVC.securityViewMode == .defaultMode
                            {
                                if twoWayVC.twoWayVerifyView.twoWayViewMode == .both
                                {
                                    showAlert = false
                                    ErrorHandler.show(error: error)
                                }
                            }
                            if showAlert == true
                            {
                                showRedMessage(redBorderMessage: redBorderMessage ,withMode:withMode)
                            }
                        }else if reason == "PARAMETER_INVALID"
                        {
                            Log.i("參數錯誤 :\(reason)")
                            let results = ErrorDefaultDto(code: dto.code, reason: reason, timestamp: 0, httpStatus: "", errors: dto.errors)
                            ErrorHandler.show(error: ApiServiceError.errorDto(results))
                        }else
                        {
                            ErrorHandler.show(error: error)
                        }
                    }else
                    {
                        ErrorHandler.show(error: error)
                    }
                default:
                    ErrorHandler.show(error: error)
                }
            }
        }.disposed(by: disposeBag)

    }
    func showRedMessage(redBorderMessage : String ,withMode:String)
    {
        if twoWayVC.securityViewMode == .onlyEmail
        {
            twoWayVC.twoWayVerifyView.emailInputView.invalidLabel.isHidden = false
            twoWayVC.twoWayVerifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: redBorderMessage)
        }else if twoWayVC.securityViewMode == .onlyMobile
        {
            twoWayVC.twoWayVerifyView.mobileInputView.invalidLabel.isHidden = false
            twoWayVC.twoWayVerifyView.mobileInputView.changeInvalidLabelAndMaskBorderColor(with: redBorderMessage)
        }else if twoWayVC.securityViewMode == .selectedMode
        {
            if withMode == "onlyEmail" , let emailVC = twoWayVC.twoWayViewControllers.first
            {
                emailVC.verifyView.emailInputView.invalidLabel.isHidden = false
                emailVC.verifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: redBorderMessage)
            }else if withMode == "onlyMobile" , let mobileVC = twoWayVC.twoWayViewControllers.last
            {
                mobileVC.verifyView.mobileInputView.invalidLabel.isHidden = false
                mobileVC.verifyView.mobileInputView.changeInvalidLabelAndMaskBorderColor(with: redBorderMessage)
            }
        }
    }
}
// MARK: -
// MARK: 延伸
//@available(iOS 11.0, *)
extension AddressBookViewController:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresBookDtos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: AddressBookViewCell.self, indexPath: indexPath)
        cell.setData(data: addresBookDtos[indexPath.item])
        cell.shouldIndentWhileEditing = false
        cell.rxChangeWhiteListClickWhenOpen().subscribeSuccess {[self] cellData in
            Log.i("發送驗證碼並呼叫修改API")
            toSecurityByType(data: cellData)
        }.disposed(by: cellDpg)
        cell.rxChangeWhiteListClickWhenClose().subscribeSuccess {[self] cellData in
            Log.i("呼叫修改API")
            changeCellWhiteListType(addressData: cellData) { isOnValue in
                if isOnValue == false
                {
                    cell.whiteListSwitch.isOn = true
                }
            }
        }.disposed(by: cellDpg)
//        cell.setAccountData(data: dataArray[indexPath.item])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let data = dataArray[indexPath.item]
//        onCellClick.onNext(data)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // 0927 刪除交互修改
        return false
//        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete".localized) { [self ](action, indexPath) in
            Log.v("刪除\(action)")
            showAlert(indexpath: indexPath)
        }
        delete.backgroundColor = UIColor(rgb: 0x2B3674)
        return [delete]
    }
 
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.isEditing ? .none:.delete
    }
//    @available(iOS 11.0, *)
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
//            print("一點點動心")
//            completionHandler(true)
//        }
//        delete.image = UIImage(named: "RightDeletaBG")
//        delete.backgroundColor = UIColor(rgb: 0x2B3674)
//        return UISwipeActionsConfiguration(actions: [delete])
//    }
    // 0927 刪除交互修改
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                Log.v("刪除\(indexPath)")
                showAlert(indexpath: indexPath)
            }
        }
    }
}
