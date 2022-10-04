//
//  DynamicCollectionView.swift
//  cryptoVerOne
//
//  Created by BBk on 6/7/22.
//


import Foundation
import RxCocoa
import RxSwift

class DynamicCollectionView: UIView ,NibOwnerLoadable{
    // MARK:業務設定
    private let onClick = PublishSubject<(FilterLabelType,String)>()
    private let dpg = DisposeBag()
    var labelType : FilterLabelType! = .history
    {
        didSet{
//            collectionView.reloadData()
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        customInit()
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func customInit()
    {
        loadNibContent()
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        collectionView.registerXibCell(type: FilterCollectionCell.self)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        self.topLabel.text = labelType.topLabelString
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
        onClick.onNext((labelType , labelType.titles[0]))
    }
    func setData(type:FilterLabelType)
    {
        self.labelType = type
    }
    func rxCellClick() -> Observable<(FilterLabelType,String)>
    {
        return onClick.asObservable()
    }
}
// MARK: -
// MARK: 延伸
extension DynamicCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labelType.numberOfRow
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: FilterCollectionCell.self, indexPath: indexPath)
        cell.setData(modeName: labelType.titles[indexPath.item])
        if labelType == FilterLabelType.networkMethod
        {
            cell.titleLabel.font = Fonts.pingFangTCMedium(16)
        }else
        {

        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if labelType == FilterLabelType.networkMethod
        {
            return CGSize(width: labelType.widths[indexPath.item], height: 39)
        }else
        {
            return CGSize(width: labelType.widths[indexPath.item], height: 33)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onClick.onNext((labelType , labelType.titles[indexPath.item]))
    }
}
