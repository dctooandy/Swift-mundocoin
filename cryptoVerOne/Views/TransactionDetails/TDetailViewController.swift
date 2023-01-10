//
//  TDetailViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/16.
//


import Foundation
import RxCocoa
import RxSwift
import Toaster

enum DetailType {
    case pending
    case processing
    case done
    case failed
    case innerDone
    case innerFailed
}
enum DetailHiddenModeTopView {
    case topViewHidden
    case topViewShow
}
enum DetailHiddenModeBottomButton {
    case buttonHidden
    case buttonShow
}
class TDetailViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private var dpg = DisposeBag()
    var titleString = ""
    // model
    var detailType : DetailType = .pending
    var detailDataDto : DetailDto? {
        didSet{
            detailType = detailDataDto!.detailType
        }
    }
    var topHiddenMode:DetailHiddenModeTopView = .topViewShow{
        didSet{
            if self.topHiddenMode == .topViewShow
            {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:mdBackBtn)
            }
        }
    }
    var buttonHiddenMode:DetailHiddenModeBottomButton = .buttonShow{
        didSet{
        }
    }
    // 上部 高度調整
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    // 下部 高度調整
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    var isPushToAddAddressBookVC = false
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topView: TransTopView!
    @IBOutlet weak var dataListView: TransDetailView!
