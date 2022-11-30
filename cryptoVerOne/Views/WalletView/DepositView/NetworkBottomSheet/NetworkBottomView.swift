//
//  NetworkBottomView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/13.
//


import Foundation
import RxCocoa
import RxSwift

class NetworkBottomView: UIView {
    // MARK:業務設定
    private let onCellClick = PublishSubject<SelectNetworkMethodDetailDto>()
    private let dpg = DisposeBag()
//    var dataArray = [UserAddressDto]()
    var dataArray : [SelectNetworkMethodDetailDto] = []{
        didSet {
            setupData()
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
//        setupData()
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
        topLabel.text = "Select Network Method".localized
        subLabel.text = "The method must match the network.".localized
//        addNewAddressLabel.text = "+ Add new address".localized
//        addressBookLabel.text = "Address book".localized
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: NetworkBottomCell.self)
        tableView.separatorStyle = .none
    }
    func setupData()
    {
        // 目前沒有特殊處理
        tableView.reloadData()
    }
    func bindLabel()
    {
  
    }
    func rxCellDidClick() -> Observable<SelectNetworkMethodDetailDto>
    {
        return onCellClick.asObserver()
    }

}
// MARK: -
// MARK: 延伸
extension NetworkBottomView:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: NetworkBottomCell.self, indexPath: indexPath)
        cell.config(withData: dataArray[indexPath.item])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataArray[indexPath.item]
        onCellClick.onNext(data)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
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
