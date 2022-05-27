//
//  LoginPageViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import UIKit
import Parchment
import RxSwift

class LoginPageViewController: BaseViewController {
    // MARK:業務設定
    private let verifyCodeBtnClick = PublishSubject<String>()
    private let signupBtnClick = PublishSubject<SignupPostDto>()
    private let loginBtnClick = PublishSubject<LoginPostDto>()
    private let resetLinkBtnClick = PublishSubject<LoginPostDto>()
    private let forgetBtnClick = PublishSubject<Void>()
    private var currentShowMode: ShowMode = .loginEmail {
        didSet {
            cleanTextField()
//            if currentShowMode == .forgotPW
//            {
//                pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: 110, height: 50)
//                pageViewcontroller?.indicatorColor = .black
//            }else
//            {
//                pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: 110, height: 0)
//                pageViewcontroller?.indicatorColor = .clear
//            }
            pageViewcontroller?.reloadData()
        }
    }
    // MARK: -
    // MARK:UI 設定
    private var pageViewcontroller: PagingViewController<PagingIndexItem>?
    var loginViewControllers = [LoginViewController]()
    var signupViewControllers = [SignupViewController]()
    var forgotViewControllers = [ForgotViewController]()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupMenu()
    }
    // MARK: -
    // MARK:業務方法
    private func setupMenu() {
        pageViewcontroller = PagingViewController<PagingIndexItem>()
        pageViewcontroller?.delegate = self
        pageViewcontroller?.dataSource = self
        // menu item
        pageViewcontroller?.menuItemSize = PagingMenuItemSize.fixed(width: 110, height: 0)
        pageViewcontroller?.menuHorizontalAlignment = .left
        pageViewcontroller?.menuItemSpacing = 20
        pageViewcontroller?.menuBackgroundColor = .clear
        pageViewcontroller?.borderColor = .clear
        // menu text
        pageViewcontroller?.selectedFont = UIFont.systemFont(ofSize: 20)
        pageViewcontroller?.font = UIFont.systemFont(ofSize: 20)
        pageViewcontroller?.textColor = .black
        pageViewcontroller?.selectedTextColor = .black
        // menu indicator
        // 欄目可動
        pageViewcontroller?.menuInteraction = .none
        // 下方VC可動
        pageViewcontroller?.contentInteraction = .none
        pageViewcontroller?.indicatorColor = .clear
        pageViewcontroller?.indicatorClass = RoundedIndicatorView.self
        pageViewcontroller?.indicatorOptions = .hidden
        addChild(pageViewcontroller!)
        view.addSubview(pageViewcontroller!.view)
        pageViewcontroller?.view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    private func setupVC() {
        let accLogin = LoginViewController.instance(mode: .emailPage)
//        let phoneLogin = LoginViewController.instance(mode: .phone)
        let accSignup = SignupViewController.instance(mode: .emailPage)
//        let phoneSignup = SignupViewController.instance(mode: .phone)
        let accForgot = ForgotViewController.instance(mode: .emailPage)
        loginViewControllers = [accLogin]
        //            bindVerifyCodeBtn(obs: phoneLogin.rxVerifyCodeButtonClick)
        signupViewControllers = [accSignup]
        //            bindVerifyCodeBtn(obs: phoneSignup.rxVerifyCodeButtonClick)
        forgotViewControllers = [accForgot]
        bindLoginViewControllers()
        bindSingupViewControllers()
        bindForgotViewControllers()
    }
    private func cleanTextField() {
        loginViewControllers.forEach({$0.cleanTextField()})
        signupViewControllers.forEach({$0.cleanTextField()})
        forgotViewControllers.forEach({$0.cleanTextField()})
    }
    
//    func reloadPageMenu(isLogin: Bool) {
//        self.isLogin = isLogin
//        DispatchQueue.main.async {[weak self] in
//            self?.pageViewcontroller?.reloadData()
//        }
//    }
    func reloadPageMenu(currentMode: ShowMode) {
        self.currentShowMode = currentMode
        DispatchQueue.main.async {[weak self] in
            self?.pageViewcontroller?.reloadData()
        }
    }
    
    func startReciprocal() {
        switch currentShowMode {
        case .loginEmail:
            loginViewControllers[1].startReciprocal()
        case .loginPhone:
            signupViewControllers[1].startReciprocal()
        case .signupEmail:
            loginViewControllers[1].startReciprocal()
        case .signupPhone:
            signupViewControllers[1].startReciprocal()
        case .forgotPW:
            break
//            forgotViewControllers[1].startReciprocal()
        }
//        if isLogin {
//            loginViewControllers[1].startReciprocal()
//        } else {
//            signupViewControllers[1].startReciprocal()
//        }
    }
    
    func setVerifyCode(code: String) {
        switch currentShowMode {
        case .loginEmail:
            loginViewControllers[1].showVerifyCode(code)
        case .loginPhone:
            loginViewControllers[1].showVerifyCode(code)
        case .signupEmail:
            signupViewControllers[1].showVerifyCode(code)
        case .signupPhone:
            signupViewControllers[1].showVerifyCode(code)
        case .forgotPW:
            forgotViewControllers[1].showVerifyCode(code)
        }
//        if isLogin {
//            loginViewControllers[1].showVerifyCode(code)
//        } else {
//            signupViewControllers[1].showVerifyCode(code)
//        }
    }
    
    func setVerifyCodeBtnToDefault() {
        loginViewControllers.last?.setDefault()
        signupViewControllers.last?.setDefault()
        forgotViewControllers.last?.setDefault()
    }
    
    func setAccount(acc: String, pwd: String) {
        loginViewControllers[0].setAccount(acc: acc, pwd: pwd)
    }
    
    private func bindLoginViewControllers() {
        for i in loginViewControllers {
            i.rxLoginButtonPressed()
                .subscribeSuccess { [weak self] dto in
                    self?.loginBtnClick.onNext(dto)
                }.disposed(by: disposeBag)
            
            i.rxForgetPassword()
                .subscribeSuccess { [weak self] in
                    self?.forgetBtnClick.onNext(())
                }.disposed(by: disposeBag)
        }
    }
    
    private func bindSingupViewControllers() {
        for i in signupViewControllers {
            i.rxSignupButtonPressed()
                .subscribeSuccess { [weak self] dto in
                    self?.signupBtnClick.onNext(dto)
                }.disposed(by: disposeBag)
        }
    }
    
    private func bindForgotViewControllers() {
        for i in forgotViewControllers {
            i.rxResetButtonPressed()
                .subscribeSuccess { [weak self] dto in
                    self?.resetLinkBtnClick.onNext(dto)
                }.disposed(by: disposeBag)
        }
    }
    
    private func bindVerifyCodeBtn(obs: Observable<String>?) {
        obs?.subscribeSuccess({ [weak self] (phone) in
            self?.verifyCodeBtnClick.onNext(phone)
        }).disposed(by: disposeBag)
    }
    
    
    func rxLoginBtnClick() -> Observable<LoginPostDto> {
        return loginBtnClick.asObserver()
    }
    
    func rxSignupBtnClick() -> Observable<SignupPostDto> {
        return signupBtnClick.asObserver()
    }
    
    func rxResetPWBtnClick() -> Observable<LoginPostDto> {
        return resetLinkBtnClick.asObserver()
    }
    
    func rxForgetBtnClick() -> Observable<Void> {
        return forgetBtnClick.asObserver()
    }
    
    func rxVerifyCodeBtnClick() -> Observable<String> {
        return verifyCodeBtnClick.asObserver()
    }
}