//    @IBOutlet weak var checkButton: CornerradiusButton!
//    @IBOutlet weak var tryButton: CornerradiusButton!
    @IBOutlet weak var saveButton: SaveButton!
    @IBOutlet weak var shareButton: CornerradiusButton!
    @IBOutlet weak var contentScrollView: UIScrollView!
    lazy var mdBackBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        btn.addTarget(self, action:#selector(popToRootVC), for:.touchUpInside)
        return btn
    }()
    lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    static func instance(titleString : String ,mode: DetailHiddenModeTopView ,buttonMode: DetailHiddenModeBottomButton , dataDto: DetailDto) -> TDetailViewController {
        let vc = TDetailViewController.loadNib()
        vc.titleString = titleString
        vc.detailDataDto = dataDto
        vc.topHiddenMode = mode
        vc.buttonHiddenMode = buttonMode
        return vc
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        view.backgroundColor = Themes.grayF4F7FE
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = titleString
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
        setupData()
        topView.applyCornerAndShadow(radius: 16)
        dataListView.applyCornerAndShadow(radius: 16)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isPushToAddAddressBookVC == true
        {
            Log.v("此為測試內容")
        }else
        {
            dpg = DisposeBag()
        }
        isPushToAddAddressBookVC = false
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
//        checkButton.setTitle("Check History".localized, for: .normal)
//        checkButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
//        checkButton.setBackgroundImage(UIImage(color: Themes.blue6149F6) , for: .normal)
//        tryButton.setTitle("Try Again".localized, for: .normal)
//        tryButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
//        tryButton.setBackgroundImage(UIImage(color: Themes.blue6149F6) , for: .normal)
        shareButton.rx.tap.subscribeSuccess { [self](_) in
            shareInfo()
        }.disposed(by: dpg)
        saveButton.rx.tap.subscribeSuccess { [self](_) in
            if AuthorizeService.share.authorizePhoto()
            {
                //            let image = codeImageView.asImage()
                Log.v("開始使用相機相簿")
//                if let image = contentScrollView.captrue
//                {
////                    let image = UIApplication.shared.keyWindow!.asImage()
////                    let image = view.screenShot()!
//                    // 将转换后的UIImage保存到相机胶卷中
//                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                }
                let image = contentScrollView.getLongImage()!
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                Toast.show(msg: "Saved")
            }
            
        }.disposed(by: dpg)
    }
    func bindUI()
    {
//        checkButton.rx.tap.subscribeSuccess { (_) in
//            Log.i("去看金流歷史紀錄")
//            let boardVC = BoardViewController.loadNib()
//            boardVC.loadingDurarion = 1.0
//            boardVC.isFromWithdral = true
//            self.navigationController?.viewControllers = [WalletViewController.share]
//            WalletViewController.share.navigationController?.pushViewController(boardVC, animated: true)
//        }.disposed(by: dpg)
//        tryButton.rx.tap.subscribeSuccess { [self] (_) in
//            Log.i("回到首頁")
//            if let amountValue = detailDataDto?.amount ,let addressValue = detailDataDto?.address
//            {
//                WithdrawViewController.share.setDataFromTryAgain(amount:amountValue , address: addressValue)
//            }
//            self.navigationController?.popToViewController(WithdrawViewController.share , animated: true)
//        }.disposed(by: dpg)
        dataListView.rxAddAddressClick().subscribeSuccess { [self] addressString in
            Log.v("增加錢包地址")
            let addVC = AddNewAddressViewController.loadNib()
            addVC.newAddressString = addressString
            isPushToAddAddressBookVC = true
            navigationController?.pushViewController(addVC, animated: true)
        }.disposed(by: dpg)
        TXPayloadDto.rxShare.subscribeSuccess { [self] dto in
            if let data = dto,
               let statsValue = dto?.detailType,
               let socketID = dto?.id,
//               let feeString = dto?.fees != nil ? ((dto?.fees)! > 0 ? "\(String(describing: dto?.fees))" : "1") : "1"
               let feeDouble = dto?.serviceFee
            {
                let feeString = "\(feeDouble)"
                let detailDto = DetailDto(detailType: data.detailType,
                                          amount: data.txAmountIntWithDecimal?.stringValue ?? "",
                                          tether: data.currency ?? "",
                                          network: "Tron(TRC20)",
                                          confirmations: "\(data.confirmBlocks ?? 0)",
                                          //                                          fee: "\(data.fees ?? 1)",
                                          fee: feeString,
                                          date: data.createdDateString,
                                          address: data.toAddress ?? "",
                                          fromAddress: data.fromAddress ?? "",
                                          txid: data.txId ?? "",
                                          id: data.id ?? "",
                                          orderId: data.orderId ?? "",
                                          confirmBlocks: data.confirmBlocks ?? 0,
                                          type: dto?.type ?? "",
                                          decimal: dto?.decimal ?? 0,
                                          feeDecimal: dto?.feeDecimal ?? 0,
                                          actualAmount: "\(dto?.actualAmount ?? 0.0)")
                if detailDataDto?.id == socketID, (detailDataDto?.detailType != statsValue || detailDataDto?.confirmBlocks != data.confirmBlocks)
                {
                    detailDto.showMode = dataListView.detailDataDto?.showMode
                    dataListView.detailDataDto = detailDto
                    self.detailDataDto = detailDto
                    dataListView.viewType = detailDto.detailType
                    topView.topViewType = detailDto.detailType
                    TransStyleThemes().acceptTopViewStatusStyle(detailDto.detailType)
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
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
        if topHiddenMode == .topViewShow
        {
            topViewHeight.constant = 70
            topView.isHidden = false
        }else
        {
            topViewHeight.constant = 0
            topView.isHidden = true
        }
        if buttonHiddenMode == .buttonShow
        {
//            checkButton.isHidden = false
//            tryButton.isHidden = false
//            TransStyleThemes.tryAgainBtnHiddenType.bind(to: tryButton.rx.isHidden).disposed(by: dpg)
            bottomViewHeight.constant = 0.0
        }else
        {
//            checkButton.isHidden = true
//            tryButton.isHidden = true
            bottomViewHeight.constant = 104.0
        }
    }
    @objc func popToRootVC() {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
// MARK: -
// MARK: 延伸
extension TDetailViewController
{
    func shareInfo() {
        // activityItems 陣列中放入我們想要使用的元件，這邊我們放入使用者圖片、使用者名稱及個人部落格。
        // 這邊因為我們確認裡面有值，所以使用驚嘆號強制解包。
        let imageData = contentScrollView.getLongImage()!
//        let imageData = view.screenShot()!
    //        let stringData = "MundoCoin \n Account Address"
        let activityVC = UIActivityViewController(activityItems: [imageData], applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            // 如果錯誤存在，跳出錯誤視窗並顯示給使用者。
            if error != nil {
                self.showAlert(title: "Error", message: "Error:\(error!.localizedDescription)")
                return
            }
                                                 
            // 如果發送成功，跳出提示視窗顯示成功。
            if completed {
                self.showAlert(title: "Success", message: "Share MundoCoin's information.")
            }

        }
        // 顯示出我們的 activityVC。
        self.present(activityVC, animated: true, completion: nil)
    }
}



