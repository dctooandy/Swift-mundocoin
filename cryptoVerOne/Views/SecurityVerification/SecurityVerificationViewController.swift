//
//  SecurityVerificationViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/10.
//

import Foundation
import Parchment
import RxCocoa
import RxSwift
import SnapKit
enum SecurityViewMode {
    case defaultMode
    case selectedMode
    case onlyEmail
    case onlyMobile
//    case onlyTwoFA
}
class SecurityVerificationViewController: BaseViewController {
    // MARK:業務設定
    private let onVerifySuccessClick = PublishSubject<(String,String)>()
    private let onSelectedModeSuccessClick = PublishSubject<(String,String)>()
    private var dpg = DisposeBag()
    static let share: SecurityVerificationViewController = SecurityVerificationViewController.loadNib()
    var securityViewMode : SecurityViewMode = .defaultMode {
        didSet{
            dpg = DisposeBag()
            setupUI()
            bind()
        }
    }
    // MARK: -
    // MARK:UI 設定
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
//    var twoFAVerifyView = TwoFAVerifyView.loadNib()
    var twoWayVerifyView = TwoWayVerifyView.loadNib()
    var onlyEmailVerifyViewController = TwoWayVerifyViewController()
    var onlyMobileVerifyViewController = TwoWayVerifyViewController()
    var twoWayViewControllers = [TwoWayVerifyViewController]()
//    var onlyEmailVerifyViewController = TwoFAVerifyViewController()
//    var onlyTwoFAVerifyViewController = TwoFAVerifyViewController()
//    var twoFAViewControllers = [TwoFAVerifyViewController]()
    private var pageViewcontroller: PagingViewController<PagingIndexItem>?
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        title = "Security Verification"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        twoWayVerifyView.cleanTextField()
        onlyEmailVerifyViewController.verifyView.cleanTextField()
        onlyMobileVerifyViewController.verifyView.cleanTextField()
        resetHeightForView()
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        verifyResentAutoPressed(byMode: securityViewMode)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        twoWayVerifyView.cleanTimer()
        for vc in twoWayViewControllers
        {
            vc.cleanTimerAndResetProperty()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        twoWayVerifyView.removeFromSuperview()
        pageViewcontroller?.removeFromParent()
        pageViewcontroller?.view.removeFromSuperview()
        twoWayVerifyView = TwoWayVerifyView.loadNib()
        switch securityViewMode {
        case .selectedMode:
            setupSelectedUI()
        case .defaultMode:
            self.twoWayVerifyView.twoWayViewMode = .both
            view.addSubview(twoWayVerifyView)
        case .onlyEmail:
            self.twoWayVerifyView.twoWayViewMode = .onlyEmail
            view.addSubview(twoWayVerifyView)
        case .onlyMobile:
            self.twoWayVerifyView.twoWayViewMode = .onlyMobile
            view.addSubview(twoWayVerifyView)
        }
    }
    func setupSelectedUI()
    {
        setupPageVC()
        pageViewcontroller = PagingViewController<PagingIndexItem>()
        
        pageViewcontroller?.delegate = self
        pageViewcontroller?.dataSource = self
        // menu item
        pageViewcontroller?.menuItemSource = (.class(type: SecurityPagingTitleCell.self))

        pageViewcontroller?.selectedBackgroundColor = Themes.gray2B3674
        pageViewcontroller?.backgroundColor = .white
        pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: 95, height: 38)
        // menu text
        pageViewcontroller?.selectedFont = Fonts.PlusJakartaSansBold(15)
        pageViewcontroller?.font = Fonts.PlusJakartaSansBold(15)
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

    }
    func resetHeightForView()
    {
        let height = self.navigationController?.navigationBar.frame.maxY ?? 44
        switch securityViewMode {
        case .selectedMode:
            pageViewcontroller?.view.snp.remakeConstraints({ (make) in
                make.top.equalToSuperview().offset(height + 20)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        case .defaultMode,.onlyEmail,.onlyMobile:
            twoWayVerifyView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(height + 40)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
    }
    
    func bind()
    {
        bindSubPageViewControllers()
        bindAction()
    }
    func bindSubPageViewControllers()
    {
        // 只有Email時的驗證碼發送接收方法
        self.onlyEmailVerifyViewController.rxEmailSendVerifyAction().subscribeSuccess { [self](_) in
            Log.v("發送驗證傳送請求")
            verifyResentPressed(byEmail: true , byVC: true)
        }.disposed(by: dpg)
        // 只有Mobile時的驗證碼發送接收方法
        self.onlyMobileVerifyViewController.rxMobileSendVerifyAction().subscribeSuccess { [self](_) in
            Log.v("發送驗證傳送請求")
            verifyResentPressed(byEmail: false , byVC: true)
        }.disposed(by: dpg)
        
        self.onlyEmailVerifyViewController.rxSecondSubmitOnlyEmailAction().subscribeSuccess {[self](stringData) in
            Log.v("發送Second submit請求 ,onlyEmail:\(stringData)")
            onSelectedModeSuccessClick.onNext((stringData,"onlyEmail"))
        }.disposed(by: dpg)
        
        self.onlyMobileVerifyViewController.rxSecondSubmitOnlyMobileAction().subscribeSuccess {[self](stringData) in
            Log.v("發送Second submit請求 ,onlyMobile:\(stringData)")
            onSelectedModeSuccessClick.onNext((stringData,"onlyMobile"))
        }.disposed(by: dpg)
    }
    func bindAction()
    {
        // 可選頁面時的驗證碼接收方法
        self.twoWayVerifyView.rxEmailSecondSendVerifyAction().subscribeSuccess { [self](_) in
            Log.v("發送驗證傳送請求")
            verifyResentPressed(byEmail: true)
        }.disposed(by: dpg)
        self.twoWayVerifyView.rxMobileSecondSendVerifyAction().subscribeSuccess { [self](_) in
            Log.v("發送驗證傳送請求")
            verifyResentPressed(byEmail: false)
        }.disposed(by: dpg)
        self.twoWayVerifyView.rxSubmitBothAction().subscribeSuccess {[self](stringData) in
            Log.v("發送submit請求 ,Email:\(stringData.0) ,Mobile:\(stringData.1)")
            // 暫時取消推回
//            self.navigationController?.popViewController(animated: false)
            onVerifySuccessClick.onNext((stringData.0,stringData.1))
            twoWayVerifyView.resetProperty()
        }.disposed(by: dpg)
        self.twoWayVerifyView.rxSubmitOnlyEmailAction().subscribeSuccess {[self](stringData) in
            Log.v("發送View submit請求 ,onlyEmail:\(stringData)")
            onVerifySuccessClick.onNext((stringData,"onlyEmail"))
            twoWayVerifyView.resetProperty()
        }.disposed(by: dpg)
        self.twoWayVerifyView.rxSubmitOnlyMobileAction().subscribeSuccess {[self](stringData) in
            Log.v("發送View submit請求 ,onlyMobile:\(stringData)")
            onVerifySuccessClick.onNext((stringData,"onlyMobile"))
            twoWayVerifyView.resetProperty()
        }.disposed(by: dpg)
        self.twoWayVerifyView.rxLostGoogleAction().subscribeSuccess { [self](_) in
            Log.v("跳轉綁定Google Auth")
            let twoFAVC = TFFinishReViewController.loadNib()
            twoFAVC.viewMode = .reverify
            navigationController?.pushViewController(twoFAVC, animated: true)
            twoWayVerifyView.resetProperty()
        }.disposed(by: dpg)
    }

    func verifyResentAutoPressed(byMode: SecurityViewMode)
    {
        if byMode == .selectedMode
        {
//            onlyEmailVerifyViewController.verifyView.emailInputView.sendVerifyCode()
//            onlyMobileVerifyViewController.verifyView.mobileInputView.sendVerifyCode()
        }else if byMode == .defaultMode
        {
            twoWayVerifyView.emailInputView.resetTimerAndAll()
            twoWayVerifyView.mobileInputView.resetTimerAndAll()
        }else if byMode == .onlyEmail
        {
//            twoWayVerifyView.emailInputView.sendVerifyCode()
            twoWayVerifyView.emailInputView.resetTimerAndAll()
        }else
        {
//            twoWayVerifyView.mobileInputView.sendVerifyCode()
            twoWayVerifyView.mobileInputView.resetTimerAndAll()
        }
    }
    func verifyResentPressed(byEmail:Bool = false , byVC:Bool = false)
    {
        
        if let loginDto = KeychainManager.share.getLastAccountDto(), UserStatus.share.isLogin
        {
            let idString = (byEmail == true ? loginDto.account : loginDto.phone)
            Log.v("重發驗證")
            Beans.loginServer.verificationResend(idString: idString).subscribe { [self]dto in
                if let dataDto = dto
                {
                    var countTime = (dataDto.nextTimestamp - dataDto.currentTimestamp)/1000
                    if countTime <= Themes.verifyCountTime
                    {
                        countTime = Themes.verifyCountTime
                    }
                    resetCountDownNumber(byEmail:byEmail ,number: countTime,byVC: byVC)
                }
            } onError: { error in
                if let error = error as? ApiServiceError
                {
                    switch error {
                    case .errorDto(let dto):
                        let status = dto.httpStatus ?? ""
                        let reason = dto.reason
                        if status == "400"
                        {
                            let results = ErrorDefaultDto(code: dto.code, reason: reason, timestamp: 0, httpStatus: "", errors: [])
                            ErrorHandler.show(error: ApiServiceError.errorDto(results))
                        }else
                        {
                            ErrorHandler.show(error: error)
                        }
                    case .noData:
                        Log.v("註冊返回沒有資料")
                    default:
                        ErrorHandler.show(error: error)
                    }
                }
            }.disposed(by: dpg)
        }
    }
    func resetCountDownNumber(byEmail:Bool = false ,number:Int ,byVC:Bool)
    {
        if byVC == true
        {
            if byEmail == true
            {
                onlyEmailVerifyViewController.verifyView.emailInputView.setupCountTime(seconds: number)
            }else
            {
                onlyMobileVerifyViewController.verifyView.mobileInputView.setupCountTime(seconds: number)
            }
        }else
        {
            if byEmail == true
            {
                twoWayVerifyView.emailInputView.setupCountTime(seconds: number)
            }else
            {
                twoWayVerifyView.mobileInputView.setupCountTime(seconds: number)
            }
        }
    }

    private func setupPageVC() {
        let emailVC = TwoWayVerifyViewController.instance(mode: .onlyEmail)
        let mobileVC = TwoWayVerifyViewController.instance(mode: .onlyMobile)
        self.onlyEmailVerifyViewController = emailVC
        self.onlyMobileVerifyViewController = mobileVC
        twoWayViewControllers = [self.onlyMobileVerifyViewController,
                                self.onlyEmailVerifyViewController]
    }
    func rxVerifySuccessClick() -> Observable<(String,String)>
    {
        return onVerifySuccessClick.asObserver()
    }
    func rxSelectedModeSuccessClick() -> Observable<(String,String)>
    {
        return onSelectedModeSuccessClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸

extension SecurityVerificationViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T where T : PagingItem, T : Comparable, T : Hashable {
        return PagingIndexItem(index: index, title: twoWayViewControllers[index].modeTitle()) as! T
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T : PagingItem, T : Comparable, T : Hashable {
        return twoWayViewControllers[index]
    }
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int where T : PagingItem, T : Comparable, T : Hashable {
        return twoWayViewControllers.count
    }
}
struct PagingTitleCellViewModel {
  let title: String?
  let font: UIFont
  let selectedFont: UIFont
  let textColor: UIColor
  let selectedTextColor: UIColor
  let backgroundColor: UIColor
  let selectedBackgroundColor: UIColor
  let selected: Bool
  
  init(title: String?, selected: Bool, options: PagingOptions) {
    self.title = title
    self.font = options.font
    self.selectedFont = options.selectedFont
    self.textColor = options.textColor
    self.selectedTextColor = options.selectedTextColor
    self.backgroundColor = options.backgroundColor
    self.selectedBackgroundColor = options.selectedBackgroundColor
    self.selected = selected
  }
  
}
class SecurityPagingTitleCell: PagingTitleCell {
    var viewModel: PagingTitleCellViewModel?
    open override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
      if let titleItem = pagingItem as? PagingTitleItem {
        viewModel = PagingTitleCellViewModel(
          title: titleItem.title,
          selected: selected,
          options: options)
      }
      configureNewTitleLabel()
    }
    open func configureNewTitleLabel() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.title
        titleLabel.textAlignment = .center
        if viewModel.selected {
            titleLabel.font = viewModel.selectedFont
            titleLabel.textColor = viewModel.selectedTextColor
            titleLabel.backgroundColor = viewModel.selectedBackgroundColor
 
//            contentView.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMaxXMinYCorner]
        } else {
            titleLabel.font = viewModel.font
            titleLabel.textColor = viewModel.textColor
            titleLabel.backgroundColor = viewModel.backgroundColor

//            contentView.layer.maskedCorners = [.layerMinXMinYCorner , .layerMinXMaxYCorner]
        }
    }
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
      super.apply(layoutAttributes)
        titleLabel.layer.borderColor = UIColor.white.cgColor
        titleLabel.layer.borderWidth = 1.5
        titleLabel.layer.cornerRadius = 18.25
        titleLabel.layer.masksToBounds = true
        self.backgroundColor = Themes.grayE0E5F2
        self.contentView.backgroundColor = .white
//        self.contentView.applyCornerAndShadow(radius: layoutAttributes.frame.height / 2)
//        self.applyCornerAndShadow(radius: layoutAttributes.frame.height / 2)
        self.layer.cornerRadius = layoutAttributes.frame.height / 2
        self.contentView.layer.cornerRadius = 19
        if layoutAttributes.indexPath.last == 1
        {
            contentView.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(-1)
                make.centerY.equalToSuperview()
                make.width.equalTo(96)
                make.height.equalTo(38)
            }
            titleLabel.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(-1)
                make.centerY.equalToSuperview()
                make.width.equalTo(94.5)
                make.height.equalTo(36.5)
            }
            self.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMaxXMinYCorner]
            self.contentView.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMaxXMinYCorner]
        }else
        {
            contentView.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(1)
                make.centerY.equalToSuperview()
                make.width.equalTo(96)
                make.height.equalTo(38)
            }
            titleLabel.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(1)
                make.centerY.equalToSuperview()
                make.width.equalTo(94.5)
                make.height.equalTo(36.5)
            }
            self.layer.maskedCorners = [.layerMinXMinYCorner , .layerMinXMaxYCorner]
            self.contentView.layer.maskedCorners = [.layerMinXMinYCorner , .layerMinXMaxYCorner]
        }
        self.layer.masksToBounds = true
        self.contentView.layer.masksToBounds = true
