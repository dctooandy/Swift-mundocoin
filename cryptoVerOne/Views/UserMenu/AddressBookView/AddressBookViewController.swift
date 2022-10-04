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

class AddressBookViewController: BaseViewController {
    // MARK:業務設定
    var viewModel = AddressBookViewModel()
    private let onClick = PublishSubject<Any>()
//    private let dpg = DisposeBag()
    private var cellDpg = DisposeBag()
    var addresBookDtos : [AddressBookDto] = []
    var twoFAVC = SecurityVerificationViewController.loadNib()
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
        let whiteListBottomSheet = WhiteListBottomSheet()
        whiteListBottomSheet.rxChangeWhiteListMode().subscribeSuccess { [self] _ in
            twoFAVC = SecurityVerificationViewController.loadNib()
            // 暫時改為 onlyEmail
//            twoFAVC.securityViewMode = .defaultMode
//            twoFAVC.rxVerifySuccessClick().subscribeSuccess { [self] (_) in
//                verifySuccessForChangeWhiteList()
//            }.disposed(by: dpg)
            twoFAVC.securityViewMode = .onlyEmail
            twoFAVC.rxVerifySuccessClick().subscribeSuccess { [self] data in
                verifySuccessForChangeWhiteList(code: data.0,withMode: data.1, done: {
                    self.twoFAVC.navigationController?.popViewController(animated: true)
                    
                })
            }.disposed(by: disposeBag)
            self.navigationController?.pushViewController(twoFAVC, animated: true)
        }.disposed(by: disposeBag)
        DispatchQueue.main.async {
            whiteListBottomSheet.start(viewController: self ,height: 283)
        }
    }
    func verifySuccessForChangeWhiteList(code:String, withMode:String = "",done: @escaping () -> Void)
    {
        let isOn = KeychainManager.share.getWhiteListOnOff()
        Beans.addressBookServer.enableAddressBookWhiteList(enabled: !isOn, verificationCode: code).subscribe { _ in
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
                    if status == "400"
                    {
                        if reason == "CODE_MISMATCH"
                        {
                            Log.i("驗證碼錯誤 :\(reason)")
                            if twoFAVC.securityViewMode == .onlyEmail
                            {
                                twoFAVC.twoFAVerifyView.emailInputView.invalidLabel.isHidden = false
                                twoFAVC.twoFAVerifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                            }else if twoFAVC.securityViewMode == .onlyTwoFA
                            {
                                twoFAVC.twoFAVerifyView.twoFAInputView.invalidLabel.isHidden = false
                                twoFAVC.twoFAVerifyView.twoFAInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                            }else if twoFAVC.securityViewMode == .selectedMode
                            {
                                if withMode == "onlyEmail" , let emailVC = twoFAVC.twoFAViewControllers.first
                                {
                                    emailVC.verifyView.emailInputView.invalidLabel.isHidden = false
                                    emailVC.verifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                                }else if withMode == "onlyTwoFA" , let twoFAVC = twoFAVC.twoFAViewControllers.last
                                {
                                    twoFAVC.verifyView.twoFAInputView.invalidLabel.isHidden = false
                                    twoFAVC.verifyView.twoFAInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                                }
                            }else if twoFAVC.securityViewMode == .defaultMode
                            {
                                if twoFAVC.twoFAVerifyView.twoFAViewMode == .both
                                {
                                    ErrorHandler.show(error: error)
                                }
                            }
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
            
            twoFAVC = SecurityVerificationViewController.loadNib()
            // 暫時改為 onlyEmail
            //            twoFAVC.securityViewMode = .defaultMode
            //            twoFAVC.rxVerifySuccessClick().subscribeSuccess { [self] (_) in
            //                verifySuccessForChangeWhiteList()
            //            }.disposed(by: dpg)
            twoFAVC.securityViewMode = .onlyEmail
            twoFAVC.rxVerifySuccessClick().subscribeSuccess { [self] (codeData) in
                //            twoFAVC.navigationController?.popViewController(animated: true)
                Log.i("返回Security並打API")
                // 需要填入修改白名單API
                changeCellWhiteListType(addressData: data , code: codeData.0,withMode: codeData.1, done: {
                    if codeData.0 != "" // 如果codeData.0 不是 "" ,即為開啟,會帶驗證碼
                    {
                        self.twoFAVC.navigationController?.popViewController(animated: true)
                    }
                    _ = AddressBookListDto.update { [self] in
                        addresBookDtos = KeychainManager.share.getAddressBookList()
                        cellDpg = DisposeBag()
                        tableView.reloadData()
                    }
                })
            }.disposed(by: disposeBag)
            isShowSecurityVC = true
            self.navigationController?.pushViewController(twoFAVC, animated: true)
        }else
        {
//            isShowSecurityVC = false
        }
    }
    func changeCellWhiteListType(addressData:AddressBookDto , code:String = "" , withMode:String = "",done: @escaping () -> Void)
    {
        Beans.addressBookServer.updateAddressBookStatus(addressBookID: addressData.id , enabled: addressData.enabled , verificationCode: code).subscribe { _ in
            done()
        } onError: { [self] error in
            if let error = error as? ApiServiceError
            {
                switch error {
                case .errorDto(let dto):
                    let status = dto.httpStatus ?? ""
                    let reason = dto.reason
                    if status == "400"
                    {
                        if reason == "CODE_MISMATCH"
                        {
                            Log.i("驗證碼錯誤 :\(reason)")
                            if twoFAVC.securityViewMode == .onlyEmail
                            {
                                twoFAVC.twoFAVerifyView.emailInputView.invalidLabel.isHidden = false
                                twoFAVC.twoFAVerifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                            }else if twoFAVC.securityViewMode == .onlyTwoFA
                            {
                                twoFAVC.twoFAVerifyView.twoFAInputView.invalidLabel.isHidden = false
                                twoFAVC.twoFAVerifyView.twoFAInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                            }else if twoFAVC.securityViewMode == .selectedMode
                            {
                                if withMode == "onlyEmail" , let emailVC = twoFAVC.twoFAViewControllers.first
                                {
                                    emailVC.verifyView.emailInputView.invalidLabel.isHidden = false
                                    emailVC.verifyView.emailInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                                }else if withMode == "onlyTwoFA" , let twoFAVC = twoFAVC.twoFAViewControllers.last
                                {
                                    twoFAVC.verifyView.twoFAInputView.invalidLabel.isHidden = false
                                    twoFAVC.verifyView.twoFAInputView.changeInvalidLabelAndMaskBorderColor(with: "The Email Code is incorrect. Please re-enter.")
                                }
                            }else if twoFAVC.securityViewMode == .defaultMode
                            {
                                if twoFAVC.twoFAVerifyView.twoFAViewMode == .both
                                {
                                    ErrorHandler.show(error: error)
                                }
                            }
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
            changeCellWhiteListType(addressData: cellData, done: {})
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
