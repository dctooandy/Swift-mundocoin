//
//  AuditTabbar.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/6/12.
//

import Foundation
import RxCocoa
import RxSwift

class AuditTabbar: UIView {
    // MARK:業務設定
    private let onLabelClick = PublishSubject<AuditTriggerMode>()
    
    let rxItemClick = PublishSubject<Int>()
    private let dpg = DisposeBag()
    static var share = AuditTabbar.loadNib()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var detailTabbarView: UIView!
    @IBOutlet weak var acceptLabel: UILabel!
    @IBOutlet weak var rejectLabel: UILabel!
    
    @IBOutlet weak var todoView: UIView!
    @IBOutlet weak var accountView: UIView!
    
    @IBOutlet weak var todoIconImageView: UIImageView!
    @IBOutlet weak var accountIconImageView: UIImageView!
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    private lazy var icons = [todoIconImageView,accountIconImageView]
    private lazy var labels = [todoLabel,accountLabel]
    @IBOutlet weak var backgroundView:UIImageView!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        customInit()
        setupUI()
        bindLabels()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func customInit()
    {
//        loadNibContent()
    }
    // MARK: -
    // MARK:業務方法
    func bringToFront(){
        superview?.bringSubviewToFront(self)
    }
    func setupUI()
    {
        backgroundColor = .clear
        bindView()
        backgroundView.image = UIImage(color: Themes.grayF7F8FC)
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowRadius = 35
//        layer.shadowOffset = .zero
//        layer.shadowOpacity = 0.3
    }
    func bindView()
    {
        todoView.rx.click.subscribeSuccess { [weak self](_) in
            guard let weakSelf = self else {return}
            weakSelf.selected(0)
        }.disposed(by: dpg)
        accountView.rx.click.subscribeSuccess { [weak self](_) in
            guard let weakSelf = self else {return}
            weakSelf.selected(1)
        }.disposed(by: dpg)
    }
    func selected(_ index:Int ){
        rxItemClick.onNext(index)
        guard index != 2 ,
        UserStatus.share.isLogin || index < 2 else {return}
        if index == 0
        {
            todoIconImageView.image = UIImage(named: "Todo-Icon")
            accountIconImageView.image = UIImage(named: "Account-unselect-Icon")
        }else
        {
            todoIconImageView.image = UIImage(named: "Todo-unselect-Icon")
            accountIconImageView.image = UIImage(named: "Account-Icon")
        }
//        icons.forEach({$0?.image = $0?.image?.blendedByColor(.black)})
//        icons[index]?.image = icons[index]?.image?.blendedByColor(Themes.blue6149F6)
//        labels.forEach({$0?.textColor = .black})
//        labels[index]?.textColor = Themes.blue6149F6
    }
   func bindLabels()
    {
        rejectLabel.rx.click.subscribeSuccess { [self] _ in
            Log.v("不允許")
            onLabelClick.onNext(.reject)
        }.disposed(by: dpg)
        acceptLabel.rx.click.subscribeSuccess { [self] _ in
            Log.v("允許")
            onLabelClick.onNext(.accept)
        }.disposed(by: dpg)
    }
    func rxLabelClick() -> Observable<AuditTriggerMode>
    {
        return onLabelClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
