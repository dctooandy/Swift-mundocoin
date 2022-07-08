//
//  AuditTabbarViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/6/12.
//

import Foundation
import RxCocoa
import RxSwift
import SnapKit

class AuditTabbarViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static var share = AuditTabbarViewController()
    // MARK: -
    // MARK:UI 設定
    lazy var todoPageVC:MDNavigationController = {
        let todoVC = TodoListViewController.loadNib()
        todoVC.currentShowMode = .pending
        let todoNavVC = MDNavigationController(rootViewController: todoVC)
        let vc = todoNavVC
        return vc
    }()
    lazy var accountPageVC:MDNavigationController = {
        let accountVC = AccountViewController.loadNib()
        let accountNavVC = MDNavigationController(rootViewController: accountVC)
        let vc = accountNavVC
        return vc
    }()
    let tabbar = AuditTabbar.share
    var topConstraint: Constraint?
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
    init() {
        super.init()
        initData()
    }
    // MARK: -
    // MARK:業務方法
   
   required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       initData()
   }
   private func initData(){
       setupTabbar()
       settingViewControllers()
       bindTabbar()
       bindFanmenu()
       tabbar.selected(0)
   }
    private func setupTabbar(){
        view.addSubview(tabbar)
        tabbar.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview()
            topConstraint = make.top.equalToSuperview().offset(Views.screenHeight - Views.baseTabbarHeight).constraint
        }
    }
    private func settingViewControllers() {
        naviBackBtn.isHidden = true
        addChild(todoPageVC)
//        todoPageVC.mdBackBtn.isHidden = true
        addChild(accountPageVC)
        view.addSubview(todoPageVC.view)
        view.addSubview(accountPageVC.view)

        todoPageVC.view.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(strongSelf.tabbar.snp.top)
        }
    }
    private func bindTabbar(){
        tabbar.rxItemClick.subscribeSuccess {[weak self](index) in
            guard let weakSelf = self else { return }
            if !UserStatus.share.isLogin && index > 1 {
                weakSelf.present(LoginAlert(), animated: true, completion: nil)
                return
            }
            weakSelf.statusStyle = .default
            switch index {
            case 0:
                weakSelf.statusStyle = .default
                weakSelf.view.bringSubviewToFront(weakSelf.todoPageVC.view)
                weakSelf.todoPageVC.didMove(toParent: self)
            case 1:
                weakSelf.view.bringSubviewToFront(weakSelf.accountPageVC.view)
                weakSelf.accountPageVC.didMove(toParent: self)
            
            default:
                break
            }
            weakSelf.tabbar.bringToFront()
        }.disposed(by: disposeBag)
//        tabbar.rxLabelClick().subscribeSuccess { [self] accept in
//            tabbar.detailTabbarView.isHidden = true
//            Log.v("結果\(accept)")
//            UIApplication.topViewController()?.navigationController?.popToRootViewController(animated: true)
//
//        }.disposed(by: dpg)
    }
    func selected(_ index:Int) {
        tabbar.selected(index)
    }
    private func bindFanmenu() {
//        tabbar.rxMenuClick.subscribeSuccess { (menuType) in
//            guard let topVC = UIApplication.topViewController() else { return }
//            if menuType == .service {
////                LiveChatService.share.betLeadServicePresent()
//                return
//            }
////            topVC.present(BetLeadWebViewController(menuType.urlStr), animated: true, completion: nil)
//            print("跳出客服")
//        }.disposed(by: disposeBag)
    }
}
// MARK: -
// MARK: 延伸
