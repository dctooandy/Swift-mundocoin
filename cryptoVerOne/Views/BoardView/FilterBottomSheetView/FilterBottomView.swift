//
//  FilterBottomView.swift
//  cryptoVerOne
//
//  Created by BBk on 6/6/22.
//


import Foundation
import RxCocoa
import RxSwift
import UIKit

enum FilterLabelType {
    case history
    case status
    case networkMethod
    case addNewAddressNetworkMethod
    
    var numberOfRow : Int {
        switch self
        {
        case .history:
            return 3
        case .status:
            return 5
        case .networkMethod:
            return 3
        case .addNewAddressNetworkMethod:
            return KeychainManager.share.getMundoCoinNetworkMethodEnable() ? 2 : 1
        }
    }
    var topLabelString : String{
        switch self {
        case .history:
            return "History".localized
        case .status:
            return "Status".localized
        case .networkMethod:
            return "NetWork Method".localized
        case .addNewAddressNetworkMethod:
            return "Network".localized
        }
    }
    var titles:[String] {
        switch self {
        case .history:
            return ["All".localized,
                    "Deposits".localized,
                    "Withdrawals".localized]
        case .status:
            return ["All".localized,
                    "Pending".localized,
                    "Processing".localized,
                    "Completed".localized,
                    "Failed".localized]
        case .networkMethod:
            return ["All".localized,
                    "TRC20".localized,
                    "ERC20".localized]
        case .addNewAddressNetworkMethod:
            return KeychainManager.share.getMundoCoinNetworkMethodEnable() ?
            ["TRC 20".localized,"ERC 20".localized] :
            ["TRC 20".localized]
        }
    }
    var widths:[CGFloat] {
        switch self {
        case .history:
            return ["All".localized.customWidth(),
                    "Deposits".localized.customWidth(),
                    "Withdrawals".localized.customWidth()]
        case .status:
            return ["All".localized.customWidth(),
                    "Pending".localized.customWidth(),
                    "Processing".localized.customWidth(),
                    "Completed".localized.customWidth(),
                    "Failed".localized.customWidth()]
        case .networkMethod:
            return ["All".localized.customWidth(),
                    "TRC20".localized.customWidth(),
                    "ERC20".localized.customWidth()]
        case .addNewAddressNetworkMethod:
            return KeychainManager.share.getMundoCoinNetworkMethodEnable() ?
            ["TRC 20".localized.customWidth(),"ERC 20".localized.customWidth()] :
            ["TRC 20".localized.customWidth()]
        }
    }
}
class FilterBottomView: UIView {
    // MARK:????????????
    private let onConfirmTrigger = PublishSubject<WalletTransPostDto>()
    private let dpg = DisposeBag()
    let dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
           return formatter
       }()
    var showModeAtView : TransactionShowMode = .withdrawals
    {
        didSet{
            if showModeAtView == .deposits
            {
                filterHistoryValue = "DEPOSIT"
            }else if showModeAtView == .withdrawals
            {
                filterHistoryValue = "WITHDRAW"
            }else
            {
                filterHistoryValue = "ALL"
            }
            let showModeIndex = (showModeAtView == .deposits ? 1 : (showModeAtView == .withdrawals ? 2 : 0))
            FilterStyleThemes.share.acceptSheetHeightStyle(showModeAtView)
            historyView.collectionView.selectItem(at: IndexPath(item: showModeIndex, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
        }
    }
    var transPostDto :WalletTransPostDto = WalletTransPostDto()
    var filterHistoryValue:String = "ALL"
    var filterNetworkMethodValue:String = "ALL"
    var filterStateValue:String = "ALL"
    
    // MARK: -
    // MARK:UI ??????
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var cryptoContainerView: UIView!
    @IBOutlet weak var cryptoLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var historyView:DynamicCollectionView!
    @IBOutlet weak var networkMethodView:DynamicCollectionView!
    @IBOutlet weak var statusView:DynamicCollectionView!
    @IBOutlet weak var cryptoInputView: InputStyleView!
    private lazy var confirmButton: OKButton = {
        let btn = OKButton()
        btn.setTitle("Confirm".localized, for: .normal)
        btn.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var resetButton: CancelButton = {
        let btn = CancelButton()
        btn.setTitle("Reset".localized, for: .normal)
        btn.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    var myDatePicker: UIDatePicker!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupDatePackerLabel()
        bindUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: -
    // MARK:????????????
    func setupUI()
    {
//        historyCollectionView.registerXibCell(type: FilterCollectionCell.self)
//        historyCollectionView.backgroundColor = .clear
//        historyCollectionView.showsHorizontalScrollIndicator = false
//
//        statusCollectionView.registerXibCell(type: FilterCollectionCell.self)
//        statusCollectionView.backgroundColor = .clear
//        statusCollectionView.showsHorizontalScrollIndicator = false
//        statusCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
        
        dateContainerView.layer.borderColor = Themes.grayE0E5F2.cgColor
        dateContainerView.layer.borderWidth = 1
        dateContainerView.layer.cornerRadius = 10
        dateContainerView.layer.masksToBounds = true
        cryptoContainerView.layer.cornerRadius = 10
        cryptoContainerView.layer.masksToBounds = true
        cryptoContainerView.backgroundColor = Themes.grayE0E5F2
        cryptoLabel.textColor = Themes.grayA3AED0
        cryptoLabel.backgroundColor = .clear
        
        addSubview(confirmButton)
        addSubview(resetButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(cryptoContainerView.snp.bottom).offset(32)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(44)
            make.width.equalToSuperview().multipliedBy(0.39)
        }
        resetButton.snp.makeConstraints { make in
            make.top.equalTo(cryptoContainerView.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(30)
            make.height.equalTo(44)
            make.width.equalToSuperview().multipliedBy(0.39)
        }
        historyView.setData(type: .history)
        if KeychainManager.share.getMundoCoinNetworkMethodEnable() == true
        {
            networkMethodView.setData(type: .networkMethod)
        }else
        {
            networkMethodView.isHidden = true
        }
        statusView.setData(type: .status)
        cryptoInputView.setMode(mode: .crypto(["USDT"] , .drop))
    }
    func setupDatePackerLabel()
    {
        let startDateValue = Date().addDay(day: -90)
        let startDate = dateFormatter.string(from: startDateValue)
        startLabel.text = startDate
        let endDate = dateFormatter.string(from: Date())
        endLabel.text = endDate
        // ?????????????????????????????????
        let fromDateTime = dateFormatter.date(from: startDate)
        endDatePicker.minimumDate = fromDateTime
        // ?????? UIDatePicker(frame:) ???????????? UIDatePicker
//        myDatePicker = UIDatePicker()
//        // ?????? UIDatePicker ??????
//        myDatePicker.datePickerMode = .date
//        // ?????????????????????????????? ????????? 15 ?????????????????????
//        myDatePicker.minuteInterval = 15
//        // ?????????????????????????????????
//        myDatePicker.date = Date()
//        // ?????? NSDate ?????????
//        let formatter = DateFormatter()
//        // ???????????????????????????
//        formatter.dateFormat = "yyyy-MM-dd"
//        // ?????????????????????????????????
//        let fromDateTime = formatter.date(from: "2021-01-01")
//        // ???????????????????????????????????????
//        myDatePicker.minimumDate = fromDateTime
//        // ?????????????????????????????????
//        let endDateTime = formatter.date(from: "2022-12-25")
//        // ???????????????????????????????????????
//        myDatePicker.maximumDate = endDateTime
//        if #available(iOS 13.4, *) {
//            myDatePicker.preferredDatePickerStyle = .compact
//        } else {
//            // Fallback on earlier versions
//        }
//        myDatePicker.locale = Locale(identifier: "en_US_POSIX")
//        myDatePicker.calendar = Calendar(identifier: .gregorian)
//        dateContainerView.addSubview(myDatePicker)
//        myDatePicker.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.leading.equalToSuperview().offset(20)
//        }
    }
    func bindUI()
    {
        FilterStyleThemes.statusViewHiddenType.bind(to: statusView.rx.isHidden).disposed(by: dpg)

        startDatePicker.rx.click.subscribeSuccess { [weak self](_) in
            Log.v("???Start??????")
            self?.startDatePicker.alpha = 1.0
        }.disposed(by: dpg)
        endDatePicker.rx.click.subscribeSuccess { [weak self](_) in
            Log.v("???end??????")
            self?.endDatePicker.alpha = 1.0
        }.disposed(by: dpg)
        startDatePicker.addTarget(self, action: #selector(tap(_:)), for: .editingDidEnd)
        endDatePicker.addTarget(self, action: #selector(tap(_:)), for: .editingDidEnd)
        startDatePicker.addTarget(self, action: #selector(changeClick(_:)), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(changeClick(_:)), for: .valueChanged)
        
        // start ???????????????????????????
        let startDateValue = Date().addDay(day: -90)
        let endDateValue = Date()
//        let startMinDate = dateFormatter.string(from: startDateValue)
//        let fromStartDateTime = dateFormatter.date(from: startMinDate)
        startDatePicker.minimumDate = startDateValue
        startDatePicker.maximumDate = endDateValue
        endDatePicker.maximumDate = endDateValue
        startDatePicker.setDate(startDateValue, animated: true)
        endDatePicker.date = Date()
        historyView.rxCellClick().subscribeSuccess { [self] data in
            if String(data.1) == "Deposits".localized
            {
                filterHistoryValue = "DEPOSIT"
                filterNetworkMethodValue = "ALL"
                filterStateValue = "ALL"
                FilterStyleThemes.share.acceptSheetHeightStyle(.deposits)
            }else if String(data.1) == "Withdrawals".localized
            {
                filterHistoryValue = "WITHDRAW"
                filterNetworkMethodValue = "ALL"
                filterStateValue = "ALL"
                FilterStyleThemes.share.acceptSheetHeightStyle(.withdrawals)
            }else
            {
                filterHistoryValue = "ALL"
                filterNetworkMethodValue = "ALL"
                filterStateValue = "ALL"
                FilterStyleThemes.share.acceptSheetHeightStyle(.all)
            }
        }.disposed(by: dpg)
        networkMethodView.rxCellClick().subscribeSuccess { [self] data in
            Log.v("NetWotk Method ?????? \(data.1)")
            filterNetworkMethodValue = changeNetworkMethodString(dataString: data.1)
        }.disposed(by: dpg)
        statusView.rxCellClick().subscribeSuccess { [self] data in
            Log.v("Status ?????? \(data.1)")
            filterStateValue = changeStateString(dataString: data.1)
        }.disposed(by: dpg)
    }
    func changeNetworkMethodString(dataString:String) -> String
    {
        if dataString == "All"
        {
            return "ALL"
        }else if dataString == "TRC20"
        {
            return "TRC20"
        }else if dataString == "ERC20"
        {
            return "ERC20"
        }else
        {
            return "ALL"
        }
    }
    func changeStateString(dataString:String) -> String
    {
        if dataString == "All"
        {
            return "ALL"
        }else if dataString == "Pending"
        {
            return "PENDING"
        }else if dataString == "Processing"
        {
            return "PROCESSING"
        }else if dataString == "Completed"
        {
            return "COMPLETE"
        }else if dataString == "Failed"
        {
            return "FAILED"
        }else
        {
            return "ALL"
        }
    }
    @objc func tap(_ sender: UIDatePicker) {
        if sender == startDatePicker
        {
            startDatePicker.alpha = 0.05
            let startDate = dateFormatter.string(from: startDatePicker.date)
            let endDate = dateFormatter.string(from: endDatePicker.date)
            startLabel.text = startDate

            // ?????????????????????????????????
            let fromDateTime = dateFormatter.date(from: startDate)
            endDatePicker.minimumDate = fromDateTime
            // ?????? ??????????????????????????????
            if startDate > endDate
            {
                // ??????picker??? ????????? ??????picker???
                endDatePicker.date = startDatePicker.date
                // ??????label ????????? ??????label
                endLabel.text = startDate
            }
        }else
        {
            endDatePicker.alpha = 0.05
            let endDate = dateFormatter.string(from: endDatePicker.date)
            endLabel.text = endDate
        }
    }
    @objc func changeClick(_ sender: UIDatePicker)
    {
        if sender == startDatePicker
        {
            let startDate = dateFormatter.string(from: startDatePicker.date)
            startLabel.text = startDate
        }else
        {
            let endDate = dateFormatter.string(from: endDatePicker.date)
            endLabel.text = endDate
        }
    }
    @objc private func confirmButtonPressed(_ sender: UIButton) {
        
        if sender == confirmButton ,let cryptoString = cryptoInputView.textField.text{
            Log.v("Confirm")
            let startDate = dateFormatter.string(from: startDatePicker.date)
//            let endDate = dateFormatter.string(from: endDatePicker.date)
            let beginTime = dateFormatter.date(from: startDate)?.timeIntervalSince1970
//            let endTime = dateFormatter.date(from: endDate)?.timeIntervalSince1970
            let endTime = endDatePicker.date.addEndOfDay().timeIntervalSince1970
            transPostDto.beginDate = beginTime! * 1000
            transPostDto.endDate = endTime * 1000
            transPostDto.currency = cryptoString
            transPostDto.historyType = filterHistoryValue
            if KeychainManager.share.getMundoCoinNetworkMethodEnable() == true
            {
                transPostDto.networkType = filterNetworkMethodValue
            }
            transPostDto.stats = filterStateValue
            onConfirmTrigger.onNext(transPostDto)
        } else {
            Log.v("Reset")
            setupDatePackerLabel()
        }
    }
    func setupData()
    {
        cryptoLabel.text = "USDT"
        // ????????????
        transPostDto.currency = "ALL"
        transPostDto.stats = "ALL"
        transPostDto.pageable = PagePostDto()
        let startDate = dateFormatter.string(from: startDatePicker.date)
        let endDate = dateFormatter.string(from: endDatePicker.date)
        let beginTime = dateFormatter.date(from: startDate)?.timeIntervalSince1970
        let endTime = dateFormatter.date(from: endDate)?.timeIntervalSince1970
        transPostDto.beginDate = beginTime!
        transPostDto.endDate = endTime!
    }
    
    func rxConfirmTrigger() -> Observable<WalletTransPostDto>
    {
        return onConfirmTrigger.asObserver()
    }
}
// MARK: -
// MARK: ??????
