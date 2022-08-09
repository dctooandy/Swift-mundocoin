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
    case onlyTwoFA
}
class SecurityVerificationViewController: BaseViewController {
    // MARK:業務設定
    private let onVerifySuccessClick = PublishSubject<(String,String)>()
    private let onSelectedModeSuccessClick = PublishSubject<(String,String)>()
    private let dpg = DisposeBag()
    static let share: SecurityVerificationViewController = SecurityVerificationViewController.loadNib()
    var securityViewMode : SecurityViewMode = .defaultMode {
        didSet{
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
    var twoFAVerifyView = TwoFAVerifyView.loadNib()
    var onlyEmailVerifyViewController = TwoFAVerifyViewController()
    var onlyTwoFAVerifyViewController = TwoFAVerifyViewController()
    private var pageViewcontroller: PagingViewController<PagingIndexItem>?
    var twoFAViewControllers = [TwoFAVerifyViewController]()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        title = "Security Verification"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        twoFAVerifyView.cleanTextField()
        onlyEmailVerifyViewController.verifyView.cleanTextField()
        onlyTwoFAVerifyViewController.verifyView.cleanTextField()
        resetHeightForView()
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        verifyResentAutoPressed(byMode: securityViewMode)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        twoFAVerifyView.cleanTimer()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        switch securityViewMode {
        case .selectedMode:
            break
        case .defaultMode,.onlyEmail,.onlyTwoFA:
            view.addSubview(twoFAVerifyView)
           
        }
        resetUI()
    }
    func resetHeightForView()
    {
        let height = self.navigationController?.navigationBar.frame.maxY ?? 44
        switch securityViewMode {
        case .selectedMode:
            pageViewcontroller?.view.snp.remakeConstraints({ (make) in
                make.top.equalToSuperview().offset(height + 40)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        case .defaultMode,.onlyEmail,.onlyTwoFA:
            twoFAVerifyView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(height + 40)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
    }
    func resetUI()
    {
        switch securityViewMode {
        case .defaultMode:
            self.twoFAVerifyView.twoFAViewMode = .both
        case .selectedMode:
            setupSelectedUI()
        case .onlyEmail:
            self.twoFAVerifyView.twoFAViewMode = .onlyEmail
        case .onlyTwoFA:
            self.twoFAVerifyView.twoFAViewMode = .onlyTwoFA
        }
    }
    func bind()
    {
        bindAction()
    }
    func bindAction()
    {
        // 可選頁面時的驗證碼接收方法
        self.twoFAVerifyView.rxSecondSendVerifyAction().subscribeSuccess { [self](_) in
            Log.i("發送驗證傳送請求")
            verifyResentPressed()
        }.disposed(by: dpg)
        self.twoFAVerifyView.rxSubmitBothAction().subscribeSuccess {[self](stringData) in
            Log.i("發送submit請求 ,Email:\(stringData.0) ,2FA:\(stringData.1)")
            // 暫時取消推回
//            self.navigationController?.popViewController(animated: false)
            onVerifySuccessClick.onNext((stringData.0,stringData.1))
            
        }.disposed(by: dpg)
        self.twoFAVerifyView.rxSubmitOnlyEmailAction().subscribeSuccess {[self](stringData) in
            Log.i("發送View submit請求 ,onlyEmail:\(stringData)")
            onVerifySuccessClick.onNext((stringData,""))
        }.disposed(by: dpg)
        self.twoFAVerifyView.rxSubmitOnlyTwiFAAction().subscribeSuccess {[self](stringData) in
            Log.i("發送View submit請求 ,onlyTwoFA:\(stringData)")
            onVerifySuccessClick.onNext((stringData,""))
        }.disposed(by: dpg)
        self.twoFAVerifyView.rxLostGoogleAction().subscribeSuccess { (_) in
            Log.i("跳轉綁定Google Auth")
            let twoFAVC = TFFinishReViewController.loadNib()
            twoFAVC.viewMode = .reverify
            self.navigationController?.pushViewController(twoFAVC, animated: true)
        }.disposed(by: dpg)
        
    }
    func bindSubPageViewControllers()
    {
        // 只有Email時的驗證碼發送接收方法
        self.onlyEmailVerifyViewController.rxThirdSendVerifyAction().subscribeSuccess { [self](_) in
            Log.i("發送驗證傳送請求")
            verifyResentPressed( byVC: true)
        }.disposed(by: dpg)
        
        self.onlyEmailVerifyViewController.rxSecondSubmitOnlyEmailAction().subscribeSuccess {[self](stringData) in
            Log.i("發送Second submit請求 ,onlyEmail:\(stringData)")
            onSelectedModeSuccessClick.onNext((stringData,"onlyEmail"))
        }.disposed(by: dpg)
        
        self.onlyTwoFAVerifyViewController.rxSecondSubmitOnlyTwoFAAction().subscribeSuccess {[self](stringData) in
            Log.i("發送Second submit請求 ,onlyTwoFA:\(stringData)")
            onSelectedModeSuccessClick.onNext((stringData,"onlyTwoFA"))
        }.disposed(by: dpg)
    }
    func verifyResentAutoPressed(byMode: SecurityViewMode)
    {
        if byMode == .selectedMode
        {
            onlyEmailVerifyViewController.verifyView.emailInputView.emailSendVerify()
        }else
        {
            twoFAVerifyView.emailInputView.emailSendVerify()
        }
    }
    func verifyResentPressed(byVC:Bool = false)
    {
        let loginDto = KeychainManager.share.getLastAccount()
        if let userEmail = loginDto?.account , UserStatus.share.isLogin
        {
            Log.v("重發驗證")
            Beans.loginServer.verificationResend(idString: userEmail).subscribe { [self]dto in
                if let dataDto = dto
                {
                    let countTime = (dataDto.nextTimestamp - dataDto.currentTimestamp)/1000
                    resetCountDownNumber(number: countTime,byVC: byVC)
                }
            } onError: { error in
                ErrorHandler.show(error: error)
            }.disposed(by: dpg)
        }
    }
    func resetCountDownNumber(number:Int ,byVC:Bool)
    {
        if byVC == true
        {
            onlyEmailVerifyViewController.verifyView.emailInputView.setupCountTime(seconds: number)
        }else
        {
            twoFAVerifyView.emailInputView.setupCountTime(seconds: number)
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
        pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: 120, height: 38)
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
    private func setupPageVC() {
        let emailVC = TwoFAVerifyViewController.instance(mode: .onlyEmail)
        let twoFAVC = TwoFAVerifyViewController.instance(mode: .onlyTwoFA)
        self.onlyEmailVerifyViewController = emailVC
        self.onlyTwoFAVerifyViewController = twoFAVC
        twoFAViewControllers = [self.onlyEmailVerifyViewController,
                                self.onlyTwoFAVerifyViewController]
        bindSubPageViewControllers()
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
        return PagingIndexItem(index: index, title: index == 0 ? "E-mail":"2FA") as! T
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T : PagingItem, T : Comparable, T : Hashable {
        return twoFAViewControllers[index]
    }
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int where T : PagingItem, T : Comparable, T : Hashable {
        return twoFAViewControllers.count
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
        titleLabel.layer.borderWidth = 3
        titleLabel.layer.cornerRadius = 22
        titleLabel.layer.masksToBounds = true
        self.backgroundColor = Themes.grayE0E5F2
        self.contentView.backgroundColor = .white
//        self.contentView.applyCornerAndShadow(radius: layoutAttributes.frame.height / 2)
//        self.applyCornerAndShadow(radius: layoutAttributes.frame.height / 2)
        self.layer.cornerRadius = layoutAttributes.frame.height / 2
        self.contentView.layer.cornerRadius = 22
        if layoutAttributes.indexPath.last == 1
        {
            contentView.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(-1)
                make.centerY.equalToSuperview()
                make.width.equalTo(123)
                make.height.equalTo(46)
            }
            titleLabel.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(-1)
                make.centerY.equalToSuperview()
                make.width.equalTo(123)
                make.height.equalTo(44)
            }
            self.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMaxXMinYCorner]
            self.contentView.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMaxXMinYCorner]
        }else
        {
            contentView.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(1)
                make.centerY.equalToSuperview()
                make.width.equalTo(123)
                make.height.equalTo(46)
            }
            titleLabel.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview().offset(1)
                make.centerY.equalToSuperview()
                make.width.equalTo(123)
                make.height.equalTo(44)
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
