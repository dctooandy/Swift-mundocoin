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
    private let dpg = DisposeBag()
    fileprivate let viewModel = DepositViewModel()
    var qrCodeString : String!
    var walletDto :WalletAddressDto = WalletAddressDto(){
        didSet{
            resetUI()
        }
    }
    // MARK: -
    // MARK:UI 設定
    
    @IBOutlet weak var topCurrencyView: DropDownStyleView!

    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet weak var copyImageView: UIImageView!
    @IBOutlet weak var walletAddressTitle: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var methodTitleLabel: UILabel!
    @IBOutlet weak var protocolLabel: UILabel!
    @IBOutlet weak var discritpionLabel: UILabel!
    @IBOutlet weak var saveButton: SaveButton!
    @IBOutlet weak var shareButton: CornerradiusButton!
    @IBOutlet weak var boardView: UIView!

    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Deposit USDT"
        setupUI()
        bind()
        bindViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDepositData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // MARK: -
    // MARK:業務方法
    func fetchDepositData()
    {
        viewModel.fetchWalletForDeposit()
    }
    func bindViewModel()
    {
        viewModel.rxFetchWalletAddressSuccess().subscribeSuccess { [self]dto in
            Log.v("取得Address\n\(dto)")
            walletDto = dto
        }.disposed(by: dpg)
        
    }
    func setupUI()
    {
        view.backgroundColor = Themes.grayF4F7FE
//        qrCodeString = "THFfxoxMtMJGnjar...cXUNbHzry3"
//        let image = generateQRCode(from: qrCodeString)
//        codeImageView.image = image
        topCurrencyView?.layer.borderColor = #colorLiteral(red: 0.9058823529, green: 0.9254901961, blue: 0.968627451, alpha: 1)
        topCurrencyView?.layer.borderWidth = 1
        topCurrencyView.config(showDropdown: false, dropDataSource: ["USDT"])
    }
    func resetUI()
    {
        qrCodeString = walletDto.address
        let image = generateQRCode(from: qrCodeString)
        walletAddressLabel.text = qrCodeString
        codeImageView.image = image
    }
    func bind()
    {
        copyImageView.rx.click.subscribeSuccess { [self](_) in
            // write to clipboard
            UIPasteboard.general.string = qrCodeString
            Toast.show(msg: "Copied")
        }.disposed(by: dpg)
        saveButton.rx.tap.subscribeSuccess { [self](_) in
//            let image = codeImageView.asImage()
            let image = view.screenShot()!
            /// 将转换后的UIImage保存到相机胶卷中
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            Toast.show(msg: "Saved")
        }.disposed(by: dpg)
        shareButton.rx.tap.subscribeSuccess { [self](_) in
            shareInfo()
        }.disposed(by: dpg)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    @objc func saveImageToAlbum()
    {
        Toast.show(msg: "Saved")
    }
    func shareInfo() {
        // activityItems 陣列中放入我們想要使用的元件，這邊我們放入使用者圖片、使用者名稱及個人部落格。
        // 這邊因為我們確認裡面有值，所以使用驚嘆號強制解包。
        
        let activityVC = UIActivityViewController(activityItems: [view.screenShot()!,"MundoCoin","Account Address"], applicationActivities: nil)
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
// MARK: -
// MARK: 延伸
