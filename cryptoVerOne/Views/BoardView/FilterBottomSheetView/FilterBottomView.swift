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
    case deposits
    case withdrawals
    case all
    case pending
    case processing
    case completed
    
    var title:String {
        switch self {
        case .deposits:
            return "Deposits".localized
        case .withdrawals:
            return "Withdrawals".localized
        case .all:
            return "All".localized
        case .pending:
            return "Pending".localized
        case .processing:
            return "Processing".localized
        case .completed:
            return "Completed".localized
        }
    }
    var width:CGFloat {
        return NSString(string: self.title).size(withAttributes: [NSAttributedString.Key.font:Fonts.pingFangSCRegular(14)]).width + 40
    }
}
class FilterBottomView: UIView {
    // MARK:業務設定
    private let onConfirmTrigger = PublishSubject<Any>()
    private let dpg = DisposeBag()
    let dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
           return formatter
       }()
    var showModeAtView : TransactionShowMode = .withdrawals
    {
        didSet{
            TwoSideStyle.share.acceptSheetHeightStyle(showModeAtView)
            historyCollectionView.selectItem(at: IndexPath(item: showModeAtView == .deposits ? 0 : 1, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
        }
    }
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var historyCollectionView: UICollectionView!
    @IBOutlet weak var statusCollectionView: UICollectionView!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var cryptoContainerView: UIView!
    @IBOutlet weak var cryptoLabel: UILabel!
    
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
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
        setupDatePacker()
        bindUI()
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
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        //        flowLayout.minimumInteritemSpacing = 5
        historyCollectionView.registerXibCell(type: FilterCollectionCell.self)
        historyCollectionView.backgroundColor = .clear
        historyCollectionView.showsHorizontalScrollIndicator = false

        statusCollectionView.registerXibCell(type: FilterCollectionCell.self)
        statusCollectionView.backgroundColor = .clear
        statusCollectionView.showsHorizontalScrollIndicator = false
        statusCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
        
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

    }
    func setupDatePacker()
    {
        let startDate = dateFormatter.string(from: Date())
        startLabel.text = startDate
        let endDate = dateFormatter.string(from: Date())
        endLabel.text = endDate
        // 可以選擇的最早日期時間
        let fromDateTime = dateFormatter.date(from: startDate)
        endDatePicker.minimumDate = fromDateTime
        
        // 使用 UIDatePicker(frame:) 建立一個 UIDatePicker
//        myDatePicker = UIDatePicker()
//        // 設置 UIDatePicker 格式
//        myDatePicker.datePickerMode = .date
//        // 選取時間時的分鐘間隔 這邊以 15 分鐘為一個間隔
//        myDatePicker.minuteInterval = 15
//        // 設置預設時間為現在時間
//        myDatePicker.date = Date()
//        // 設置 NSDate 的格式
//        let formatter = DateFormatter()
//        // 設置時間顯示的格式
//        formatter.dateFormat = "yyyy-MM-dd"
//        // 可以選擇的最早日期時間
//        let fromDateTime = formatter.date(from: "2021-01-01")
//        // 設置可以選擇的最早日期時間
//        myDatePicker.minimumDate = fromDateTime
//        // 可以選擇的最晚日期時間
//        let endDateTime = formatter.date(from: "2022-12-25")
//        // 設置可以選擇的最晚日期時間
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
        Themes.statusViewHiddenType.bind(to: statusView.rx.isHidden).disposed(by: dpg)
//        dateContainerView.rx.click.subscribeSuccess { [self] _ in
//            Log.v("選時間")
//
////            myDatePicker.sendActions(for: .touchUpInside)
//        }.disposed(by: dpg)

        startDatePicker.rx.click.subscribeSuccess { [weak self](_) in
            Log.v("選Start時間")
            self?.startDatePicker.alpha = 1.0
        }.disposed(by: dpg)
        endDatePicker.rx.click.subscribeSuccess { [weak self](_) in
            Log.v("選end時間")
            self?.endDatePicker.alpha = 1.0
        }.disposed(by: dpg)
        startDatePicker.addTarget(self, action: #selector(tap(_:)), for: .editingDidEnd)
        endDatePicker.addTarget(self, action: #selector(tap(_:)), for: .editingDidEnd)
//        startLabel.rx.click.subscribeSuccess { [self](_) in
//            Log.v("選Start時間")
//            startDatePicker.sendActions(for: .allTouchEvents)
//        }.disposed(by: dpg)
    }
    @objc func tap(_ sender: UIDatePicker) {
        if sender == startDatePicker
        {
            startDatePicker.alpha = 0.05
            let startDate = dateFormatter.string(from: startDatePicker.date)
            let endDate = dateFormatter.string(from: endDatePicker.date)
            startLabel.text = startDate

            // 可以選擇的最早日期時間
            let fromDateTime = dateFormatter.date(from: startDate)
            endDatePicker.minimumDate = fromDateTime
            // 如果 開始日期大於結束日期
            if startDate > endDate
            {
                // 結束picker值 要等於 開始picker值
                endDatePicker.date = startDatePicker.date
                // 結束label 要等於 開始label
                endLabel.text = startDate
            }
        }else
        {
            endDatePicker.alpha = 0.05
            let endDate = dateFormatter.string(from: endDatePicker.date)
            endLabel.text = endDate
        }
    }
    @objc private func confirmButtonPressed(_ sender: UIButton) {
        
        if sender == confirmButton {
            Log.v("Confirm")
        } else {
            Log.v("Reset")
        }
    }
    func rxConfirmTrigger() -> Observable<Any>
    {
        return onConfirmTrigger.asObserver()
    }
}
// MARK: -
// MARK: 延伸
extension FilterBottomView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == historyCollectionView
        {
            return 2
        }else
        {
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == historyCollectionView
        {
            let cell = collectionView.dequeueCell(type: FilterCollectionCell.self, indexPath: indexPath)
            if indexPath.item == 0
            {
                cell.setData(mode: .deposits)
            }else
            {
                cell.setData(mode: .withdrawals)
            }
            return cell
        }else
        {
            let cell = collectionView.dequeueCell(type: FilterCollectionCell.self, indexPath: indexPath)
            if indexPath.item == 0
            {
                cell.setData(mode: .all)
            }else if indexPath.item == 1
            {
                cell.setData(mode: .pending)
            }else if indexPath.item == 2
            {
                cell.setData(mode: .processing)
            }else
            {
                cell.setData(mode: .completed)
            }
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == historyCollectionView
        {
            if indexPath.item == 0
            {
                return CGSize(width: FilterLabelType.deposits.width, height: 33)
            }else
            {
                return CGSize(width: FilterLabelType.withdrawals.width, height: 33)
            }
        }else
        {
            if indexPath.item == 0
            {
                return CGSize(width: FilterLabelType.all.width, height: 33)
            }else if indexPath.item == 1
            {
                return CGSize(width: FilterLabelType.pending.width, height: 33)
            }else if indexPath.item == 2
            {
                return CGSize(width: FilterLabelType.processing.width, height: 33)
            }else
            {
                return CGSize(width: FilterLabelType.completed.width, height: 33)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionCell else { return }
        if cell.mode == .deposits
        {
            TwoSideStyle.share.acceptSheetHeightStyle(.deposits)
        }else if cell.mode == .withdrawals
        {
            TwoSideStyle.share.acceptSheetHeightStyle(.withdrawals)
        }else
        {
            
        }
    }
}
