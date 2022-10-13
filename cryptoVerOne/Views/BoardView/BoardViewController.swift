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
    
    var typeValue : String
    {
        switch self {
        case .deposits:
            return "DEPOSIT"
        case .withdrawals:
            return "WITHDRAW"
        }
    }
    var showTitleString:String
    {
        switch self {
        case .deposits:
            return "Deposit Details".localized
        case .withdrawals:
            return "Withdrawal Details".localized
        }
    }
    
    func ascendType() -> Bool
    {
        switch self {
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
            self.currentFilterDto = nil
            self.currentPage = 0
            self.clearAllVCDataSource()
            if isFilterAction != true
            {
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
            self.pageViewcontroller?.select(index: 1)
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
        pageViewcontroller?.menuItemSource = (.class(type: SecurityPagingTitleCell.self))

        pageViewcontroller?.selectedBackgroundColor = Themes.gray2B3674
        pageViewcontroller?.backgroundColor = .white
        pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: 124, height: 48)
        // menu text
        pageViewcontroller?.selectedFont = Fonts.PlusJakartaSansBold(15)
        pageViewcontroller?.font = Fonts.PlusJakartaSansBold(15)
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
        self.depositsViewController = TransactionTableViewController.instance(mode: .deposits)
        self.withdrawalsViewController = TransactionTableViewController.instance(mode: .withdrawals)
        transTableViewControllers = [self.depositsViewController,
                                     self.withdrawalsViewController]
        bindViewControllers()
    }
    func bindViewControllers()
    {
        
    }
    func goFetchTableViewData(filterDto : WalletTransPostDto = WalletTransPostDto() , duration:TimeInterval = 0.0)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {[self] in
            LoadingViewController.show()
            loadingDurarion = 0.0
            if let data = self.currentFilterDto , let dataType = data.historyType
            {
                viewModel.fetchWalletTransactions(currency: data.currency, stats: data.stats,type: dataType, beginDate: data.beginDate, endDate: data.endDate, pageable: PagePostDto(size: "20", page: String(currentPage)))
                isFilterAndChangeVCAction = false
            }
            else
            {
                if isFilterAndChangeVCAction == false
                {
                    //                LoadingViewController.show()
                    viewModel.fetchWalletTransactions(currency: filterDto.currency, stats: filterDto.stats,type: showMode.typeValue, beginDate: filterDto.beginDate, endDate: filterDto.endDate, pageable: PagePostDto(size: "20", page: String(currentPage)))
                }
                isFilterAndChangeVCAction = false
            }
        }
    }
    func clearAllVCDataSource()
    {
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
        
        depositsViewController.rxPullDownToRefrash().subscribeSuccess { [self] _ in
            isFilterAction = false
            showMode = .deposits
            isRefreshAction = true
        }.disposed(by: dpg)
        withdrawalsViewController.rxPullDownToRefrash().subscribeSuccess { [self] _ in
            isFilterAction = false
            showMode = .withdrawals
            isRefreshAction = true
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
                    if statsValue == "PROCESSING"
                    {
                        let newamount = (amount.intValue ?? 1) - 1
                        currentTransDto.amount = JSONValue.int(newamount)
                    }
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
        depositsViewController.data = depositData
        withdrawalsViewController.data = withdrawData
        pageViewcontroller?.reloadMenu()
    }
    func setFiletrActionFlag()
    {
        depositsViewController.isFilterAction = true
        withdrawalsViewController.isFilterAction = true
    }
    @objc func filterActionSheet() {
        Log.i("開啟過濾Sheet")
        let filterBottomSheet = FilterBottomSheet()
        filterBottomSheet.showModeAtSheet = showMode
        filterBottomSheet.rxConfirmClick().subscribeSuccess { [weak self]dataDto in
            self?.isFilterAction = true
            self?.isFilterAndChangeVCAction = true
            self?.currentPage = 0
            self?.clearAllVCDataSource()
            self?.setFiletrActionFlag()
            if dataDto.historyType == "WITHDRAW"
            {
                self?.pageViewcontroller?.select(index: 1)
            }else
            {
                self?.pageViewcontroller?.select(index: 0)
            }
            self?.currentFilterDto = dataDto
            self?.goFetchTableViewData(filterDto: dataDto ,duration: 0.0)
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
            if isRefreshAction != true
            {
                showMode = pageItem.index == 0 ? .deposits : .withdrawals
            }
            isFilterAction = false
            isRefreshAction = false
            Log.v("pagingItem :\(pageItem.index)")
        }
    }
}

