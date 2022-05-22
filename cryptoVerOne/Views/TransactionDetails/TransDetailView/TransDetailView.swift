//
//  TransDetailView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/20.
//


import Foundation
import RxCocoa
import RxSwift

class TransDetailView: UIStackView ,NibOwnerLoadable{
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var detailDataDto : DetailDto? {
        didSet{
//            setupUI()
//            bindUI()
        }
    }
    var viewType : DetailType = .pending {
        didSet{
            setupType()
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topSwitchView: UIView!
    @IBOutlet weak var switchModeView: UIView!
    @IBOutlet weak var pendingImageView: UIImageView!
    @IBOutlet weak var processingImageView: UIImageView!
    @IBOutlet weak var processingLabel: UILabel!
    
    @IBOutlet weak var CompletedModeView: UIView!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var dataListView: UIView!
    @IBOutlet weak var withdrawToView: UIView!
    @IBOutlet weak var txidView: UIView!
    var contentView: UIView!
    var withdrawToInputView : InputStyleView!
    var txidInputView : InputStyleView!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    // MARK: -
    // MARK:業務方法
    func customInit()
    {
        loadNibContent()
    }
    func setupUI()
    {
        pendingImageView.layer.borderWidth = 6
        pendingImageView.layer.borderColor = UIColor(red: 0.381, green: 0.286, blue: 0.967, alpha: 1).cgColor
        processingImageView.layer.borderWidth = 6
        processingImageView.layer.borderColor = UIColor.clear.cgColor
        processingLabel.textColor = Themes.grayE0E5F2

        withdrawToInputView = InputStyleView(inputViewMode: .withdrawAddressToDetail(true))
        withdrawToView.addSubview(withdrawToInputView)
        withdrawToInputView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        txidInputView = InputStyleView(inputViewMode: .txid(""))
        txidView.addSubview(txidInputView)
        txidInputView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    func bindUI()
    {
        txidInputView.rxTextLabelClick().subscribeSuccess { (string) in
            print("outapp url str: \(string)")
              UIApplication.shared.open((URL(string: "https://google.com.tw")!), options: [:], completionHandler: nil)
        }.disposed(by: dpg)
        withdrawToInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            withdrawToInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
        Themes.txidViewType.bind(to: txidView.rx.isHidden).disposed(by: dpg)
        Themes.processingImageType.bind(to: processingImageView.rx.borderColor).disposed(by: dpg)
        Themes.processingLabelType.bind(to: processingLabel.rx.textColor).disposed(by: dpg)
        Themes.completeViewType.bind(to: CompletedModeView.rx.isHidden).disposed(by: dpg)
    }
    func setupType()
    {
        if let dto = detailDataDto
        {
            withdrawToInputView.setVisibleString(string: dto.address)
            txidInputView.setVisibleString(string: dto.txid)
        }
    }
}
// MARK: -
// MARK: 延伸
