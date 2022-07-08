//
//  AccountViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/6/12.
//


import Foundation
import RxCocoa
import RxSwift

class AccountViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var adminImageView: UIImageView!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    private lazy var logoBtn:UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        let image = UIImage(named: "mundoLogo")?.reSizeImage(reSize: CGSize(width: 26, height: 26))
        btn.setImage(image, for: .normal)
        return btn
    }()
    private lazy var logoutBtn:UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        let image = UIImage(named: "icon-logoout")?.reSizeImage(reSize: CGSize(width: 26, height: 26))
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action:#selector(logoutAction), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        naviBackBtn.isHidden = true
        setupUI()
        bindLabel()
        setupBackUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        setupNavigation()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // MARK: -
    // MARK:業務方法
    func setupBackUI()
    {
        title = "MC Audit".localized
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoBtn)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoutBtn)
        view.backgroundColor = Themes.black1B2559
    }
    func setupNavigation()
    {
        let bar = self.navigationController?.navigationBar
        bar?.isTranslucent = true
    }
    func setupUI()
    {
        var version = ""
        var build = ""
        if let versionString = Bundle.main.releaseVersionNumber
        {
            version = versionString
        }
        else
        {
            version = "version 1.2.3"
        }
        if let buildString = Bundle.main.buildVersionNumber
        {
            build = buildString
        }
        else
        {
            build = "1"
        }
        let appVersionString = "version \(version)-\(build)"
        appVersionLabel.text = appVersionString
        logoutLabel.layer.borderColor = UIColor.lightGray.cgColor
        logoutLabel.layer.borderWidth = 1
        emailLabel.text = KeychainManager.share.getLastAccount()?.account
    }
    func bindLabel()
    {
        logoutLabel.rx.click.subscribeSuccess { (_) in
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
            {
                DeepLinkManager.share.cleanDataForLogout()
                let auditNavVC = MDNavigationController(rootViewController: AuditLoginViewController.loadNib())
                mainWindow.rootViewController = auditNavVC
                mainWindow.makeKeyAndVisible()
            }
        }.disposed(by: dpg)
    }
    @objc func logoutAction()
    {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let mainWindow = appDelegate.window
        {
            DeepLinkManager.share.cleanDataForLogout()
            let auditNavVC = MDNavigationController(rootViewController: AuditLoginViewController.loadNib())
            mainWindow.rootViewController = auditNavVC
            mainWindow.makeKeyAndVisible()
        }
    }
}
// MARK: -
// MARK: 延伸
