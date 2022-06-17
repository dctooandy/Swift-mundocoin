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
    private let onAddAddressClick = PublishSubject<String>()
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
    // Switch
    @IBOutlet weak var topSwitchView: UIView!
    @IBOutlet weak var switchModeView: UIView!
    @IBOutlet weak var pendingImageView: UIImageView!
    @IBOutlet weak var processingImageView: UIImageView!
    @IBOutlet weak var processingLabel: UILabel!
    // Amount
    @IBOutlet weak var currencyIcon: UIImageView!
    @IBOutlet weak var topAmountLabel: UILabel!
    // Data List
    
    @IBOutlet var dataListViewArray: [UIView]!
    @IBOutlet weak var tetherLabel: UILabel!
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var confirmationsLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var completedModeView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var dataListView: UIStackView!
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
        let lineViewOne = UILabel()
        lineViewOne.textAlignment = .center
        lineViewOne.backgroundColor = .clear
        withdrawToInputView.tfMaskView.addSubview(lineViewOne)
        lineViewOne.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        lineViewOne.text = "----------------------------------------------------------"
    
        txidInputView = InputStyleView(inputViewMode: .txid("---------------------------------------------------------"))
        txidView.addSubview(txidInputView)
        txidInputView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let lineViewTwo = UILabel()
        lineViewTwo.textAlignment = .center
        lineViewTwo.backgroundColor = .clear
        txidInputView.tfMaskView.addSubview(lineViewTwo)
        lineViewTwo.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        lineViewTwo.text = "----------------------------------------------------------"
    }
    func drawDashLine(lineView : UIView,lineLength : Int ,lineSpacing : Int,lineColor : UIColor){
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = lineView.bounds
//        只要是CALayer這種類型,他的anchorPoint默認都是(0.5,0.5)
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
//        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = lineColor.cgColor

        shapeLayer.lineWidth = lineView.frame.size.height
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round

        shapeLayer.lineDashPattern = [NSNumber(value: lineLength),NSNumber(value: lineSpacing)]

        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: lineView.frame.size.width, y: 0))

        shapeLayer.path = path
        lineView.layer.addSublayer(shapeLayer)
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
        Themes.completeViewType.bind(to: completedModeView.rx.isHidden).disposed(by: dpg)
        Themes.topViewIconType.bind(to: iconImageView.rx.image).disposed(by: dpg)
        Themes.topViewLabelText.bind(to: statusLabel.rx.text).disposed(by: dpg)
        Themes.topViewLabelTextColor.bind(to: statusLabel.rx.textColor).disposed(by: dpg)
        if let confirmationsView = dataListViewArray.filter({ $0.tag == 3 }).first
        {
            Themes.txidViewType.bind(to: confirmationsView.rx.isHidden).disposed(by: dpg)
        }
        if let feeView = dataListViewArray.filter({ $0.tag == 4 }).first
        {
            Themes.txidViewType.bind(to: feeView.rx.isHidden).disposed(by: dpg)
        }
        withdrawToInputView.rxAddAddressImagePressed().subscribeSuccess { [self](isChoose) in
            if let addressText = withdrawToInputView.normalTextLabel.text
            {
                onAddAddressClick.onNext(addressText)
            }
        }.disposed(by: dpg)
        
        
    }
    func setupType()
    {
        if let dto = detailDataDto
        {
            withdrawToInputView.setVisibleString(string: dto.address)
            txidInputView.setVisibleString(string: dto.txid)
            topAmountLabel.text = dto.amount
            tetherLabel.text = dto.tether
            networkLabel.text = dto.network
            confirmationsLabel.text = dto.confirmations
            feeLabel.text = dto.fee
            dateLabel.text = dto.date
        }
    }
    func rxAddAddressClick() -> Observable<String>
    {
        return onAddAddressClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
