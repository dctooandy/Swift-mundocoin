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
    private var currentNetwotkMethod = ""
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var dropdownView: DropDownStyleView!
    @IBOutlet weak var addressStyleView: InputStyleView!
    @IBOutlet weak var networkView: DynamicCollectionView!
    @IBOutlet weak var nameStyleView: InputStyleView!
    @IBOutlet weak var walletLabelStyleView: InputStyleView!
    @IBOutlet weak var checkBox: CheckBoxView!
    @IBOutlet weak var saveButton: CornerradiusButton!
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
        bindTextfield()
        bindDynamicView()
        bindSaveButton()
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        addressStyleView.tfMaskView.changeBorderWith(isChoose:false)
        nameStyleView.tfMaskView.changeBorderWith(isChoose:false)
        walletLabelStyleView.tfMaskView.changeBorderWith(isChoose:false)
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
        nameStyleView.setMode(mode: .customLabel("Name"))
        walletLabelStyleView.setMode(mode: .customLabel("Wallet label (Optional)"))
        checkBox.checkType = .checkType
        checkBox.isSelected = true
        saveButton.setTitle("Save".localized, for: .normal)
    }
    func bindTextfield()
    {
        addressStyleView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            addressStyleView.tfMaskView.changeBorderWith(isChoose:isChoose)
            addressStyleView.changeInvalidLabelAndMaskBorderColor(with:"")
            addressStyleView.invalidLabel.isHidden = true
        }.disposed(by: dpg)
        nameStyleView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            nameStyleView.tfMaskView.changeBorderWith(isChoose:isChoose)
            nameStyleView.changeInvalidLabelAndMaskBorderColor(with:"")
            nameStyleView.invalidLabel.isHidden = true
        }.disposed(by: dpg)
        walletLabelStyleView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            walletLabelStyleView.tfMaskView.changeBorderWith(isChoose:isChoose)
            walletLabelStyleView.changeInvalidLabelAndMaskBorderColor(with:"")
            walletLabelStyleView.invalidLabel.isHidden = true
        }.disposed(by: dpg)
        let isAddressValid = addressStyleView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. coinAddress, input: acc)
        }
        isAddressValid.skip(1).bind(to: addressStyleView.invalidLabel.rx.isHidden).disposed(by: dpg)
        let isNameValid = nameStyleView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. delegateName, input: acc)
        }
        isNameValid.skip(1).bind(to: nameStyleView.invalidLabel.rx.isHidden).disposed(by: dpg)
        Observable.combineLatest(isAddressValid,isNameValid)
            .map { return $0.0 && $0.1 } //reget match result
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: dpg)
    }
    func bindDynamicView()
    {
        networkView.rxCellClick().subscribeSuccess { data in
            Log.v("NetworkMethod 點到 \(data.1)")
            self.currentNetwotkMethod = data.1
        }.disposed(by: dpg)
    }
    func bindSaveButton()
    {
        saveButton.rx.tap.subscribeSuccess { [self](_) in
            Log.v("點到Save")
            let coinString = dropdownView.topLabel.text ?? ""
            let addressString = addressStyleView.textField.text ?? ""
            let nameString = nameStyleView.textField.text ?? ""
            let walletLabelString = walletLabelStyleView.textField.text ?? ""
            let isAddToWhiteList = checkBox.isSelected
            let address = AddressBookDto(coin: coinString, address: addressString, network: currentNetwotkMethod, name: nameString, walletLabel: walletLabelString, isWhiteList: isAddToWhiteList)
            if KeychainManager.share.saveAddressbook(address) == true
            {
                self.navigationController?.popViewController(animated: true)
            }else
            {
                Log.i("資料異常,無法存入")
            }
        }.disposed(by: dpg)
    }
}
// MARK: -
// MARK: 延伸
