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
    private let onCellClick = PublishSubject<UserAddressDto>()
    private let dpg = DisposeBag()
    var dataArray = [UserAddressDto]()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var addNewAddressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupData()
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
        
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: AddressBottomCell.self)
        tableView.separatorStyle = .none
    }
    func setupData()
    {
        for index in 0...9 {
            let data = UserAddressDto(accountName: "Kraken wallet", address: "THFfxoxMtMJGnjarKUpt7qjfcXUNbHzry3", protocolType: "TRC\(index)")
            dataArray.append(data)
        }
    }
    func rxCellDidClick() -> Observable<UserAddressDto>
    {
        return onCellClick.asObserver()
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
