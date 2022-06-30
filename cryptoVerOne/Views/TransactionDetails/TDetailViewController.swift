//
//  TDetailViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/16.
//


import Foundation
import RxCocoa
import RxSwift
enum DetailType {
    case pending
    case processing
    case done
    case failed
}
enum DetailHiddenMode {
    case topViewHidden
    case topViewShow
}
class TDetailViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var titleString = ""
    // model
    var detailType : DetailType = .pending
    var detailDataDto : DetailDto? {
        didSet{
            detailType = detailDataDto!.detailType
        }
    }
    var hiddenMode:DetailHiddenMode = .topViewShow{
        didSet{
            if self.hiddenMode == .topViewShow
            {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:mdBackBtn)
            }
        }
    }
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topView: TransTopView!
    @IBOutlet weak var dataListView: TransDetailView!
    @IBOutlet weak var checkButton: CornerradiusButton!
    @IBOutlet weak var tryButton: CornerradiusButton!
    lazy var mdBackBtn:TopBackButton = {
        let btn = TopBackButton()
        btn.addTarget(self, action:#selector(popToRootVC), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    static func instance(titleString : String ,mode: DetailHiddenMode , dataDto: DetailDto) -> TDetailViewController {
        let vc = TDetailViewController.loadNib()
        vc.titleString = titleString
        vc.detailDataDto = dataDto
        vc.hiddenMode = mode
        return vc
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
        
        view.backgroundColor = Themes.grayF4F7FE
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = titleString
        setupData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        checkButton.setTitle("Check History".localized, for: .normal)
        checkButton.titleLabel?.font = Fonts.pingFangTCMedium(16)
        checkButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        checkButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        tryButton.setTitle("Try Again".localized, for: .normal)
        tryButton.titleLabel?.font = Fonts.pingFangTCMedium(16)
        tryButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        tryButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
    }
    func bindUI()
    {
        checkButton.rx.tap.subscribeSuccess { (_) in
            Log.i("去看金流歷史紀錄")
            let boardVC = BoardViewController.loadNib()
            self.navigationController?.viewControllers = [WalletViewController.share]
            WalletViewController.share.navigationController?.pushViewController(boardVC, animated: true)
        }.disposed(by: dpg)
        tryButton.rx.tap.subscribeSuccess { (_) in
            Log.i("回到首頁")
            self.navigationController?.popToRootViewController(animated: true)
        }.disposed(by: dpg)
        dataListView.rxAddAddressClick().subscribeSuccess { [self] addressString in
            Log.i("增加錢包地址")
            let addVC = AddNewAddressViewController.loadNib()
            addVC.newAddressString = addressString
            navigationController?.pushViewController(addVC, animated: true)
        }.disposed(by: dpg)
        TXPayloadDto.rxShare.subscribeSuccess { [self] dto in
            if let data = dto,
               let statsValue = dto?.detailType,
               let socketID = dto?.id
            {
                if detailDataDto?.id == socketID, detailDataDto?.detailType != statsValue
                {
                    let detailDto = DetailDto(detailType: data.detailType,
                                              amount: data.amountIntWithDecimal?.stringValue ?? "",
                                              tether: data.currency ?? "",
                                              network: "Tron(TRC20)",
                                              confirmations: "\(data.confirmBlocks ?? 0)/1",
                                              //                                          fee: "\(data.fees ?? 1)",
                                              fee: "1",
                                              date: data.createdDateString,
                                              address: data.toAddress ?? "",
                                              txid: data.txId ?? "",
                                              id: data.id ?? "",
                                              orderId: data.orderId ?? "")
                    self.detailDataDto = detailDto
                    dataListView.detailDataDto = detailDto
                    dataListView.viewType = detailDto.detailType
                    topView.topViewType = detailDto.detailType
                    TransStyleThemes().acceptTopViewStatusStyle(detailDto.detailType)
                }
            }
        }.disposed(by: dpg)
    }
    func setupData()
    {
        if let dataDto = detailDataDto
        {
            dataListView.detailDataDto = dataDto
            dataListView.viewType = dataDto.detailType
            topView.topViewType = dataDto.detailType
        }
        if hiddenMode == .topViewShow
        {
            topViewHeight.constant = 70
            checkButton.isHidden = false
            tryButton.isHidden = false
            TransStyleThemes.tryAgainBtnHiddenType.bind(to: tryButton.rx.isHidden).disposed(by: dpg)
        }else
        {
            topViewHeight.constant = 0
            checkButton.isHidden = true
            tryButton.isHidden = true
        }
    }
    @objc func popToRootVC() {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
// MARK: -
// MARK: 延伸

