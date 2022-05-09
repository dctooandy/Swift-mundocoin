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
    let depositVC = DepositViewController.loadNib()
    let withdrawVC = WithdrawViewController.loadNib()
    fileprivate let pageVC = WalletPageViewController()
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()

    // MARK: -
    // MARK:UI 設定
    private lazy var profileButton:UIButton = {
        let backToButton = UIButton()
        let image = UIImage(named:"launch-logo")?.reSizeImage(reSize: CGSize(width: 30, height: 30))
        backToButton.setImage(image, for: .normal)
        backToButton.addTarget(self, action:#selector(pushToProfile), for:.touchUpInside)
        return backToButton
    }()
    private lazy var bellButton:UIButton = {
        let backToButton = UIButton()
        let image = UIImage(named:"launch-logo")?.reSizeImage(reSize: CGSize(width: 30, height: 30))
        backToButton.setImage(image, for: .normal)
        backToButton.addTarget(self, action:#selector(pushToBell), for:.touchUpInside)
        return backToButton
    }()
    private lazy var boardButton:UIButton = {
        let backToButton = UIButton()
        let image = UIImage(named:"launch-logo")?.reSizeImage(reSize: CGSize(width: 30, height: 30))
        backToButton.setImage(image, for: .normal)
        backToButton.addTarget(self, action:#selector(pushToBoard), for:.touchUpInside)
        return backToButton
    }()
    @IBOutlet weak var depositImg: UIImageView!
    @IBOutlet weak var withdrawImg: UIImageView!
    @IBOutlet weak var middleLineView: UIView!
    
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
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
    func bindingIMGview()
    {
        depositImg.rx.click.subscribeSuccess { [self] (_) in
            self.navigationController?.pushViewController(depositVC, animated: true)
        }.disposed(by: dpg)
        withdrawImg.rx.click.subscribeSuccess { [self] (_) in
            self.navigationController?.pushViewController(withdrawVC, animated: true)
        }.disposed(by: dpg)
    }
    private func setupPagingView() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.snp.makeConstraints({ (make) in
            make.top.equalTo(self.middleLineView.snp.bottom).offset(26)
            make.left.bottom.right.equalToSuperview()
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
