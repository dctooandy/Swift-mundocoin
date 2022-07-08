//
//  AuditTwoFACheckViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 7/7/22.
//

import Foundation
import SnapKit
import RxCocoa
import RxSwift

class AuditTwoFACheckViewController: BaseViewController {
    // MARK:業務設定
    private let onSubmitClick = PublishSubject<String>()
    private let dpg = DisposeBag()
    var emailAccountString : String = ""
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var twoFAVerifyInputView: InputStyleView!
    @IBOutlet weak var submitButton: CornerradiusButton!
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    static func instance(emailString : String ) -> AuditTwoFACheckViewController {
        let vc = AuditTwoFACheckViewController.loadNib()
        vc.emailAccountString = emailString
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Security Verification".localized
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        view.backgroundColor = Themes.black1B2559
        backView.backgroundColor = Themes.grayF4F7FE
        setupUI()
        bindButtonAction()
        bindBorderColor()
        bindTextfield()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    @objc func touch() {
        self.view.endEditing(true)
        twoFAVerifyInputView.tfMaskView.changeBorderWith(isChoose:false)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        twoFAVerifyInputView.tfMaskView.changeBorderWith(isChoose:false)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        twoFAVerifyInputView.setMode(mode: .twoFAVerify)
        twoFAVerifyInputView.backgroundColor = .clear
        submitButton.setTitle("Submit".localized, for: .normal)
        submitButton.titleLabel?.font = Fonts.pingFangTCMedium(16)
        submitButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        submitButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(twoFAVerifyInputView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.065)
        }
    }
    
    func bindButtonAction()
    {
        submitButton.rx.tap.subscribeSuccess { [self](_) in
            requestForSubmit()
        }.disposed(by: dpg)
        
    }
    func bindBorderColor()
    {
        twoFAVerifyInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            twoFAVerifyInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
    }
    func requestForSubmit()
    {
        //網路
        //假設成功
        if let codeString = twoFAVerifyInputView.textField.text
        {
            self.navigationController?.popViewController(animated: true)
            onSubmitClick.onNext(codeString)
        }
    }
    func bindTextfield()
    {
        let isCodeValid = twoFAVerifyInputView.textField.rx.text
            .map { (str) -> Bool in
                guard let acc = str else { return false  }
                return RegexHelper.match(pattern: .otp, input: acc)
        }
        isCodeValid.skip(1).bind(to: twoFAVerifyInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isCodeValid.bind(to: submitButton.rx.isEnabled).disposed(by: dpg)
    }
    func rxSubmitClick() -> Observable<String>
    {
        return onSubmitClick.asObservable()
    }
}
// MARK: -
// MARK: 延伸
