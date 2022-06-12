//
//  AuditLoginViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/10/22.
//

import Foundation
import RxCocoa
import RxSwift

class AuditLoginViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
//    static let share: AuditLoginViewController = AuditLoginViewController.loadNib()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var accountInputView: InputStyleView!
    @IBOutlet weak var passwordInputView: InputStyleView!
    @IBOutlet weak var checkBoxView: CheckBoxView!
    @IBOutlet weak var loginButton: CornerradiusButton!
    @IBOutlet weak var backgroundView: UIView!
    private let tabbarVC = AuditTabbarViewController()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        naviBackBtn.isHidden = true
        setupKeyboardNoti()
        setupUI()
        bindTextfield()
        bindLoginButton()
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        accountInputView.tfMaskView.changeBorderWith(isChoose:false)
        passwordInputView.tfMaskView.changeBorderWith(isChoose:false)
    }
    // MARK: -
    // MARK:業務方法
    func setupKeyboardNoti()
    {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if ((passwordInputView?.textField.isFirstResponder) == true)
            {
                let diffHeight = Views.screenHeight - passwordInputView.frame.maxY
                if diffHeight < (keyboardHeight + 50)
                {
                    let upHeight = (keyboardHeight + 50) - diffHeight
                    if backgroundView.frame.origin.y == Views.topOffset {
                        backgroundView.frame.origin.y = Views.topOffset - upHeight
                    }
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if backgroundView.frame.origin.y != Views.topOffset {
            backgroundView.frame.origin.y = Views.topOffset
         }
    }

    func setupUI()
    {
        accountInputView.setMode(mode: .auditAccount)
        passwordInputView.setMode(mode: .auditPassword)
        checkBoxView.checkType = .checkType
        checkBoxView.isSelected = true
    }
    func bindTextfield()
    {
        accountInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            accountInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
            passwordInputView.tfMaskView.changeBorderWith(isChoose:false)
        }.disposed(by: dpg)
        passwordInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            accountInputView.tfMaskView.changeBorderWith(isChoose:false)
            passwordInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)

        let isAccountValid = accountInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard let acc = str else { return false  }
                return RegexHelper.match(pattern:. mail, input: acc)
        }
        let isPWValid = passwordInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. password, input: acc)
        }
        isAccountValid.skip(1).bind(to: accountInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isPWValid.skip(1).bind(to: passwordInputView.invalidLabel.rx.isHidden).disposed(by: dpg)

        Observable.combineLatest(isAccountValid, isPWValid)
            .map { return $0.0 && $0.1 } //reget match result
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: dpg)
    }
    func bindLoginButton()
    {
        loginButton.rx.tap.subscribeSuccess { [self](_) in
            Log.v("Audit登入")
            goTodoViewController()
        }.disposed(by: dpg)
    }
    func getTabbarVC() -> AuditTabbarViewController? {
        return UIApplication.topViewController() as? AuditTabbarViewController
    }
    func goTodoViewController() {
//        tabbarVC.selected(0)
        //        tabbarVC.mainPageVC.shouldFetchGameType = true
        let auditTodoVC = MuLoginNavigationController(rootViewController: tabbarVC)
        DispatchQueue.main.async {
            if let mainWindow = (UIApplication.shared.delegate as? AppDelegate)?.window {
                print("go ")
                mainWindow.rootViewController = auditTodoVC
                mainWindow.makeKeyAndVisible()
            }
        }
    }
}
// MARK: -
// MARK: 延伸
