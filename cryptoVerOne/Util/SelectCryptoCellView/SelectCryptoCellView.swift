//
//  SelectCryptoCellView.swift
//  cryptoVerOne
//
//  Created by Andy on 2022/11/30.
//


import Foundation
import RxCocoa
import RxSwift

class SelectCryptoCellView: UIView ,NibOwnerLoadable{
    // MARK:業務設定
    private let onSelectCryptoClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var cryptoImageView: UIImageView!
    @IBOutlet weak var cryptoLabel: UILabel!
    @IBOutlet weak var selectCryptoIcon: UIImageView!
    @IBOutlet weak var selectCryptoCoverView: UIView!
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        customInit()
        setupUI()
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
        loadNibContent()
        if KeychainManager.share.getMundoCoinSelectCryptoEnable() == true
        {
            selectCryptoIcon.isHidden = false
            selectCryptoCoverView.isHidden = false
        }else
        {
            selectCryptoIcon.isHidden = true
            selectCryptoCoverView.isHidden = true
        }
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        selectCryptoCoverView.rx.click.subscribeSuccess { [self] _ in
            onSelectCryptoClick.onNext(())
        }.disposed(by: dpg)
    }
    func rxSelectCryptoClick() -> Observable<Any>
    {
        return onSelectCryptoClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
