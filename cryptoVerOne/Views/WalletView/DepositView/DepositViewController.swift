//
//  DepositViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/9.
//

import Foundation
import Toaster
import RxCocoa
import RxSwift

class DepositViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private var dpg = DisposeBag()
    fileprivate let viewModel = DepositViewModel()
    var qrCodeString : String!
    // 如果是一個 就灰色不給選,多個才會有下拉選單
    var dropDataSource = ["TRC20"]
    var walletDto :WalletAddressDto = WalletAddressDto(){
        didSet{
            resetUI()
        }
    }
    // MARK: -
    // MARK:UI 設定
    
//    @IBOutlet weak var topCurrencyView: DropDownStyleView!
    @IBOutlet weak var topCurrencyView: SelectCryptoCellView!
    @IBOutlet weak var topCurrencyViewHeight : NSLayoutConstraint!
    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet weak var copyImageView: UIImageView!
    @IBOutlet weak var walletAddressTitle: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var discritpionLabel: UILabel!
    @IBOutlet weak var saveButton: SaveButton!
    @IBOutlet weak var shareButton: CornerradiusButton!
    @IBOutlet weak var boardView: UIView!
    @IBOutlet weak var methodView : InputStyleView!
    var searchVC = SelectViewController.loadNib()
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Deposit USDT"
        if KeychainManager.share.getMundoCoinNetworkMethodEnable() == true
        {
            dropDataSource = ["TRC20","ERC20"]
        }
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDepositData()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:backBtn)
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bind()
        bindSelectVC()
        bindViewModel()
        bindWhenAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dpg = DisposeBag()
    }
    // MARK: -
    // MARK:業務方法
    @objc override func popVC() {
//        clearAllData()
        _ = self.navigationController?.popViewController(animated: true)
    }
    func fetchDepositData()
    {
        viewModel.fetchWalletForDeposit()
    }

    func setupUI()
    {
        view.backgroundColor = Themes.grayF4F7FE
//        qrCodeString = "THFfxoxMtMJGnjar...cXUNbHzry3"
//        let image = generateQRCode(from: qrCodeString)
//        codeImageView.image = image
        topCurrencyView.layer.borderColor = #colorLiteral(red: 0.9058823529, green: 0.9254901961, blue: 0.968627451, alpha: 1)
        topCurrencyView.layer.borderWidth = 1
//        topCurrencyView.config(showDropdown: false, dropDataSource: ["USDT"])
        boardView.applyCornerAndShadow(radius: 16)
        methodView.setMode(mode: .networkMethod(dropDataSource,.sheet))
    }
    func resetUI()
    {
        qrCodeString = walletDto.address
        let image = UIImage().generateQRCode(from: qrCodeString, imageView: codeImageView, logo:    nil)
        walletAddressLabel.text = qrCodeString
        codeImageView.image = image
    }
    func bind()
    {
        topCurrencyView.rxSelectCryptoClick().subscribeSuccess { [self] _ in
            searchVC.currentSelectMode = .selectCrypto
            searchVC.modalPresentationStyle = .popover
            present(searchVC, animated: true)
        }.disposed(by: dpg)
        copyImageView.rx.click.subscribeSuccess { [self](_) in
            // write to clipboard
            UIPasteboard.general.string = qrCodeString
            Toast.show(msg: "Copied")
        }.disposed(by: dpg)
        saveButton.rx.tap.subscribeSuccess { [self](_) in
            if AuthorizeService.share.authorizePhoto()
            {
                //            let image = codeImageView.asImage()
                Log.v("開始使用相機相簿")
                let image = view.screenShot()!
                /// 将转换后的UIImage保存到相机胶卷中
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                Toast.show(msg: "Saved")
            }
            
        }.disposed(by: dpg)
        shareButton.rx.tap.subscribeSuccess { [self](_) in
            shareInfo()
        }.disposed(by: dpg)
        methodView.rxSelectNetworkMethodSheetClick().subscribeSuccess { _ in
            Log.v("點到選network sheet")
            self.showNetWorkBottomSheet()
        }.disposed(by: dpg)
    }
    func bindSelectVC()
    {
        searchVC.rxSelectedCryptoClick().subscribeSuccess { [self] selectedCrypto in
            Log.v("Open Select Crypto: \(selectedCrypto)")
            topCurrencyView.cryptoLabel.text = selectedCrypto.cryptoName
            topCurrencyView.cryptoImageView.image = UIImage(named: selectedCrypto.cryptoIconName)
        }.disposed(by: dpg)
    }
    func bindViewModel()
    {
        viewModel.rxFetchWalletAddressSuccess().subscribeSuccess { [self]dto in
            Log.v("取得Address\n\(dto)")
            walletDto = dto
        }.disposed(by: dpg)
    }
    func bindWhenAppear()
    {
        AuthorizeService.share.rxShowAlert().subscribeSuccess { alertVC in
            UIApplication.topViewController()?.present(alertVC, animated: true, completion: nil)
        }.disposed(by: dpg)
    }
    @objc func saveImageToAlbum()
    {
        Toast.show(msg: "Saved")
    }
    func shareInfo() {
        // activityItems 陣列中放入我們想要使用的元件，這邊我們放入使用者圖片、使用者名稱及個人部落格。
        // 這邊因為我們確認裡面有值，所以使用驚嘆號強制解包。
        let imageData = view.screenShot()!
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
    func showNetWorkBottomSheet()
    {
        let networkBottomSheet = NetworkBottomSheet()
        networkBottomSheet.dataArray = transDataSourceToNetworkDto()
        networkBottomSheet.rxCellSecondClick().subscribeSuccess { [self](dataDto) in
            methodView.textField.text = dataDto.name
        }.disposed(by: dpg)
    
        DispatchQueue.main.async { [self] in
            networkBottomSheet.start(viewController: self, height: networkViewSheetHeight())
        }
    }
    func transDataSourceToNetworkDto() -> [SelectNetworkMethodDetailDto]
    {
        var newData : [SelectNetworkMethodDetailDto] = []
        for data in dropDataSource
        {
            let subData = SelectNetworkMethodDetailDto(name: data)
            newData.append(subData)
        }
        return newData
    }
    func networkViewSheetHeight() -> CGFloat
    {
        var sheetHeight = 251.0
        var cellCount = 0
        
        cellCount = dropDataSource.count
        sheetHeight += 92.0 * Double((cellCount - 1))
        return sheetHeight
    }
}
// MARK: -
// MARK: 延伸
