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
enum SecurityViewMode {
    case defaultMode
    case selectedMode
    case onlyEmail
    case onlyTwoFA
}
class SecurityVerificationViewController: BaseViewController {
    // MARK:業務設定
    private let onVerifySuccessClick = PublishSubject<Any>()
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
    var twoFAVerifyView = TwoFAVerifyView.loadNib()
    var onlyEmailVerifyViewController = TwoFAVerifyViewController()
    var onlyTwoFAVerifyViewController = TwoFAVerifyViewController()
    private var pageViewcontroller: PagingViewController<PagingIndexItem>?
    private var twoFAViewControllers = [TwoFAVerifyViewController]()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Security Verification"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        twoFAVerifyView.cleanTextField()
        onlyEmailVerifyViewController.verifyView.cleanTextField()
        onlyTwoFAVerifyViewController.verifyView.cleanTextField()
        resetHeightForView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        self.twoFAVerifyView.rxSecondSendVerifyAction().subscribeSuccess { (_) in
            Log.i("發送驗證傳送請求")
        }.disposed(by: dpg)
        self.twoFAVerifyView.rxSubmitBothAction().subscribeSuccess {[self](stringData) in
            Log.i("發送submit請求 ,Email:\(stringData.0) ,2FA:\(stringData.1)")
            self.navigationController?.popViewController(animated: false)
            onVerifySuccessClick.onNext(())
            
        }.disposed(by: dpg)
        self.twoFAVerifyView.rxSubmitOnlyEmailAction().subscribeSuccess {[self](stringData) in
            Log.i("發送View submit請求 ,onlyEmail:\(stringData)")
            onVerifySuccessClick.onNext(())
        }.disposed(by: dpg)
        self.twoFAVerifyView.rxSubmitOnlyTwiFAAction().subscribeSuccess {[self](stringData) in
            Log.i("發送View submit請求 ,onlyTwoFA:\(stringData)")
            onVerifySuccessClick.onNext(())
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
        self.onlyTwoFAVerifyViewController.rxThirdSendVerifyAction().subscribeSuccess { (stringData) in
            Log.i("發送驗證傳送請求")
        }.disposed(by: dpg)
        
        self.onlyEmailVerifyViewController.rxSecondSubmitOnlyEmailAction().subscribeSuccess {[self](stringData) in
            Log.i("發送Second submit請求 ,onlyEmail:\(stringData)")
            onVerifySuccessClick.onNext(())
        }.disposed(by: dpg)
        
        self.onlyTwoFAVerifyViewController.rxSecondSubmitOnlyTwoFAAction().subscribeSuccess {[self](stringData) in
            Log.i("發送Second submit請求 ,onlyTwoFA:\(stringData)")
            onVerifySuccessClick.onNext(())
        }.disposed(by: dpg)
    }

    func setupSelectedUI()
    {
        setupPageVC()
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
        let image = UIImage().gradientImage(with: CGRect(x: 0, y: 0, width: 375, height: 38), colors: [Themes.grayF4F7FE.cgColor , Themes.whiteFFFFFF.cgColor , Themes.grayF4F7FE.cgColor], locations: nil)

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
    func rxVerifySuccessClick() -> Observable<Any>
    {
        return onVerifySuccessClick.asObserver()
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
class SecurityPagingTitleCell: PagingTitleCell {
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
      super.apply(layoutAttributes)
        titleLabel.layer.borderColor = UIColor.white.cgColor
        titleLabel.layer.borderWidth = 3
        titleLabel.layer.cornerRadius = layoutAttributes.frame.height / 2
        layer.cornerRadius = layoutAttributes.frame.height / 2
//        if self.isSelected == true
//        {
//            titleLabel.backgroundColor = Themes.blue2B3674
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
}
