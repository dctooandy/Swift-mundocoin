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
class TDetailViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var titleString = ""
    // model
    var detailType : DetailType = .pending
    var detailDataDto : DetailDto? {
        didSet{
            setupUI()
            bindUI()
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var withdrawToView: UIView!
    @IBOutlet weak var txidView: UIView!
    @IBOutlet weak var checkButton: CornerradiusButton!
    
    var withdrawToInputView : InputStyleView!
    var txidInputView : InputStyleView!
    
    @IBOutlet weak var txidInputViewHeight: NSLayoutConstraint!
    // MARK: -
    // MARK:Life cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = titleString
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
        if let dto = detailDataDto
        {

            withdrawToInputView = InputStyleView(inputViewMode: .withdrawAddressToDetail(true))
            withdrawToView.addSubview(withdrawToInputView)
            withdrawToInputView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            txidInputView = InputStyleView(inputViewMode: .txid(dto.txid))
            txidView.addSubview(txidInputView)
            txidInputView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            checkButton.setTitle("Check History".localized, for: .normal)
            checkButton.titleLabel?.font = Fonts.pingFangTCMedium(16)
            checkButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
            checkButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
            
            withdrawToInputView.setVisibleString(string: dto.address)
            txidInputView.setVisibleString(string: dto.txid)
        }
    }
    func bindUI()
    {
        txidInputView.rxTextLabelClick().subscribeSuccess { (string) in
            print("outapp url str: \(string)")
              UIApplication.shared.open((URL(string: "https://google.com.tw")!), options: [:], completionHandler: nil)
        }.disposed(by: dpg)
        checkButton.rx.tap.subscribeSuccess { (_) in
            Log.i("去看金流歷史紀錄")
        }.disposed(by: dpg)
        
        withdrawToInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            withdrawToInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
    }
}
// MARK: -
// MARK: 延伸

