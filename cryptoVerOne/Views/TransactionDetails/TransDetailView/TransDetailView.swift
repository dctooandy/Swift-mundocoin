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
            resetAddressInputView()
//            setupUI()
//            bindUI()
        }
    }
    var viewType : DetailType = .pending {
        didSet{
            setupType()
        }
    }
    
    @IBOutlet weak var fromHeight: NSLayoutConstraint!
    @IBOutlet weak var withdrawToHeight: NSLayoutConstraint!
    @IBOutlet weak var topSwitchViewHeight: NSLayoutConstraint!
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
    @IBOutlet weak var fromView: UIView!
    @IBOutlet weak var fromWhiteView: UIView!
    @IBOutlet weak var withdrawToView: UIView!
    
    @IBOutlet weak var txidView: UIView!

    @IBOutlet weak var middleWhiteView: UIView!
    var fromInputView : InputStyleView!
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

        fromInputView = InputStyleView(inputViewMode: .withdrawAddressToDetail(true))
        fromView.addSubview(fromInputView)
        fromInputView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        withdrawToInputView = InputStyleView(inputViewMode: .withdrawAddressToDetail(true))
        withdrawToView.addSubview(withdrawToInputView)
        withdrawToInputView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let lineViewOne = UILabel()
        lineViewOne.textAlignment = .center
        lineViewOne.backgroundColor = .clear
        lineViewOne.textColor = Themes.grayA3AED0
        lineViewOne.lineBreakMode = .byCharWrapping
        withdrawToInputView.tfMaskView.addSubview(lineViewOne)
        lineViewOne.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(2)
        }
        lineViewOne.text = "----------------------------------------------------------"
    
        txidInputView = InputStyleView(inputViewMode: .txid("---------------------------------------------------------"))
        txidView.addSubview(txidInputView)
        txidInputView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
//        let lineViewTwo = UILabel()
//        lineViewTwo.textAlignment = .center
//        lineViewTwo.backgroundColor = .clear
//        lineViewTwo.textColor = Themes.grayA3AED0
//        lineViewTwo.lineBreakMode = .byCharWrapping
//        txidInputView.tfMaskView.addSubview(lineViewTwo)
//        lineViewTwo.snp.makeConstraints { make in
//            make.top.equalToSuperview()
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(2)
//        }
//        lineViewTwo.text = "----------------------------------------------------------"
        dataListView.layer.cornerRadius = 16
        dataListView.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMinXMaxYCorner]
        dataListView.layer.masksToBounds = true
    }
    func resetAddressInputView(isAuto:Bool = true ,detailType:DetailType = .done)
    {
        if let trueDetailType = detailDataDto?.detailType
        {
            if detailDataDto?.type == "DEPOSIT"
            {
                var typeValue:DetailType
                if isAuto == false
                {
                    typeValue = detailType
                }else
                {
                    typeValue = trueDetailType
                }
                if typeValue == .innerFailed || typeValue == .innerDone
                {
                    fromInputView.topLabel.text = InputViewMode.withdrawAddressInnerFromDetail.topString()
                    txidInputView.isHidden = true
                }else
                {
                    fromInputView.topLabel.text = InputViewMode.withdrawAddressFromDetail.topString()
                    txidInputView.isHidden = false
                }
            }else
            {
                fromInputView.topLabel.text = InputViewMode.withdrawAddressFromDetail.topString()
            }
        }
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
            var outPutString = ""
#if Mundo_PRO || Mundo_STAGE || Approval_PRO || Approval_STAGE
            outPutString = "https://tronscan.org/#/transaction/\(string)"
#else
            outPutString = "https://shasta.tronscan.org/#/transaction/\(string)"
#endif
            Log.v("outapp url str: \(outPutString)")
            UIApplication.shared.open((URL(string: outPutString)!), options: [:], completionHandler: nil)
        }.disposed(by: dpg)
        fromInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            fromInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
        withdrawToInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            withdrawToInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
        
        TransStyleThemes.txidViewType.bind(to: txidView.rx.isHidden).disposed(by: dpg)
        TransStyleThemes.processingImageType.bind(to: processingImageView.rx.borderColor).disposed(by: dpg)
        
        TransStyleThemes.processingLabelType.bind(to: processingLabel.rx.textColor).disposed(by: dpg)
        TransStyleThemes.completeViewType.bind(to: completedModeView.rx.isHidden).disposed(by: dpg)
        TransStyleThemes.topViewHeightType.bind(to: topSwitchViewHeight.rx.constant).disposed(by: dpg)
        
        TransStyleThemes.topViewIconType.bind(to: iconImageView.rx.image).disposed(by: dpg)
        TransStyleThemes.topViewLabelText.bind(to: statusLabel.rx.text).disposed(by: dpg)
        TransStyleThemes.topViewLabelTextColor.bind(to: statusLabel.rx.textColor).disposed(by: dpg)
