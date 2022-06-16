//
//  TransactionTableViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/6/22.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class TransactionTableViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var showModeAtTableView : TransactionShowMode = .deposits{
        didSet{
            setup()
            bindView()
        }
    }
    var data:[ContentDto] = [] {
        didSet{
            createData()
        }
    }
    var sectionDic:[String:[ContentDto]] = [:]
    
    // MARK: -
    // MARK:UI 設定
    var verifyView = TwoFAVerifyView()
    var headerView: UILabel!
    @IBOutlet weak var tableView: UITableView!
    // MARK: -
    // MARK:Life cycle
    // MARK: instance
    static func instance(mode: TransactionShowMode) -> TransactionTableViewController {
        let vc = TransactionTableViewController.loadNib()
        vc.showModeAtTableView = mode
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Themes.grayF4F7FE
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        verifyView.cleanTimer()
    }
    // MARK: -
    // MARK:業務方法

    func setup()
    {
        tableView.tableFooterView = nil
        tableView.registerXibCell(type: TransHistoryCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundView = NoDataView(image: UIImage(named: "empty-list"), title: "No records found" , subTitle: "You have no transactions")
        tableView.backgroundView?.isHidden = false
    }
    func bindView()
    {
//        self.verifyView.rxSecondSendVerifyAction().subscribeSuccess { [self](_) in
//            onThirdSendVerifyClick.onNext(())
//        }.disposed(by: dpg)
//        self.verifyView.rxSubmitOnlyEmailAction().subscribeSuccess {[self](stringData) in
//            Log.i("發送submit請求 ,onlyEmail:\(stringData)")
//            onSubmitOnlyEmailClick.onNext(stringData)
//        }.disposed(by: dpg)
//        self.verifyView.rxSubmitOnlyTwiFAAction().subscribeSuccess {[self](stringData) in
//            Log.i("發送submit請求 ,onlyTwoFA:\(stringData)")
//            onSubmitOnlyTwoFAClick.onNext(stringData)
//        }.disposed(by: dpg)
    }
    func createData()
    {
        var daySactionStringArray:[String] = []
        let oldFormatter = DateFormatter()
        oldFormatter.dateFormat = "MM dd,yyyy HH:mm:ss"
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "MMMM dd,yyyy"
        for dataDto in data {
            // 將時間戳轉換成 TimeInterval
            let timeInterval = TimeInterval(dataDto.date)
            // 初始化一個 Date
            let date = Date(timeIntervalSince1970: timeInterval)
            //            let startDate = oldFormatter.date(from: dataDto.date)
            let currentTimeString = newFormatter.string(from: date )
            let newTimeInt = newFormatter.date(from: currentTimeString)?.timeIntervalSince1970
            
            if !daySactionStringArray.contains(newTimeInt?.intervalToString() ?? "0")
            {
                daySactionStringArray.append(newTimeInt?.intervalToString() ?? "0")
            }
            if let timeString = newTimeInt?.intervalToString()
            {
                if sectionDic[timeString] != nil
                {
                    sectionDic[timeString]?.append(dataDto)
                }else
                {
                    sectionDic[timeString] = [dataDto]
                }
            }
//            if sectionDic[currentTimeString] != nil
//            {
//                sectionDic[currentTimeString]?.append(dataDto)
//            }else
//            {
//                sectionDic[currentTimeString] = [dataDto]
//            }
        }
        tableView.backgroundView?.isHidden = data.count > 0 ? true : false
        tableView.reloadData()
    }
    func modeTitle() -> String {
        switch showModeAtTableView
        {
        case .deposits:
            return  "Deposits".localized
        case .withdrawals:
            return  "Withdrawals".localized
        }
    }
}
// MARK: -
// MARK: 延伸
extension TransactionTableViewController:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionCount = sectionDic.keys.count
        return sectionCount
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let keyArray = Array(sectionDic.keys).sorted(by: >)
        if let rowNumber = sectionDic[keyArray[section]]?.count
        {
            return rowNumber
        }else
        {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: TransHistoryCell.self, indexPath: indexPath)
        let keyArray = Array(sectionDic.keys).sorted(by: >)
        if let rowData = sectionDic[keyArray[indexPath.section]]
        {
            let currentData = rowData.sorted(by: { $0.date > $1.date })
            cell.setData(data: currentData[indexPath.item] ,type: showModeAtTableView)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = data[indexPath.item]
//        onCellClick.onNext(data)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.headerView = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 24))
        let keyArray = Array(sectionDic.keys).sorted(by: >)
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "MMMM dd,yyyy"
        let timeInterval = TimeInterval(keyArray[section])
        // 初始化一個 Date
        let date = Date(timeIntervalSince1970: timeInterval!)
        //            let startDate = oldFormatter.date(from: dataDto.date)
        let currentTimeString = newFormatter.string(from: date )
        self.headerView.text = currentTimeString
        self.headerView.textAlignment = .center
        self.headerView.backgroundColor = .clear
        self.headerView.textColor = Themes.gray707EAE
        self.headerView.font = Fonts.pingFangSCRegular(14)
        return self.headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if refreshControl.isRefreshing {
//            refreshing()
//        }
    }
}
