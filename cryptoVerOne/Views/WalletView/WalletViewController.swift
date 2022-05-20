//
//  WalletViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import UIKit
import UPCarouselFlowLayout
import SnapKit
import RxCocoa
import RxSwift
import UserNotifications
import SafariServices
import SDWebImage
class WalletViewController: BaseViewController {
    // MARK:業務設定
    static let share: WalletViewController = WalletViewController.loadNib()
    let depositVC = DepositViewController.loadNib()
    let withdrawVC = WithdrawViewController.loadNib()
    let twoFAVC = SecurityVerificationViewController.loadNib()
    fileprivate let pageVC = WalletPageViewController()
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()

    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var eyeIconImageView: UIImageView!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var hiddenTotalBalanceLabel: UILabel!
    @IBOutlet weak var balanceGradiView: BalanceGradientView!
    @IBOutlet weak var spotGradiView: BalanceGradientView!
    @IBOutlet weak var balanceFrameView: UIView!
    @IBOutlet weak var depositImg: UIImageView!
    @IBOutlet weak var withdrawImg: UIImageView!
    
    private lazy var profileButton:UIButton = {
        let backToButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        let image = UIImage(named:"icon-user")
        backToButton.setImage(image, for: .normal)
        backToButton.addTarget(self, action:#selector(pushToProfile), for:.touchUpInside)
        return backToButton
    }()
    private lazy var bellButton:UIButton = {
        let backToButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        let image = UIImage(named:"icon-bell")
        backToButton.setImage(image, for: .normal)
        backToButton.addTarget(self, action:#selector(pushToBell), for:.touchUpInside)
        return backToButton
    }()
    private lazy var boardButton:UIButton = {
        let backToButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        let image = UIImage(named:"icon-record")
        backToButton.setImage(image, for: .normal)
        backToButton.addTarget(self, action:#selector(pushToBoard), for:.touchUpInside)
        return backToButton
    }()
 
    
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
        setup()
        bindAction()
        bindingIMGview()
        setupPagingView()
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
    // MARK: -
    // MARK:業務方法
    func setupNavi()
    {
        title = "Wallet".localized
        let rightBarItems = [UIBarButtonItem(customView: boardButton),UIBarButtonItem(customView: bellButton)]
        self.navigationItem.rightBarButtonItems = rightBarItems
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
    }
    func setup()
    {
        totalBalanceLabel.text = "988775.05".numberFormatter(.decimal, 2)
        Themes.moneyVisibleOrNotVisible.bind(to: totalBalanceLabel.rx.isHidden).disposed(by: dpg)
        Themes.stringVisibleOrNotVisible.bind(to: hiddenTotalBalanceLabel.rx.isHidden).disposed(by: dpg)
    }
    func bindAction()
    {
        twoFAVC.securityViewMode = .defaultMode
        twoFAVC.rxVerifySuccessClick().subscribeSuccess { (_) in
            Log.i("Submit成功")
        }.disposed(by: dpg)
        eyeIconImageView.rx.click.subscribeSuccess { [self](_) in
            changeEyeMode()
        }.disposed(by: dpg)
    }
    func changeEyeMode()
    {
        if hiddenTotalBalanceLabel.isHidden == true
        {
            eyeIconImageView.image = UIImage(named: "icon-view")
            TwoSideStyle.share.acceptMoneySecureStyle(.nonVisible)
        }else
        {
            eyeIconImageView.image = UIImage(named: "icon-view-hide")
            TwoSideStyle.share.acceptMoneySecureStyle(.visible)
        }
        
    }
    func bindingIMGview()
    {
        depositImg.rx.click.subscribeSuccess { [self] (_) in
            self.navigationController?.pushViewController(depositVC, animated: true)
        }.disposed(by: dpg)
        withdrawImg.rx.click.subscribeSuccess { [self] (_) in
            // 測試
//            self.navigationController?.pushViewController(twoFAVC, animated: true)
            self.navigationController?.pushViewController(withdrawVC, animated: true)
        }.disposed(by: dpg)
    }
    private func setupPagingView() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.snp.makeConstraints({ (make) in
            make.top.equalTo(self.balanceFrameView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        })
    }
    @objc func pushToProfile() {
        Log.i("推到個人清單")
        let userVC = UserMenuViewController.loadNib()
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    @objc func pushToBell() {
        Log.i("推到通知")
        let notiVC = NotiViewController.loadNib()
        self.navigationController?.pushViewController(notiVC, animated: true)
    }
    
    @objc func pushToBoard() {
        Log.i("推到業務清單")
        let boardVC = BoardViewController.loadNib()
        self.navigationController?.pushViewController(boardVC, animated: true)
    }
}
// MARK: -
// MARK: 延伸
