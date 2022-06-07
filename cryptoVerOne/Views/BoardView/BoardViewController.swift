//
//  BoardViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import RxCocoa
import RxSwift
import Parchment

enum TransactionShowMode
{
    case deposits
    case withdrawals
}
class BoardViewController: BaseViewController {
    // MARK:業務設定
    fileprivate var viewModel = BoardViewModel()
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var showMode : TransactionShowMode = .deposits{
        didSet{

        }
    }
    // MARK: -
    // MARK:UI 設定
    var depositsViewController = TransactionTableViewController()
    var withdrawalsViewController = TransactionTableViewController()
    private var pageViewcontroller: PagingViewController<PagingIndexItem>?
    private var transTableViewControllers = [TransactionTableViewController]()
    private lazy var filterButton:UIButton = {
        let filterBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
        let image = UIImage(named:"icon-Filter")
        filterBtn.setImage(image, for: .normal)
        filterBtn.addTarget(self, action:#selector(filterActionSheet), for:.touchUpInside)
        return filterBtn
    }()
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transaction History"
        view.backgroundColor = Themes.grayF4F7FE
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        setupUI()
        bind()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchWalletTransactions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        setupPageVC()
        setupPageContainerView()
    }
    func bind()
    {
        viewModel.rxWalletTransactionsSuccess().subscribeSuccess { dto in
            Log.v("交易紀錄Dto : \(dto)")
        }.disposed(by: dpg)
    }
    func setupPageContainerView()
    {
        pageViewcontroller = PagingViewController<PagingIndexItem>()
        
        pageViewcontroller?.delegate = self
        pageViewcontroller?.dataSource = self
        // menu item
        pageViewcontroller?.menuItemSource = (.class(type: SecurityPagingTitleCell.self))

        pageViewcontroller?.selectedBackgroundColor = Themes.blue2B3674
        pageViewcontroller?.backgroundColor = .white
        pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: 120, height: 38)
        // menu text
        pageViewcontroller?.selectedFont = UIFont.systemFont(ofSize: 15)
        pageViewcontroller?.font = UIFont.systemFont(ofSize: 15)
        pageViewcontroller?.textColor = Themes.grayA3AED0
        pageViewcontroller?.selectedTextColor = .white
        pageViewcontroller?.menuHorizontalAlignment = .center
        pageViewcontroller?.menuItemSpacing = 0
        let image = UIImage().gradientImage(with: CGRect(x: 0, y: 0, width: Views.screenWidth, height: 38), colors: [Themes.grayF4F7FE.cgColor ,Themes.grayF4F7FE.cgColor, Themes.whiteFFFFFF.cgColor, Themes.whiteFFFFFF.cgColor ,Themes.grayF4F7FE.cgColor, Themes.grayF4F7FE.cgColor], locations: nil)

        let bgImage = UIColor(patternImage: image!)
        pageViewcontroller?.menuBackgroundColor = bgImage
        pageViewcontroller?.borderColor = .clear
     
        // menu indicator
        // 欄目可動
        pageViewcontroller?.menuInteraction = .none
        // 下方VC可動
        pageViewcontroller?.contentInteraction = .none
        pageViewcontroller?.indicatorColor = .clear

        addChild(pageViewcontroller!)
        view.addSubview(pageViewcontroller!.view)
        pageViewcontroller?.view.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().offset(Views.topOffset + 12.0)
            make.left.right.bottom.equalToSuperview()
        })
        
    }
    func setupPageVC()
    {
        let depositsVC = TransactionTableViewController.instance(mode: .deposits)
        let withdrawalsVC = TransactionTableViewController.instance(mode: .withdrawals)
        self.depositsViewController = depositsVC
        self.withdrawalsViewController = withdrawalsVC
        transTableViewControllers = [self.depositsViewController,
                                     self.withdrawalsViewController]
        bindViewControllers()
    }
    func bindViewControllers()
    {
        
    }
    @objc func filterActionSheet() {
        Log.i("開啟過濾Sheet")
        let filterBottomSheet = FilterBottomSheet()
        filterBottomSheet.showModeAtSheet = showMode
        filterBottomSheet.rxConfirmClick().subscribeSuccess { [weak self]dataDto in
            self?.viewModel.fetchWalletTransactions(currency: dataDto.currency, stats: dataDto.stats, beginDate: dataDto.beginDate, endDate: dataDto.endDate, pageable: dataDto.pageable)
        }.disposed(by: dpg)
        DispatchQueue.main.async { [self] in
            filterBottomSheet.start(viewController: self ,height: 508)
        }
    }
}
// MARK: -
// MARK: 延伸
extension BoardViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T where T : PagingItem, T : Comparable, T : Hashable {
        return PagingIndexItem(index: index, title: transTableViewControllers[index].modeTitle()) as! T
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T : PagingItem, T : Comparable, T : Hashable {
        return transTableViewControllers[index]
    }
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int where T : PagingItem, T : Comparable, T : Hashable {
        return transTableViewControllers.count
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
        if let pageItem = pagingItem as? PagingIndexItem
        {
            showMode = pageItem.index == 0 ? .deposits : .withdrawals
            Log.v("pagingItem :\(pageItem.index)")
        }
    }
}