//        if let confirmationsView = dataListViewArray.filter({ $0.tag == 3 }).first
//        {
//            if detailDataDto?.showMode != .deposits
//            {
//                TransStyleThemes.txidViewType.bind(to: confirmationsView.rx.isHidden).disposed(by: dpg)
//            }else
//            {
//                confirmationsView.isHidden = true
//            }
//        }
        fromInputView.rxAddAddressImagePressed().subscribeSuccess { [self](isChoose) in
            if let addressText = fromInputView.normalTextLabel.text
            {
                onAddAddressClick.onNext(addressText)
            }
        }.disposed(by: dpg)
        withdrawToInputView.rxAddAddressImagePressed().subscribeSuccess { [self](isChoose) in
            if let addressText = withdrawToInputView.normalTextLabel.text
            {
                onAddAddressClick.onNext(addressText)
            }
        }.disposed(by: dpg)
#if Mundo_PRO || Approval_PRO
                
#else
        bindCurrencyIcon()
#endif
    }
    func bindCurrencyIcon()
    {
#if Mundo_PRO || Mundo_STAGE || Approval_PRO || Approval_STAGE
                
#else    
        currencyIcon.rx.click.subscribeSuccess { [self] _ in
            if KeychainManager.share.getDomainMode() == .Dev ||
                KeychainManager.share.getDomainMode() == .Qa
            {
                var type : DetailType!
                if viewType == .done
                {
                    type = .innerDone
                }else if viewType == .innerDone
                {
                    type = .failed
                }else if viewType == .failed
                {
                    type = .innerFailed
                }else if viewType == .innerFailed
                {
                    type = .pending
                }else if viewType == .pending
                {
                    type = .processing
                }else
                {
                    type = .done
                }
                resetAddressInputView(isAuto: false, detailType: type)
                TransStyleThemes.share.acceptTopViewStatusStyle(type)
                viewType = type                
            }
        }.disposed(by: dpg)
#endif
    }
    func setupType()
    {
        if let dto = detailDataDto ,fromInputView != nil
        {
            var fromAddress = ""
            var withdrawToAddress = ""
            if dto.type == "DEPOSIT"
            {
                fromAddress = dto.fromAddress
            }else
            {
                if dto.fromAddress.isEmpty == false
                {
                    fromAddress = dto.fromAddress
                }else
                {
                    fromAddress = "--"
                }
                withdrawToAddress = dto.address
            }
            // MC524 暫時隱藏
//            let fromStringHeight = fromAddress.height(withConstrainedWidth: (Views.screenWidth - 115), font:  Fonts.PlusJakartaSansRegular(14))
            let fromStringHeight = fromAddress.height(withConstrainedWidth: (Views.screenWidth - 115 - 34), font:  Fonts.PlusJakartaSansRegular(14))
            let withdrawToStringHeight = withdrawToAddress.height(withConstrainedWidth: (Views.screenWidth - 115 - 34), font:  Fonts.PlusJakartaSansRegular(14))
            fromInputView.tvHeightConstraint.constant = (fromStringHeight + 18)
            fromInputView.setVisibleString(string: fromAddress)
            withdrawToInputView.tvHeightConstraint.constant = (withdrawToStringHeight + 18)
            withdrawToInputView.setVisibleString(string: withdrawToAddress)
            txidInputView.setVisibleString(string: dto.txid.isEmpty ? "--":dto.txid)
            let flagAmount = (dto.showMode == .deposits ? "+" : "-")
            topAmountLabel.text = "\(flagAmount)\(dto.amount.numberFormatter(.decimal, 8))"
            tetherLabel.text = dto.tether
            networkLabel.text = dto.network
            confirmationsLabel.text = dto.confirmations
            feeLabel.text = dto.fee
            dateLabel.text = dto.date
            if dto.type == "DEPOSIT"
            {
                if let confirmationsView = dataListViewArray.filter({ $0.tag == 3 }).first
                {
                    confirmationsView.isHidden = true
                }
//                if let feeView = dataListViewArray.filter({ $0.tag == 4 }).first
//                {
//                    feeView.isHidden = true
//                }
//                middleWhiteView.isHidden = true
//                withdrawToInputView.isHidden = false
//                withdrawToHeight.constant = 46 + fromStringHeight
                fromWhiteView.isHidden = true
                withdrawToView.isHidden = true
                withdrawToInputView.isHidden = true
            }else
            {
                if let confirmationsView = dataListViewArray.filter({ $0.tag == 3 }).first
                {
                    TransStyleThemes.txidViewType.bind(to: confirmationsView.rx.isHidden).disposed(by: dpg)
                }
                if let feeView = dataListViewArray.filter({ $0.tag == 4 }).first
                {
                    feeView.isHidden = false
                    // 0818 產品驗收 不隱藏了
//                    TransStyleThemes.feeViewType.bind(to: feeView.rx.isHidden).disposed(by: dpg)
                }
//                withdrawToInputView.isHidden = false
//                withdrawToHeight.constant = 46 + fromStringHeight
//                TransStyleThemes.txidViewType.bind(to: middleWhiteView.rx.isHidden).disposed(by: dpg)
                fromWhiteView.isHidden = false
                withdrawToView.isHidden = false
                withdrawToInputView.isHidden = false
                withdrawToHeight.constant = 46 + withdrawToStringHeight
            }
            fromInputView.isHidden = false
            fromHeight.constant = 46 + fromStringHeight
            TransStyleThemes.txidViewType.bind(to: middleWhiteView.rx.isHidden).disposed(by: dpg)
        }
    }
    func rxAddAddressClick() -> Observable<String>
    {
        return onAddAddressClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
