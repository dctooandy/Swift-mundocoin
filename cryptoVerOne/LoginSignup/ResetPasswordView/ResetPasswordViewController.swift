//
//  ResetPasswordViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/6.
//

import Foundation
import RxCocoa
import RxSwift

class ResetPasswordViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    private let cancelImg = UIImage(named: "icon-close")!
    fileprivate let changedPWVC = CPasswordViewController.loadNib()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topLabel: UILabel!
    let newPWTopLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.textColor = .black
        lb.text = "New Password".localized
        lb.font = Fonts.pingFangSCRegular(16)
        return lb
    }()
    let newPWTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = Fonts.pingFangSCRegular(16)
        tf.keyboardType = .numberPad
        return tf
    }()
    let newPWInvalidLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.font = Fonts.pingFangSCRegular(14)
        lb.textColor = .red
        lb.text = "Enter the 6-digit code".localized
        lb.isHidden = true
        return lb
    }()
    let confirmPWTopLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.textColor = .black
        lb.text = "Confirm new password".localized
        lb.font = Fonts.pingFangSCRegular(16)
        return lb
    }()
    let confirmPWTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = Fonts.pingFangSCRegular(16)
        tf.keyboardType = .numberPad
        return tf
    }()
    
    let confirmPWInvalidLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.font = Fonts.pingFangSCRegular(14)
        lb.textColor = .red
        lb.text = "Enter the 6-digit code".localized
        lb.isHidden = true
        return lb
    }()
    private lazy var backBtn:UIButton = {
        let btn = UIButton()
        let image = UIImage(named:"back")?.reSizeImage(reSize: CGSize(width: Views.backImageHeight(), height: Views.backImageHeight())).withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
//        btn.setImage(UIImage(named:"left-arrow"), for:.normal)
        btn.tintColor = .black
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        btn.setTitle("", for:.normal)
        return btn
    }()
    let newPWCancelRightButton = UIButton()
    let confirmPWCancelRightButton = UIButton()
    let submitButton = CornerradiusButton()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:backBtn)
        setupUI()
        bindPwdButton()
        bindTextfield()
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
        topLabel.text = "Reset password".localized
        view.addSubview(newPWTopLabel)
        view.addSubview(newPWTextField)
        view.addSubview(newPWInvalidLabel)
        view.addSubview(confirmPWTopLabel)
        view.addSubview(confirmPWTextField)
        view.addSubview(confirmPWInvalidLabel)
        view.addSubview(newPWCancelRightButton)
        view.addSubview(confirmPWCancelRightButton)
        view.addSubview(submitButton)
        newPWTextField.delegate = self
        confirmPWTextField.delegate = self
        let textFieldMulH = height(48/812)
        let invalidH = height(20/812)
        let tfWidth = width(361.0/414.0) - 40
        newPWTextField.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(80)
            make.height.equalTo(textFieldMulH)
            make.centerX.equalToSuperview()
            make.width.equalTo(tfWidth)
        }
        newPWTextField.setMaskView()
        newPWTopLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(newPWTextField.snp.top).offset(-17)
            make.left.equalTo(newPWTextField).offset(-10)
            make.height.equalTo(17)
        }
        newPWInvalidLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newPWTextField.snp.bottom).offset(5)
            make.left.equalTo(newPWTextField)
            make.height.equalTo(invalidH)
        }
        
        confirmPWTextField.snp.makeConstraints { (make) in
            make.top.equalTo(newPWTextField.snp.bottom).offset(65)
            make.height.equalTo(textFieldMulH)
            make.centerX.equalToSuperview()
            make.width.equalTo(tfWidth)
        }
        confirmPWTextField.setMaskView()
        confirmPWTopLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(confirmPWTextField.snp.top).offset(-17)
            make.left.equalTo(confirmPWTextField).offset(-10)
            make.height.equalTo(17)
        }
        confirmPWInvalidLabel.snp.makeConstraints { (make) in
            make.top.equalTo(confirmPWTextField.snp.bottom).offset(5)
            make.left.equalTo(confirmPWTextField)
            make.height.equalTo(invalidH)
        }
        submitButton.titleLabel?.font = Fonts.pingFangTCRegular(16)
        submitButton.setTitle("Submit".localized, for: .normal)
        submitButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        submitButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmPWInvalidLabel.snp.bottom).offset(10)
            make.centerX.equalTo(confirmPWTextField)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.065)
        }
        newPWTextField.setPlaceholder("********", with: Themes.grayLighter)
        confirmPWTextField.setPlaceholder("********", with: Themes.grayLighter)
        //設定文字刪除
        newPWCancelRightButton.setBackgroundImage(cancelImg, for: .normal)
        newPWCancelRightButton.backgroundColor = .black
        newPWCancelRightButton.layer.cornerRadius = 7
        newPWCancelRightButton.layer.masksToBounds = true
        newPWCancelRightButton.snp.makeConstraints { (make) in
            make.right.equalTo(newPWTextField).offset(-5)
            make.centerY.equalTo(newPWTextField)
            make.width.height.equalTo(14)
        }
        confirmPWCancelRightButton.setBackgroundImage(cancelImg, for: .normal)
        confirmPWCancelRightButton.backgroundColor = .black
        confirmPWCancelRightButton.layer.cornerRadius = 7
        confirmPWCancelRightButton.layer.masksToBounds = true
        confirmPWCancelRightButton.snp.makeConstraints { (make) in
            make.right.equalTo(confirmPWTextField).offset(-5)
            make.centerY.equalTo(confirmPWTextField)
            make.width.height.equalTo(14)
        }
    }
    func bindPwdButton()
    {
        newPWCancelRightButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.newPWTextField.text = ""
                self?.newPWTextField.sendActions(for: .valueChanged)
            }.disposed(by: dpg)
        confirmPWCancelRightButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.confirmPWTextField.text = ""
                self?.confirmPWTextField.sendActions(for: .valueChanged)
            }.disposed(by: dpg)
        submitButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.submitButtonPressed()
            }.disposed(by: dpg)
    }
    func bindTextfield()
    {
        let isNewPWValid = newPWTextField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. password, input: acc)
        }
        let isConPWValid = confirmPWTextField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return acc == self.newPWTextField.text
        }
        isNewPWValid.skip(1).bind(to: newPWInvalidLabel.rx.isHidden).disposed(by: dpg)
        isConPWValid.skip(1).bind(to: confirmPWInvalidLabel.rx.isHidden).disposed(by: dpg)

        Observable.combineLatest(isNewPWValid, isConPWValid)
            .map { return $0.0 && $0.1 } //reget match result
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: dpg)
    }
    func submitButtonPressed()
    {
        self.navigationController?.pushViewController(changedPWVC, animated: true)
    }
    @objc func popVC(isAnimation : Bool = true)
    {
        _ = self.navigationController?.popToRootViewController(animated: isAnimation)
    }
}
// MARK: -
// MARK: 延伸
extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newPWTextField {
            confirmPWTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
