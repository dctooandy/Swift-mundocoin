//
//  WDetailViewController.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/2.
//

import Foundation
import RxCocoa
import RxSwift
import Toaster

class WDetailViewController: BaseViewController {
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
    @IBOutlet weak var withdrawStatusViewHeight: NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var withdrawStatusView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    var checkButton: CornerradiusButton = CornerradiusButton()
    var tryButton: CornerradiusButton = CornerradiusButton()
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
    static func instance(titleString : String , dataDto: DetailDto) -> WDetailViewController {
        let vc = WDetailViewController.loadNib()
        vc.titleString = titleString
        vc.detailDataDto = dataDto
        return vc
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: mdBackBtn)
        view.backgroundColor = Themes.grayF4F7FE
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = titleString
        self.navigationController?.navigationBar.titleTextAttributes = [.font: Fonts.PlusJakartaSansBold(20),.foregroundColor: UIColor(rgb: 0x1B2559)]
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
        self.view.addSubview(checkButton)
        self.view.addSubview(tryButton)
        checkButton.setTitle("Check History", for: .normal)
        checkButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        checkButton.setBackgroundImage(UIImage(color: Themes.blue6149F6) , for: .normal)
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(self.withdrawStatusView.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(51)
            make.right.equalToSuperview().offset(-51)
            make.height.equalTo(50)
        }
        tryButton.setTitle("Try Again", for: .normal)
        tryButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        tryButton.setBackgroundImage(UIImage(color: Themes.blue6149F6) , for: .normal)
        tryButton.snp.makeConstraints { make in
            make.top.equalTo(self.withdrawStatusView.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(51)
            make.right.equalToSuperview().offset(-51)
            make.height.equalTo(50)
        }
        withdrawStatusView.applyCornerAndShadow(radius: 16)
    }
    func bindUI()
    {
        checkButton.rx.tap.subscribeSuccess { (_) in
            Log.i("去看金流歷史紀錄")
            let boardVC = BoardViewController.loadNib()
            boardVC.loadingDurarion = 1.0
            boardVC.isFromWithdral = true
            self.navigationController?.viewControllers = [WalletViewController.share]
            WalletViewController.share.navigationController?.pushViewController(boardVC, animated: true)
        }.disposed(by: dpg)
        tryButton.rx.tap.subscribeSuccess { [self] (_) in
            Log.i("回到首頁")
            if let amountValue = detailDataDto?.amount ,let addressValue = detailDataDto?.address
            {
                WithdrawViewController.share.setDataFromTryAgain(amount:amountValue , address: addressValue)
            }
            self.navigationController?.popToViewController(WithdrawViewController.share , animated: true)
        }.disposed(by: dpg)
    }
    func setupData()
    {
        if let dataDto = detailDataDto
        {
            amountLabel.text = "\(dataDto.amount.numberFormatter(.decimal, 8)) \(dataDto.tether)"
            if dataDto.detailType == .failed
            {
                statusImageView.image = UIImage(named:"withdraw-failed")
                statusLabel.text = "Withdrawal Failed"
                statusLabel.textColor = UIColor(rgb: 0xF33828)
                dateLabel.text = dataDto.date
                messageLabel.text = "Your withdrawal request is \nsubmitted failed.  Please try again."
                checkButton.isHidden = true
                tryButton.isHidden = false
                withdrawStatusViewHeight.constant = 380.0
            }else
            {
                statusImageView.image = UIImage(named:"withdraw-success")
                statusLabel.text = "Withdrawal Processing"
                statusLabel.textColor = UIColor(rgb: 0x0DC897)
                dateLabel.text = dataDto.date
                messageLabel.text = "Your withdrawal request is submitted successfully.  Check history for the latest updates."
                checkButton.isHidden = false
                tryButton.isHidden = true
                withdrawStatusViewHeight.constant = 398.0
            }
        }
        
        

    }
    @objc func popToRootVC() {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
// MARK: -
// MARK: 延伸
extension WDetailViewController
{
  
}