//        layer.cornerRadius = layoutAttributes.frame.height / 2
//        if self.isSelected == true
//        {
//            titleLabel.backgroundColor = Themes.gray2B3674
////            clipsToBounds = true
//            if #available(iOS 11.0, *) {
//                layer.maskedCorners = [.layerMinXMinYCorner , .layerMinXMaxYCorner]
//            } else {
//                // Fallback on earlier versions
//            }
//        }else
//        {
//            titleLabel.backgroundColor = .white
//            if #available(iOS 11.0, *) {
//                layer.maskedCorners = [.layerMaxXMinYCorner , .layerMaxXMaxYCorner]
//            } else {
//                // Fallback on earlier versions
//            }
//        }
    }
    open override func layoutSubviews() {
      super.layoutSubviews()
//        contentView.snp.remakeConstraints { (make) in
//            make.centerX.equalToSuperview().offset(viewModel!.selected ? 1: -1)
//            make.centerY.equalToSuperview()
//            make.width.equalTo(123)
//            make.height.equalTo(46)
//        }
//        titleLabel.snp.remakeConstraints { (make) in
//            make.centerX.equalToSuperview().offset(viewModel!.selected ? 1: -1)
//            make.centerY.equalToSuperview()
//            make.width.equalTo(123)
//            make.height.equalTo(44)
//        }
    }
}
