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
    fileprivate let viewModel = WalletViewModel()
    static let share: WalletViewController = WalletViewController.loadNib()
    let depositVC = DepositViewController.loadNib()
    let withdrawVC = WithdrawViewController.loadNib()
    let twoFAVC = SecurityVerificationViewController.loadNib()
    fileprivate let pageVC = WalletPageViewController()
    let userVC = UserMenuViewController.loadNib()
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    private var walletsDto : [WalletBalancesDto] = [WalletBalancesDto()] {
        didSet {
            
        }
    }
    
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
    @IBOutlet weak var spotValueLabel: UILabel!
    private lazy var profileButton:UIButton = {
        let profileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        let image = UIImage(named:"icon-user")
        profileButton.setImage(image, for: .normal)
        profileButton.addTarget(self, action:#selector(pushToProfile), for:.touchUpInside)
        return profileButton
    }()
    private lazy var bellButton:UIButton = {
        let bellButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        let image = UIImage(named:"icon-bell")
        bellButton.setImage(image, for: .normal)
        bellButton.addTarget(self, action:#selector(pushToBell), for:.touchUpInside)
        // MC524 暫時隱藏
        bellButton.isHidden = true
        return bellButton
    }()
    private lazy var boardButton:UIButton = {
        let boardButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        let image = UIImage(named:"icon-record")
        boardButton.setImage(image, for: .normal)
        boardButton.addTarget(self, action:#selector(pushToBoard), for:.touchUpInside)
        return boardButton
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
        bindViewModel()
        bindSocket()
        bindPageVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchBalances()
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
        LoadingViewController.show()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) { 
            _ = LoadingViewController.dismiss()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    // MARK: -
    // MARK:業務方法
    func setupNavi()
    {
        title = "Wallet".localized
        let firstButtonItem = UIBarButtonItem(customView: boardButton)
        let secondButtonItem = UIBarButtonItem(customView: bellButton)
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 12
        let rightBarItems = [firstButtonItem,space,secondButtonItem]
        self.navigationItem.rightBarButtonItems = rightBarItems
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
    }
    func setup()
    {        
        WalletSecurityThemes.moneyVisibleOrNotVisible.bind(to: totalBalanceLabel.rx.isHidden).disposed(by: dpg)
        WalletSecurityThemes.stringVisibleOrNotVisible.bind(to: hiddenTotalBalanceLabel.rx.isHidden).disposed(by: dpg)
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
            WalletSecurityThemes.share.acceptMoneySecureStyle(.nonVisible)
        }else
        {
            eyeIconImageView.image = UIImage(named: "icon-view-hide")
            WalletSecurityThemes.share.acceptMoneySecureStyle(.visible)
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
            withdrawVC.setUPData(withdrawDatas: walletsDto)
            self.navigationController?.pushViewController(withdrawVC, animated: true)
        }.disposed(by: dpg)
    }
    func bindViewModel()
    {
        viewModel.rxFetchWalletBalancesSuccess().subscribeSuccess { [self]dto in
            Log.v("取得Balances\n\(dto)")
            // 主要理念是 將TRX 錢包濾掉
            // Asset Allocation 依據balance有無 出現漸層或單色
            // spot value 依據balance有無 改為 100% or 0%
            walletsDto = dto.filter({$0.currency != "TRX"})// 先過濾掉TRX的錢包
            let hasBalance = (dto.filter({$0.amount.doubleValue != 0.0}).count != 0)
            balanceGradiView.haveBalance = hasBalance
            spotGradiView.haveBalance = true
            spotValueLabel.text = (hasBalance == true ? "100%":"0%")
            setUPAmount()
            setUPDataForPageVC()
        }.disposed(by: dpg)
    }
    func bindPageVC()
    {
        pageVC.rxPageNoAccountAction().subscribeSuccess { [self] _ in
            Log.v("沒有Account ,點去開Deposit")
            self.navigationController?.pushViewController(depositVC, animated: true)
        }.disposed(by: dpg)
    }
    func bindSocket()
    {
        TXPayloadDto.rxShare.subscribeSuccess { [self] dto in
            if let statsValue = dto?.state
            {
                if statsValue == "COMPLETE"
                {
                    viewModel.fetchBalances()
                }
            }
        }.disposed(by: dpg)
    }
    func randomAmount(length: Int) -> Int {
      let letters = "123456789"
        return String((0..<length).map{ _ in letters.randomElement()! }).toInt()
    }
    func setUPAmount()
    {
        var amountString = 0.0
        var dataDtoIndex = 0
        for dataDto in walletsDto {
            // 先給 = 500
//            dataDto.amount = randomAmount(length: 4)
            // 先拿到總額
            
            if let doubleValue = dataDto.amount.doubleValue
            {
                amountString += doubleValue
                
            }else if let intValue = dataDto.amount.intValue
            {
                amountString += Double(intValue)
            }
        }
        for dataDto in walletsDto {
            var amountValue = 0.0
            if let doubleValue = dataDto.amount.doubleValue
            {
                amountValue = doubleValue
                
            }else if let intValue = dataDto.amount.intValue
            {
                amountValue = Double(intValue)
            }
             
            dataDtoIndex = walletsDto.indexOfObject(object: dataDto)
            if amountValue > 0
            {
                dataDto.persentValue = String(describing: amountValue/Double(amountString) * 100).numberFormatter(.decimal , 0)
            }else
            {
                dataDto.persentValue = "0"
            }
            walletsDto.remove(at: dataDtoIndex)
            walletsDto.insert(dataDto, at: dataDtoIndex)
        }
        totalBalanceLabel.text = String(describing: amountString).numberFormatter(.decimal, 8)
        
    }
    func setUPDataForPageVC()
    {
        pageVC.pageWalletsDto = walletsDto
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
//        let userVC = UserMenuViewController.loadNib()
//        self.navigationController?.pushViewController(userVC, animated: true)
        self.navigationController?.pushViewControllerFromLeft(userVC, animated: true)
//        self.navigationController?.viewPushAnimation(userVC, from: .fromLeft)
    }
    
    @objc func pushToBell() {
        Log.i("推到通知")
        checkSocket()
        let notiVC = NotiViewController.loadNib()
        notiVC.setData(dtos: [NotificationDto()])
        self.navigationController?.pushViewController(notiVC, animated: true)
    }
    
    @objc func pushToBoard() {
        Log.i("推到業務清單")
        let boardVC = BoardViewController.loadNib()
        self.navigationController?.pushViewController(boardVC, animated: true)
    }
    func checkSocket()
    {
        _ = SocketIOManager.sharedInstance.connectStatus()
    }
}
// MARK: -
// MARK: 延伸
