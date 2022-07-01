//
//  TransTopView.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/20.
//


import Foundation
import RxCocoa
import RxSwift

class TransTopView: UIView,NibOwnerLoadable {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var topViewType : DetailType = .pending {
        didSet{
            setupType()
        }
    }
    var transID : String = ""
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topIconImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        bindUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    // MARK: -
    // MARK:業務方法
    func customInit()
    {
        loadNibContent()
    }
    func bindUI()
    {
        TransStyleThemes.topImageIconType.bind(to: topIconImageView.rx.image).disposed(by: dpg)
        TransStyleThemes.topLabelStringType.bind(to: topLabel.rx.text).disposed(by: dpg)
    }
    func setupType()
    {
        TransStyleThemes.share.acceptTopViewStatusStyle(topViewType)
    }
}
// MARK: -
// MARK: 延伸
