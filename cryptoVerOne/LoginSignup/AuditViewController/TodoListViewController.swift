//
//  TodoListViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/6/12.
//

import Foundation
import RxCocoa
import RxSwift
import Parchment
enum AuditShowMode
{
    case pending
    case finished
    
    var caseString:String{
        switch self {
        case .pending:
            return "PENDING"
        case .finished:
            return "APPROVED"
//            return "CANCELLED"
        }
    }
}
class TodoListViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var currentShowMode: AuditShowMode = .pending {
        didSet{
            subPageVC.reloadPageMenu(currentMode: currentShowMode)            
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var backImageView: UIImageView!
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
    fileprivate let subPageVC = SubListPageViewController()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        naviBackBtn.isHidden = true
        setupBackUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        setupSubPageVC()
        setupNavigation()
        currentShowMode = .pending
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
//        bar?.backgroundColor = .lightGray
    }
    private func setupSubPageVC() {
        addChild(subPageVC)
        view.insertSubview(subPageVC.view, aboveSubview: backImageView)
        let naviBarHeight = self.navigationController?.navigationBar.frame.maxY ?? Views.topOffset + Views.topOffset
        subPageVC.view.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().offset(naviBarHeight)
            make.left.bottom.right.equalToSuperview()
        })
    }

    func socketEmit()
    {
#if Mundo_PRO || Mundo_STAGE || Approval_PRO || Approval_STAGE
                
#else
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(WalletWithdrawDto())
        let json = String(data: jsonData ?? Data(), encoding: String.Encoding.utf8)
        SocketIOManager.sharedInstance.sendEchoEvent(event: "message", para: json!)
#endif
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
    override var preferredStatusBarStyle:UIStatusBarStyle {
        if #available(iOS 13.0, *) {
#if Approval_PRO || Approval_DEV || Approval_STAGE
            return .lightContent
#else
            return .darkContent
#endif
        } else {
            return .default
        }
    }
}
// MARK: -
// MARK: 延伸