// MARK: -
// MARK: 延伸
extension LoginPageViewController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T where T : PagingItem, T : Comparable, T : Hashable {
        switch currentShowMode {
        case .loginEmail,.loginPhone:
            return PagingIndexItem(index: index, title: loginViewControllers[index].modeTitle()) as! T
        case .signupEmail,.signupPhone:
            return PagingIndexItem(index: index, title: signupViewControllers[index].modeTitle()) as! T
        case .forgotPW:
            return PagingIndexItem(index: index, title: forgotViewControllers[index].modeTitle()) as! T
        }
//        if isLogin {
//            return PagingIndexItem(index: index, title: loginViewControllers[index].modeTitle()) as! T
//        }
//        return PagingIndexItem(index: index, title: signupViewControllers[index].modeTitle()) as! T
    }
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T : PagingItem, T : Comparable, T : Hashable {
        switch currentShowMode {
        case .loginEmail,.loginPhone:
            return loginViewControllers[index]
        case .signupEmail,.signupPhone:
            return signupViewControllers[index]
        case .forgotPW:
            return forgotViewControllers[index]
        }
//        return isLogin ? loginViewControllers[index] : signupViewControllers[index]
    }
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int where T : PagingItem, T : Comparable, T : Hashable {
        switch currentShowMode {
        case .loginEmail,.loginPhone:
            return loginViewControllers.count
        case .signupEmail,.signupPhone:
            return signupViewControllers.count
        case .forgotPW:
            return forgotViewControllers.count
        }
    }
}

//MARK: - apply menu indicator ui
class RoundedIndicatorView: PagingIndicatorView {
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layer.cornerRadius = layoutAttributes.frame.height / 2
    }
}
