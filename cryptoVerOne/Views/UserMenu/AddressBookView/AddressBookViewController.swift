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
    @IBOutlet weak var topIconImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topDrawDownIamge: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    let chooseDropDown = DropDown()
    let anchorView : UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
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
        let rightBarItems = [UIBarButtonItem(customView: addAddressBookButton),UIBarButtonItem(customView: whiteListButton)]
        self.navigationItem.rightBarButtonItems = rightBarItems
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        setupUI()
        bindUI()
        setupChooseDropdown()
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
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: AddressBookViewCell.self)
        tableView.separatorStyle = .none
        
        let textFieldMulH = height(48.0/812.0)
        view.addSubview(anchorView)
        anchorView.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom)
            make.height.equalTo(textFieldMulH)
            make.centerX.equalTo(topLabel)
            make.width.equalTo(topLabel)
        }
    }
    func bindUI()
    {
        topDrawDownIamge.rx.click.subscribeSuccess { (_) in
            self.chooseDropDown.show()
        }.disposed(by: dpg)
    }
    func setupChooseDropdown()
    {
        DropDown.setupDefaultAppearance()
        chooseDropDown.anchorView = anchorView
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
//        chooseDropDown.bottomOffset = CGPoint(x: 0, y:(chooseDropDown.anchorView?.plainView.bounds.height)!)
        chooseDropDown.topOffset = CGPoint(x: 0, y:-(chooseDropDown.anchorView?.plainView.bounds.height)!)
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseDropDown.direction = .bottom
        chooseDropDown.dataSource = dropDataSource
        
        // Action triggered on selection
        chooseDropDown.selectionAction = { [weak self] (index, item) in
//            self?.chooseButton.setTitle(item, for: .normal)
            self?.topLabel.text = item
        }
        chooseDropDown.dismissMode = .onTap
    }
    
    @objc func whiteListAction() {
        Log.i("開啟白名單警告Sheet")
        let whiteListBottomSheet = WhiteListBottomSheet()

        DispatchQueue.main.async {
            whiteListBottomSheet.start(viewController: self ,height: 317)
        }
    }
    
    @objc func addAddressBookAction() {
        Log.i("增加錢包地址")
        let boardVC = BoardViewController.loadNib()
        self.navigationController?.pushViewController(boardVC, animated: true)
    }
}
// MARK: -
// MARK: 延伸
@available(iOS 11.0, *)
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
