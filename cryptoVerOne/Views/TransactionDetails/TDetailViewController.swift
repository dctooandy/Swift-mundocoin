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
    var detailType : DetailType = .pending {
        didSet{
            resetUI()
        }
    }
    var detailDataDto : DetailDto? {
        didSet{
            detailType = detailDataDto!.defailType
        }
    }
    var hiddenMode:DetailHiddenMode = .topViewShow
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topView: TransTopView!
    @IBOutlet weak var dataListView: TransDetailView!
    @IBOutlet weak var checkButton: CornerradiusButton!
    // MARK: -
    // MARK:Life cycle
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
        checkButton.titleLabel?.font = Fonts.pingFangTCMedium(16)
        checkButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        checkButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
    }
    func bindUI()
    {
        checkButton.rx.tap.subscribeSuccess { (_) in
            Log.i("去看金流歷史紀錄")
            if self.detailType == .failed
            {
                self.navigationController?.popToRootViewController(animated: true)
            }else
            {
                let boardVC = BoardViewController.loadNib()
                self.navigationController?.viewControllers = [WalletViewController.share]
                WalletViewController.share.navigationController?.pushViewController(boardVC, animated: true)
            }
        }.disposed(by: dpg)
        dataListView.rxAddAddressClick().subscribeSuccess { [self] addressString in
            Log.i("增加錢包地址")
            let addVC = AddNewAddressViewController.loadNib()
            addVC.newAddressString = addressString
            navigationController?.pushViewController(addVC, animated: true)
        }.disposed(by: dpg)
        
    }
    func setupData()
    {
        if let dataDto = detailDataDto
        {
            dataListView.detailDataDto = dataDto
            dataListView.viewType = dataDto.defailType
            topView.topViewType = dataDto.defailType
        }
        if hiddenMode == .topViewShow
        {
            topViewHeight.constant = 70
            checkButton.isHidden = false
        }else
        {
            topViewHeight.constant = 0
            checkButton.isHidden = true
        }
    }
    func resetUI()
    {
        if self.detailType == .failed
        {
            checkButton.setTitle("Try Again".localized, for: .normal)
        }else
        {
            checkButton.setTitle("Check History".localized, for: .normal)
        }
    }
}
// MARK: -
// MARK: 延伸

