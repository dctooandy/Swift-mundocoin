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
    let logoImage : UIImageView = {
        let image = UIImageView(image: UIImage(named: "mundoLogo"))
        return image
    }()
    
    @IBOutlet weak var adminImageView: UIImageView!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        naviBackBtn.isHidden = true
        self.navigationItem.titleView = logoImage
        setupUI()
        bindLabel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    func setupNavigation()
    {
        let bar = self.navigationController?.navigationBar
        bar?.isTranslucent = true
        bar?.backgroundColor = .lightGray
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
}
// MARK: -
// MARK: 延伸
