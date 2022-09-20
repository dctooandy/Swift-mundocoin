//
//  AddressBottomView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/13.
//


import Foundation
import RxCocoa
import RxSwift

class AddressBottomView: UIView {
    // MARK:業務設定
    private let onCellClick = PublishSubject<AddressBookDto>()
    private let onAddNewAddressClick = PublishSubject<Any>()
    private let onAddressBookClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
//    var dataArray = [UserAddressDto]()
    var dataArray = [AddressBookDto]()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var addNewAddressLabel: UILabel!
    @IBOutlet weak var addressBookLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupData()
        bindLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        topLabel.text = "USDT address".localized
        subLabel.text = "The method must match the network.".localized
        addNewAddressLabel.text = "+ Add new address".localized
        addressBookLabel.text = "Address book".localized
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: AddressBottomCell.self)
        tableView.separatorStyle = .none
    }
    func setupData()
    {
        let isOn = KeychainManager.share.getWhiteListOnOff()
        var allAddressList:[AddressBookDto] = []
        if isOn == true
        {
            allAddressList = KeychainManager.share.getAddressBookList()
            allAddressList = allAddressList.filter({ $0.enabled == true })
        }else
        {
            allAddressList = KeychainManager.share.getAddressBookList()
        }
        dataArray = allAddressList
        tableView.reloadData()
    }
    func bindLabel()
    {
        addNewAddressLabel.rx.click.subscribeSuccess { [self] _ in
            onAddNewAddressClick.onNext(())
        }.disposed(by: dpg)
        addressBookLabel.rx.click.subscribeSuccess { [self] _ in
            onAddressBookClick.onNext(())
        }.disposed(by: dpg)
    }
    func rxCellDidClick() -> Observable<AddressBookDto>
    {
        return onCellClick.asObserver()
    }
    func rxAddNewAddressClick() -> Observable<Any>
    {
        return onAddNewAddressClick.asObserver()
    }
    func rxAddressBookClick() -> Observable<Any>
    {
        return onAddressBookClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
extension AddressBottomView:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: AddressBottomCell.self, indexPath: indexPath)
        cell.setAccountData(data: dataArray[indexPath.item])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataArray[indexPath.item]
        onCellClick.onNext(data)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
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
    
}
