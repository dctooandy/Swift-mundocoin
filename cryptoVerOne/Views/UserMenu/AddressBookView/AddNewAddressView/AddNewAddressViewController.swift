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
    @IBOutlet weak var addressStyleView: InputStyleView!
    @IBOutlet weak var networkView: DynamicCollectionView!
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add new address".localized
        view.backgroundColor = Themes.grayF4F7FE
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        setupUI()
        bindTextfield()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        networkView.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.left)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        addressStyleView.tfMaskView.changeBorderWith(isChoose:false)
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
        addressStyleView.setMode(mode: .address)
        networkView.setData(type: .networkMethod)
    }
    func bindTextfield()
    {
        addressStyleView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            addressStyleView.tfMaskView.changeBorderWith(isChoose:isChoose)
            addressStyleView.changeInvalidLabelAndMaskBorderColor(with:"")
            addressStyleView.invalidLabel.isHidden = true
        }.disposed(by: dpg)
        let isValid = addressStyleView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. coinAddress, input: acc)
        }
        isValid.skip(1).bind(to: addressStyleView.invalidLabel.rx.isHidden).disposed(by: dpg)
//        isValid.bind(to: verifyButton.rx.isEnabled).disposed(by: dpg)
    }
    func bindDynamicView()
    {
        networkView.rxCellClick().subscribeSuccess { data in
            Log.v("NetworkMethod 點到 \(data.1)")
        }.disposed(by: dpg)
    }
}
// MARK: -
// MARK: 延伸
