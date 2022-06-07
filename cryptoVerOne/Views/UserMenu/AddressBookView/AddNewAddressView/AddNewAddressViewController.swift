//
//  AddNewAddressViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 6/7/22.
//

import Foundation
import RxCocoa
import RxSwift

class AddNewAddressViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var dropdownView: DropDownStyleView!
    var addressView : InputStyleView! = InputStyleView(inputViewMode: .address)
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add new address".localized
        view.backgroundColor = Themes.grayF4F7FE
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
        dropdownView.config(showDropdown: true, dropDataSource: ["USDT","USD"])
        dropdownView.layer.cornerRadius = 10
        dropdownView.layer.masksToBounds = true
        dropdownView?.layer.borderColor = #colorLiteral(red: 0.9058823529, green: 0.9254901961, blue: 0.968627451, alpha: 1)
        dropdownView?.layer.borderWidth = 1
        dropdownView.topLabel.font = Fonts.pingFangSCRegular(14)
        
        view.addSubview(addressView)
        addressView.snp.makeConstraints { (make) in
            make.top.equalTo(dropdownView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
            make.height.equalTo(Themes.inputViewDefaultHeight)
        }
    }
}
// MARK: -
// MARK: 延伸
