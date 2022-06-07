//
//  DropDownStyleView.swift
//  cryptoVerOne
//
//  Created by BBk on 6/7/22.
//


import Foundation
import RxCocoa
import RxSwift
import DropDown

class DropDownStyleView: UIView {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    var dropDataSource : [String] = [""] {
        didSet{
            chooseDropDown.dataSource = dropDataSource
        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topIconImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topDrawDownIamge: UIImageView!
    let chooseDropDown = DropDown()
    let anchorView : UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    // MARK: -
    // MARK:Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupChooseDropdown()
        bindUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        addSubview(anchorView)
        anchorView.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom)
            make.height.equalTo(self)
            make.centerX.equalTo(topLabel)
            make.width.equalTo(topLabel)
        }
    }
    func bindUI()
    {
        topDrawDownIamge.rx.click.subscribeSuccess { (_) in
            self.chooseDropDown.show()
        }.disposed(by: dpg)
    }
    func setupChooseDropdown()
    {
        DropDown.setupDefaultAppearance()
        chooseDropDown.anchorView = anchorView
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
//        chooseDropDown.bottomOffset = CGPoint(x: 0, y:(chooseDropDown.anchorView?.plainView.bounds.height)!)
        chooseDropDown.topOffset = CGPoint(x: 0, y:-(chooseDropDown.anchorView?.plainView.bounds.height)!)
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseDropDown.direction = .bottom
        chooseDropDown.dataSource = dropDataSource
        
        // Action triggered on selection
        chooseDropDown.selectionAction = { [weak self] (index, item) in
//            self?.chooseButton.setTitle(item, for: .normal)
            self?.topLabel.text = item
        }
        chooseDropDown.dismissMode = .onTap
    }
}
// MARK: -
// MARK: 延伸
