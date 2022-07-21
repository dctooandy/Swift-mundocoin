//
//  IDVerificationViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/6.
//

import Foundation
import RxCocoa
import RxSwift
import DropDown

class IDVerificationViewController: BaseViewController {
    // MARK:業務設定
    private let onSkipClick = PublishSubject<Any>()
    private let onGoClick = PublishSubject<String>()
    private let dpg = DisposeBag()
    var dropDataSource = ["Taiwan","USA","UK","Japan"]
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var skipLabel: UILabel!
    @IBOutlet weak var idTitleLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    lazy var countryTopLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.textColor = .black
        lb.text = "Country of Residence".localized
        lb.font = Fonts.PlusJakartaSansMedium(14)
        return lb
    }()
    lazy var countryTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = Fonts.PlusJakartaSansMedium(16)
        tf.keyboardType = .numberPad
        tf.placeholder = "Choose a country".localized
        return tf
    }()
    lazy var chooseButton:UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        return btn
    }()
    lazy var chooseDropDown = DropDown()
    lazy var anchorView : UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    lazy var goButton = CornerradiusButton()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
        bindTextfield()
        setupChooseDropdown()
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(Views.topOffset + 12.0)
        }
        backgroundImageView.layer.cornerRadius = 20
        backgroundImageView.layer.contents = UIImage(color: .white)?.cgImage
        backgroundImageView.layer.addShadow()
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        view.backgroundColor = Themes.grayF4F7FE
        idTitleLabel.text = "Identity Verification".localized
        discriptionLabel.text = "Welcom to Mundocoin. Please verify your identify. Ensure the safety and security of Mundo. ".localized
        view.addSubview(countryTopLabel)
        view.addSubview(countryTextField)
        view.addSubview(anchorView)
        view.addSubview(chooseButton)
        view.addSubview(goButton)
        countryTextField.delegate = self
        
        let textFieldMulH = height(48.0/812.0)
        let tfWidth = width(361.0/414.0) - 40
        countryTextField.snp.makeConstraints { (make) in
            make.top.equalTo(discriptionLabel.snp.bottom).offset(80)
            make.height.equalTo(textFieldMulH)
            make.centerX.equalTo(discriptionLabel)
            make.width.equalTo(tfWidth)
        }
        countryTextField.setMaskView()
        anchorView.snp.makeConstraints { (make) in
            make.top.equalTo(countryTextField.snp.bottom)
            make.height.equalTo(textFieldMulH)
            make.centerX.equalTo(discriptionLabel)
            make.width.equalTo(tfWidth)
        }
        chooseButton.snp.makeConstraints { (make) in
            make.edges.equalTo(countryTextField)
        }
        countryTopLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(countryTextField.snp.top).offset(-17)
            make.left.equalTo(countryTextField).offset(-10)
            make.height.equalTo(17)
        }
        goButton.titleLabel?.font = Fonts.PlusJakartaSansRegular(16)
        goButton.setTitle("Let’s go".localized, for: .normal)
        goButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        goButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        goButton.snp.makeConstraints { (make) in
            make.top.equalTo(countryTextField.snp.bottom).offset(40)
            make.centerX.equalTo(countryTextField)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.065)
        }
    }
    func bindUI()
    {
        skipLabel.rx.click.subscribeSuccess { () in
            self.skipDismissAction()
        }.disposed(by: dpg)
        chooseButton.rx.tap.subscribeSuccess { (_) in
            self.chooseDropDown.show()
        }.disposed(by: dpg)
        goButton.rx.tap.subscribeSuccess { [self] (_) in
            // 傳送國別
            // 登入
            if let countryString = countryTextField.text
            {
                onGoClick.onNext(countryString)
            }
        }.disposed(by: dpg)
    }
    func bindTextfield()
    {
//        let isValid = countryTextField.rx.text
//            .map {  (str) -> Bool in
//                guard  let acc = str else { return false  }
//                return RegexHelper.match(pattern: .countryName, input: acc)
//        }
//        
//        isValid.bind(to: goButton.rx.isEnabled)
//            .disposed(by: dpg)
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
            self?.countryTextField.text = item
        }
        chooseDropDown.dismissMode = .onTap
    }
    func skipDismissAction()
    {
        dismiss(animated: true) {
            self.onSkipClick.onNext(())
        }
    }
    func rxSkipAction() -> Observable<(Any)>
    {
        return onSkipClick.asObserver()
    }
    func rxGoAction() -> Observable<(String)>
    {
        return onGoClick.asObserver()
    }
}
// MARK: -
// MARK: 延伸
extension IDVerificationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
