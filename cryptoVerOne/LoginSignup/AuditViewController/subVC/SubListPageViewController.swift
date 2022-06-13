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
    var subVCs : [SubListViewcontroller]! = []
    private var pageViewcontroller: PagingViewController<PagingIndexItem>?
    private var currentShowMode: AuditShowMode = .pending {
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
        setupMenu()
        setupVC()
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
        pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: 120, height: 48)
        // menu 上下左右控制
        pageViewcontroller?.menuInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        pageViewcontroller?.menuHorizontalAlignment = .center
        pageViewcontroller?.menuItemSpacing = 20
        pageViewcontroller?.menuBackgroundColor = Themes.grayA3AED020
        pageViewcontroller?.borderColor = .clear
        // menu text
        pageViewcontroller?.selectedFont = UIFont.systemFont(ofSize: 20)
        pageViewcontroller?.font = UIFont.systemFont(ofSize: 20)
        pageViewcontroller?.textColor = .black
        pageViewcontroller?.selectedTextColor = Themes.blue6149F6
        // menu indicator
        // 欄目可動
        pageViewcontroller?.menuInteraction = .none
        // 下方VC可動
        pageViewcontroller?.contentInteraction = .none
        pageViewcontroller?.indicatorColor = Themes.blue6149F6
        pageViewcontroller?.indicatorClass = RoundedIndicatorView.self
        pageViewcontroller?.indicatorOptions = .visible(height: 1,
                                                        zIndex: Int.max,
                                                        spacing: UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 15),
                                                        insets: UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15))
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
}
