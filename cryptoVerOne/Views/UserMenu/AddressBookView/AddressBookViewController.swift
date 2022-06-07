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
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var dropDataSource = ["USDT","USD"]
    // MARK: -
    // MARK:UI 設定
//    @IBOutlet weak var topIconImageView: UIImageView!
//    @IBOutlet weak var topLabel: UILabel!
//    @IBOutlet weak var topDrawDownIamge: UIImageView!
//    let chooseDropDown = DropDown()
//    let anchorView : UIView = {
//       let view = UIView()
//        view.backgroundColor = .clear
//        return view
//    }()

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
        let image = UIImage(named:"icon-Chield_check")
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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        customDrowDownView.config(showDropdown: true, dropDataSource: dropDataSource)
    }
    func bindUI()
    {
        Themes.topWhiteListImageIconType.bind(to: whiteListButton.rx.image(for: .normal)).disposed(by: dpg)
        let style: WhiteListStyle = KeychainManager.share.getWhiteListOnOff() ? .whiteListOn:.whiteListOff
        TwoSideStyle.share.acceptWhiteListTopImageStyle(style)

    }

    @objc func whiteListAction() {
        Log.i("開啟白名單警告Sheet")
        let whiteListBottomSheet = WhiteListBottomSheet()
        whiteListBottomSheet.rxChangeWhiteListMode().subscribeSuccess { [self] _ in
            let twoFAVC = SecurityVerificationViewController.loadNib()
            twoFAVC.securityViewMode = .defaultMode
            twoFAVC.rxVerifySuccessClick().subscribeSuccess { [self] (_) in
                verifySuccessForChangeWhiteList()
            }.disposed(by: dpg)
            _ = self.navigationController?.pushViewController(twoFAVC, animated: true)
        }.disposed(by: dpg)
        DispatchQueue.main.async {
            whiteListBottomSheet.start(viewController: self ,height: 317)
        }
    }
    func verifySuccessForChangeWhiteList()
    {
        let isOn = KeychainManager.share.getWhiteListOnOff()
        KeychainManager.share.saveWhiteListOnOff(!isOn)
        TwoSideStyle.share.acceptWhiteListTopImageStyle(!isOn == true ? .whiteListOn : .whiteListOff)
    }
    @objc func addAddressBookAction() {
        Log.i("增加錢包地址")
        let addVC = AddNewAddressViewController.loadNib()
        self.navigationController?.pushViewController(addVC, animated: true)
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: AddressBookViewCell.self, indexPath: indexPath)
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
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            Log.v("刪除")
        }

        delete.backgroundColor = UIColor(rgb: 0x2B3674)

        return [delete]
    }
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let delete = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
//            print("一點點動心")
//            completionHandler(true)
//        }
//        delete.image = UIImage(named: "RightDeletaBG")
//        delete.backgroundColor = .clear
//        return UISwipeActionsConfiguration(actions: [delete])
//    }
}
