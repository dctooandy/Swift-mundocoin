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
    case all
    case deposits
    case withdrawals
    
    var typeValue : String
    {
        switch self {
        case .all:
            return "ALL"
        case .deposits:
            return "DEPOSIT"
        case .withdrawals:
            return "WITHDRAW"
        }
    }
    
    func ascendType() -> Bool
    {
        switch self {
        case .all:
            return true
        case .deposits:
            return true
        case .withdrawals:
            return false
        }
    }
}
class BoardViewController: BaseViewController {
    // MARK:業務設定
    fileprivate var viewModel = BoardViewModel()
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var loadingDurarion:TimeInterval = 0
    var isFromWithdral = false
    var showMode : TransactionShowMode = .deposits{
        didSet{
            self.currentPage = 0
            self.clearAllVCDataSource()
            if isFilterAction == false
            {
                self.currentFilterDto = nil
                if loadingDurarion > 0
                {
                    self.goFetchTableViewData(duration:loadingDurarion)
                }else
                {
                    self.goFetchTableViewData()
                }
            }
        }
    }
    var transContentDto : [ContentDto] = [ContentDto()]
    var currentPage: Int = 0
    var currentFilterDto:WalletTransPostDto?
    var isFilterAction : Bool = false
    var isFilterAndChangeVCAction : Bool = false
    var isRefreshAction : Bool = false
    // MARK: -
    // MARK:UI 設定
    var allViewController : TransactionTableViewController!
    var depositsViewController : TransactionTableViewController!
    var withdrawalsViewController : TransactionTableViewController!
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
        // 暫時拿掉頁面監聽Socket事件
//        bindSocketMessage()
        currentPage = 0
//        goFetchTableViewData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
        if isFromWithdral == true
        {
            isFromWithdral = false
            self.pageViewcontroller?.select(index: 0)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    func setupPageContainerView()
    {
        pageViewcontroller = PagingViewController<PagingIndexItem>()
        
        pageViewcontroller?.delegate = self
        pageViewcontroller?.dataSource = self
        // menu item
        pageViewcontroller?.menuItemSource = (.class(type: BoardPagingTitleCell.self))

        pageViewcontroller?.selectedBackgroundColor = Themes.gray2B3674
        pageViewcontroller?.backgroundColor = .white
        pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: Views.sWidth(value: 124), height: Views.sHeight(value: 48))
        // menu text
        pageViewcontroller?.selectedFont = Fonts.PlusJakartaSansBold(15)
        pageViewcontroller?.font = Fonts.PlusJakartaSansMedium(15)
        pageViewcontroller?.textColor = Themes.grayA3AED0
        pageViewcontroller?.selectedTextColor = .white
        pageViewcontroller?.menuHorizontalAlignment = .center
        pageViewcontroller?.menuItemSpacing = 0
//        let image = UIImage().gradientImage(with: CGRect(x: 0, y: 0, width: Views.screenWidth, height: 44), colors: [Themes.grayF4F7FE.cgColor ,Themes.grayF4F7FE.cgColor, Themes.whiteFFFFFF.cgColor, Themes.whiteFFFFFF.cgColor ,Themes.grayF4F7FE.cgColor, Themes.grayF4F7FE.cgColor], locations: nil)
//        let bgImage = UIColor(patternImage: image!)
        pageViewcontroller?.menuBackgroundColor = Themes.grayF4F7FE
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
        self.allViewController = TransactionTableViewController.instance(mode: .all)
        self.depositsViewController = TransactionTableViewController.instance(mode: .deposits)
        self.withdrawalsViewController = TransactionTableViewController.instance(mode: .withdrawals)
        transTableViewControllers = [self.allViewController,
                                     self.depositsViewController,
                                     self.withdrawalsViewController]
        bindViewControllers()
    }
    func bindViewControllers()
    {
        
    }
    func goFetchTableViewData(duration:TimeInterval = 0.0)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {[self] in
            LoadingViewController.show()
            loadingDurarion = 0.0
            if let filterData = self.currentFilterDto , let filterDataType = filterData.historyType
            {
                viewModel.fetchWalletTransactions(currency: filterData.currency, stats: filterData.stats,type: filterDataType, beginDate: filterData.beginDate, endDate: filterData.endDate, pageable: PagePostDto(size: "20", page: String(currentPage)))
            }
            else
            {
                let dataDto : WalletTransPostDto = WalletTransPostDto()
                //                LoadingViewController.show()
                viewModel.fetchWalletTransactions(currency: dataDto.currency, stats: dataDto.stats,type: showMode.typeValue, beginDate: dataDto.beginDate, endDate: dataDto.endDate, pageable: PagePostDto(size: "20", page: String(currentPage)))
            }
        }
    }
    func clearAllVCDataSource()
    {
        allViewController.clearData()
        depositsViewController.clearData()
        withdrawalsViewController.clearData()
    }
    func bind()
    {
        viewModel.rxWalletTransactionsSuccess().subscribeSuccess { [self] dto in
            Log.v("交易紀錄Dto count : \(dto.content.count)")
            // 先隱藏 TRX
//            transContentDto = dto.content
            transContentDto = dto.content.filter({$0.currency != "TRX"})
            resetData()
        }.disposed(by: dpg)
        
        allViewController.rxPullDownToRefrash().subscribeSuccess { [self] _ in
            isFilterAction = false
            isFilterAndChangeVCAction = false
            showMode = .all
            isRefreshAction = true
            setFiletrActionFlag(flag: false)
        }.disposed(by: dpg)
        depositsViewController.rxPullDownToRefrash().subscribeSuccess { [self] _ in
            isFilterAction = false
            isFilterAndChangeVCAction = false
            showMode = .deposits
            isRefreshAction = true
            setFiletrActionFlag(flag: false)
        }.disposed(by: dpg)
        withdrawalsViewController.rxPullDownToRefrash().subscribeSuccess { [self] _ in
            isFilterAction = false
            isFilterAndChangeVCAction = false
            showMode = .withdrawals
            isRefreshAction = true
            setFiletrActionFlag(flag: false)
        }.disposed(by: dpg)
        
        allViewController.rxPullUpToAddRow().subscribeSuccess { [self] _ in
            currentPage += 1
            goFetchTableViewData(duration:0.0)
        }.disposed(by: dpg)
        
        depositsViewController.rxPullUpToAddRow().subscribeSuccess { [self] _ in
            currentPage += 1
            goFetchTableViewData(duration:0.0)
        }.disposed(by: dpg)
        
        withdrawalsViewController.rxPullUpToAddRow().subscribeSuccess { [self] _ in
            currentPage += 1
            goFetchTableViewData(duration:0.0)
        }.disposed(by: dpg)
    }
    func bindSocketMessage()
    {
        TXPayloadDto.rxShare.subscribeSuccess { dto in
            if let statsValue = dto?.state,
               let socketID = dto?.id,
               let amount = dto?.txAmountIntWithDecimal,
               var currentTransDto = self.transContentDto.filter({$0.id == socketID}).first,
               let currentTransIndex = self.transContentDto.firstIndex(where: { p in p.id == socketID })
            {
                if self.transContentDto[currentTransIndex].state != statsValue
                {
//                    if statsValue == "PROCESSING"
//                    {
//                        let newamount = (amount.intValue ?? 1) - 1
//                        currentTransDto.amount = JSONValue.int(newamount)
//                    }
                    currentTransDto.amount = amount
                    currentTransDto.state = statsValue
                    self.transContentDto.remove(at: currentTransIndex)
                    self.transContentDto.insert(currentTransDto, at: currentTransIndex)
                    self.clearAllVCDataSource()
                    self.resetData()
                }
            }
        }.disposed(by: dpg)
    }
    func resetData()
    {
        let depositData = transContentDto.filter{$0.type == "DEPOSIT"}
        let withdrawData = transContentDto.filter{$0.type == "WITHDRAW"}
        let allData = transContentDto.filter{$0.type == "WITHDRAW" || $0.type == "DEPOSIT"}
        allViewController.data = allData
        depositsViewController.data = depositData
        withdrawalsViewController.data = withdrawData
        pageViewcontroller?.reloadMenu()
    }
    func setFiletrActionFlag(flag :Bool = true)
    {
        allViewController.isFilterAction = flag
        depositsViewController.isFilterAction = flag
        withdrawalsViewController.isFilterAction = flag
    }
    @objc func filterActionSheet() {
        Log.v("開啟過濾Sheet")
        let filterBottomSheet = FilterBottomSheet()
        filterBottomSheet.showModeAtSheet = showMode
        filterBottomSheet.rxConfirmClick().subscribeSuccess { [weak self]dataDto in
            var pageIndex = 0
            self?.isFilterAction = true
            self?.currentPage = 0
            self?.clearAllVCDataSource()
            self?.setFiletrActionFlag(flag: false)
            var newShowMode:TransactionShowMode
            if dataDto.historyType == "WITHDRAW"
            {
                pageIndex = 2
                newShowMode = .withdrawals
                self?.withdrawalsViewController.isFilterAction = true
            }else if dataDto.historyType == "DEPOSIT"
            {
                pageIndex = 1
                newShowMode = .deposits
                self?.depositsViewController.isFilterAction = true
            }else
            {
                pageIndex = 0
                newShowMode = .all
                self?.allViewController.isFilterAction = true
            }

            if self?.showMode != newShowMode
            {
                self?.isFilterAndChangeVCAction = true
            }else
            {
                self?.isFilterAndChangeVCAction = false
            }
            // filter資料
            self?.currentFilterDto = dataDto
            // 先呼叫 pageController 上面的頁面 但不驅動撈資料
            self?.pageViewcontroller?.select(index: pageIndex)
            // 正式撈資料
            self?.goFetchTableViewData(duration: 0.0)
        }.disposed(by: dpg)
        DispatchQueue.main.async { [self] in
            if KeychainManager.share.getMundoCoinNetworkMethodEnable() == true
            {
                filterBottomSheet.start(viewController: self ,height: 533.0 + Views.bottomOffset)
            }else
            {
                filterBottomSheet.start(viewController: self ,height: 467.0 + Views.bottomOffset)
            }
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
//    func pagingViewController<T>(
//      _ pagingViewController: PagingViewController<T>,
//      willScrollToItem pagingItem: T,
//      startingViewController: UIViewController,
//      destinationViewController: UIViewController)
//    {
//        if let pageItem = pagingItem as? PagingIndexItem
//        {
//            showMode = pageItem.index == 0 ? .deposits : .withdrawals
//            Log.v("pagingItem :\(pageItem.index)")
//        }
//    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
        if let pageItem = pagingItem as? PagingIndexItem
        {
            let newShowMode:TransactionShowMode = (pageItem.index == 0 ? .all : pageItem.index == 1 ? .deposits : .withdrawals)
            if isRefreshAction != true
            {
                if isFilterAndChangeVCAction == false , isFilterAction == true
                {
                    isFilterAction = false
                }
                showMode = newShowMode
            }
            if isFilterAndChangeVCAction == true , isFilterAction == true
            {
                isFilterAndChangeVCAction = false
            }
            isFilterAction = false
            isRefreshAction = false
            Log.v("pagingItem :\(pageItem.index)")
        }
    }
}
