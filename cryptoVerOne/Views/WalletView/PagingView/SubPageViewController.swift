//
//  SubPageViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import RxCocoa
import RxSwift

class SubPageViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    private var walletPageMode : WalletPageMode = .spot {
        didSet {

        }
    }
    var dataDto : [WalletBalancesDto]? = nil {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: -
    // MARK:UI 設定
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
//        flowLayout.minimumInteritemSpacing = 5
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.registerXibCell(type: SubPageCollectionCell.self)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    // MARK: -
    // MARK:Life cycle
    // MARK: instance
    static func instance(mode: WalletPageMode) -> SubPageViewController {
        let vc = SubPageViewController()
        vc.walletPageMode = mode
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
    // MARK: -
    // MARK:業務方法
    func modeTitle() -> String {
        switch self.walletPageMode {
        case .spot:
            return "Spot".localized
        case.stake:
            return "Stake".localized
        }
    }
    func setup()
    {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.trailing.leading.bottom.equalToSuperview()
        }
    }
}
// MARK: -
// MARK: 延伸
extension SubPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = dataDto
        {
            return data.count
        }else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: SubPageCollectionCell.self, indexPath: indexPath)
        if let data = dataDto?[indexPath.item]
        {
            cell.setData(data: data)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let baseHeight = height(71/812)
     
        return CGSize(width: Views.screenWidth, height: baseHeight)
    }
}
