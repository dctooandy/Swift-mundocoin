//
//  WalletPageViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import Parchment
import RxCocoa
import RxSwift
enum WalletPageMode {
    case spot
    case stake
}
class WalletPageViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    private var pageViewcontroller: PagingViewController<PagingIndexItem>?
    private var subPageViewControllers = [SubPageViewController]()
    private var currentPageMode: WalletPageMode = .spot {
        didSet {
            pageViewcontroller?.reloadData()
        }
    }
    // MARK: -
    // MARK:UI 設定
   
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageVC()
        setupPageContainerView()
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
    private func setupPageVC() {
        let spotPage = SubPageViewController.instance(mode: .spot)
        let stakePage = SubPageViewController.instance(mode: .stake)
        subPageViewControllers = [spotPage,stakePage]
        bindSubPageViewControllers()
        
    }
    private func setupPageContainerView() {
        pageViewcontroller = PagingViewController<PagingIndexItem>()
        pageViewcontroller?.delegate = self
        pageViewcontroller?.dataSource = self
        // menu item
        pageViewcontroller?.menuItemSource = (.class(type: NewPagingTitleCell.self))
        pageViewcontroller?.selectedBackgroundColor = .white
        pageViewcontroller?.backgroundColor = UIColor(rgb: 0xEDEDED)
        pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: 110, height: 36)
        pageViewcontroller?.menuHorizontalAlignment = .center
        pageViewcontroller?.menuItemSpacing = 20
        pageViewcontroller?.menuBackgroundColor = .clear
        pageViewcontroller?.borderColor = .clear
        // menu text
        pageViewcontroller?.selectedFont = UIFont.systemFont(ofSize: 15)
        pageViewcontroller?.font = UIFont.systemFont(ofSize: 15)
        pageViewcontroller?.textColor = .black
        pageViewcontroller?.selectedTextColor = .black
        // menu indicator
        // 欄目可動
        pageViewcontroller?.menuInteraction = .none
        // 下方VC可動
        pageViewcontroller?.contentInteraction = .none
        pageViewcontroller?.indicatorColor = .clear
//        pageViewcontroller?.indicatorClass = IndicatorView.self
//        pageViewcontroller?.indicatorOptions = .visible(height: 6,
//                                                        zIndex: Int.max,
//                                                        spacing: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20),
//                                                        insets: .zero)
        addChild(pageViewcontroller!)
        view.addSubview(pageViewcontroller!.view)
        pageViewcontroller?.view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    // MARK: -
    // MARK:業務方法
    func bindSubPageViewControllers()
    {
        
    }
}
// MARK: -
// MARK: 延伸
extension WalletPageViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T where T : PagingItem, T : Comparable, T : Hashable {
        return PagingIndexItem(index: index, title: subPageViewControllers[index].modeTitle()) as! T
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T : PagingItem, T : Comparable, T : Hashable {
        return subPageViewControllers[index]
    }
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int where T : PagingItem, T : Comparable, T : Hashable {
        return subPageViewControllers.count
    }
}

//MARK: - apply menu indicator ui
class IndicatorView: PagingIndicatorView {
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layer.cornerRadius = layoutAttributes.frame.height / 2
    }
}
class NewPagingTitleCell: PagingTitleCell {
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
      super.apply(layoutAttributes)
        layer.cornerRadius = layoutAttributes.frame.height / 2
    }
}
