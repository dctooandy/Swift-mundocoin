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
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
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

    }
    func bindUI()
    {
        Themes.statusViewHiddenType.bind(to: statusView.rx.isHidden).disposed(by: dpg)
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
