//
//  LoginQuicklyViewController.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/12/27.
//


import Foundation
import RxCocoa
import RxSwift
import Toaster

class LoginQuicklyViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var faceIDImageView: UIImageView!
    @IBOutlet weak var dismissImageView: UIImageView!
    @IBOutlet weak var loginPasswordButton: CornerradiusButton!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        bindImageView()
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupBackgroundView()
    }
    // MARK: -
    // MARK:業務方法
    func setupData()
    {
        if let lastAccount = KeychainManager.share.getLastAccount()
        {
            if lastAccount.components(separatedBy: "@").count > 1
            {
                accountLabel.text = lastAccount.hideEmailAccount()
            }else
            {
                accountLabel.text = lastAccount.hidePhoneAccount()
            }
        }
    }
    func setupBackgroundView()
    {
        backgroundImageView.layer.cornerRadius = 20
        backgroundImageView.layer.contents = UIImage(color: .white)?.cgImage
        backgroundImageView.layer.addShadow()
    }
    func bindImageView()
    {
        faceIDImageView.rx.click.subscribeSuccess { [self] _ in
            Log.i("點擊使用FaceID")
            bioVerifyCheck()
        }.disposed(by: dpg)
        dismissImageView.rx.click.subscribeSuccess { [self] _ in
            Log.i("去登入")
            quicklyGoToLogin()
        }.disposed(by: dpg)
        loginPasswordButton.rx.tap.subscribeSuccess { [self] _ in
            Log.i("去密碼登入")
            quicklyGoToLoginWithPassword()
        }.disposed(by: dpg)
    }
    func bioVerifyCheck()
    {
        if let loginPostDto = KeychainManager.share.getLastAccountDto(),
           (BioVerifyManager.share.usedBIOVeritfy(loginPostDto.account) ||
            BioVerifyManager.share.usedBIOVeritfy(loginPostDto.phone))
        {
            // 進行臉部或指紋驗證
            BioVerifyManager.share.bioVerify { [self] (success, error) in
                if !success {
                    DispatchQueue.main.async { [self] in
                        //                        Toast.show(msg: "验证失败，请输入帐号密码")
                        let popVC = ConfirmPopupView(iconMode: .showIcon("Close"), title: "Warning", message: "Verification failed, please enter account password.") { (_) in
                            
                        }
                        popVC.start(viewController: self)
                    }
                    //                        return
                }
                if let err = error , error != nil {
                    if err.localizedDescription == "Biometry is not enrolled."
                    {
                        // 若使用者沒有設置生物辨識，會自動導向 設定 -> Face/Touch ID & Passcode
                        showBioAlert(error:err as NSError)
                    }else if err.localizedDescription == "Authentication canceled."
                    {
                        Toast.show(msg: "Verification failed：\(error!.localizedDescription)")
                    }
                    return
                }
                DispatchQueue.main.async {
                    // FaceID 之後 不進行驗證碼驗證
                    let idString = loginPostDto.toAccountString
                    LoginSignupViewController.share.gotoLoginAction(with: idString, password: loginPostDto.password,loginDto: loginPostDto)
                }
            }
        } else {
            Log.i("manual login.")
        }
    }
}
// MARK: -
// MARK: 延伸
extension LoginQuicklyViewController {
    func showBioAlert(error:NSError)
    {
        Log.i("unset Face ID")
        let alertController = UIAlertController(title: "Biometrics can't used", message: "please add Face ID", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "ok", style: .default) { action in
            guard let url = URL(string: "App-prefs:PASSCODE") else { return }
            if (UIApplication.shared.canOpenURL(url)) {
                UIApplication.shared.open(url) { success in
                    print(success)
                }
            }
        }
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func quicklyGoToLogin()
    {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
        {
            let loginVC = LoginSignupViewController.share
            let loginNavVC = MuLoginNavigationController(rootViewController:loginVC )
            mainWindow.rootViewController = loginNavVC
            mainWindow.makeKeyAndVisible()
        }
    }
    func quicklyGoToLoginWithPassword()
    {
        let vc = LoginQuicklyPasswordViewController.instance(faceIDPrefixVC: true)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
