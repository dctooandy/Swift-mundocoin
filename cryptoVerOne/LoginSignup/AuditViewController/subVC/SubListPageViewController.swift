//
//  SubListPageViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/13/22.
//

import Foundation
import RxCocoa
import RxSwift
import Parchment
class SubListPageViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
//    fileprivate let viewModel = SubListViewModel()
    var pendingDataArray : [WalletWithdrawDto] = []
    var finishedDataArray : [WalletWithdrawDto] = []
    var currentPage: Int = 0
    var subVCs : [SubListViewcontroller]! = []
    private var currentShowMode: AuditShowMode = .pending {
        didSet {            
            pageViewcontroller?.reloadData()
        }
    }
    // MARK: -
    // MARK:UI 設定
    private var pageViewcontroller: PagingViewController<PagingIndexItem>?
   
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenu()
        setupVC()
//        bindViewModel()
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
    private func setupMenu() {
        pageViewcontroller = PagingViewController<PagingIndexItem>()
        pageViewcontroller?.delegate = self
        pageViewcontroller?.dataSource = self
        
        // menu item
        pageViewcontroller?.selectedBackgroundColor = .clear
        pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: 120, height: 48)
        // menu 上下左右控制
        pageViewcontroller?.menuInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        pageViewcontroller?.menuHorizontalAlignment = .center
        pageViewcontroller?.menuItemSpacing = 20
        pageViewcontroller?.menuBackgroundColor = .white
        pageViewcontroller?.borderColor = UIColor(rgb: 0xE0E5F2)
        // menu text
        pageViewcontroller?.selectedFont = Fonts.SFProDisplaySemibold(18)
        pageViewcontroller?.font = Fonts.SFProDisplayRegular(18)
        pageViewcontroller?.textColor = Themes.grayA3AED0
        pageViewcontroller?.selectedTextColor = Themes.gray2B3674
        // menu indicator
        // 欄目可動
        pageViewcontroller?.menuInteraction = .none
        // 下方VC可動
        pageViewcontroller?.contentInteraction = .none
        pageViewcontroller?.indicatorColor = Themes.gray2B3674
        pageViewcontroller?.indicatorClass = IndicatorView.self
        pageViewcontroller?.indicatorOptions = .visible(height: 9,
                                                        zIndex: Int.max,
                                                        spacing: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 45),
                                                        insets: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0))
//        pageViewcontroller?.indicatorClass = RoundedIndicatorView.self
//        pageViewcontroller?.indicatorOptions = .visible(height: 1,
//                                                        zIndex: Int.max,
//                                                        spacing: UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 15),
//                                                        insets: UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15))
        addChild(pageViewcontroller!)
        view.addSubview(pageViewcontroller!.view)
        pageViewcontroller?.view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    private func setupVC() {
        let pendingVC = SubListViewcontroller.instance(mode: .pending)
        let finishedVC = SubListViewcontroller.instance(mode: .finished)
        subVCs = [pendingVC,finishedVC]
        pageViewcontroller?.reloadData()
//        bindLoginViewControllers()
//        bindSingupViewControllers()
//        bindForgotViewControllers()
    }
    func reloadPageMenu(currentMode: AuditShowMode) {
        self.currentShowMode = currentMode
        DispatchQueue.main.async {[weak self] in
            self?.pageViewcontroller?.reloadData()
        }
    }
    override var preferredStatusBarStyle:UIStatusBarStyle {
        if #available(iOS 13.0, *) {
#if Approval_PRO || Approval_DEV || Approval_STAGE
            return .lightContent
#else
            return .darkContent
#endif
        } else {
            return .default
        }
    }
}
// MARK: -
// MARK: 延伸
extension SubListPageViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T where T : PagingItem, T : Comparable, T : Hashable {
        return PagingIndexItem(index: index, title: subVCs[index].modeTitle()) as! T
        
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T : PagingItem, T : Comparable, T : Hashable {
        return subVCs[index]
    }
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int where T : PagingItem, T : Comparable, T : Hashable {
        return subVCs.count
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
//        if let pageItem = pagingItem as? PagingIndexItem
//        {
//            currentShowMode = pageItem.index == 0 ? .pending : .finished
//            Log.v("pagingItem :\(pageItem.index)")
////            isFilterAction = false
//        }
    }
}
