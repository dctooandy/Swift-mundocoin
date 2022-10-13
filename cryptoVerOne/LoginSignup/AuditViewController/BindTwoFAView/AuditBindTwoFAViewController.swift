//
//  AuditBindTwoFAViewController.swift
//  cryptoVerOne
//
//  Created by BBk on 7/7/22.
//

import Foundation
import RxCocoa
import RxSwift

class AuditBindTwoFAViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static let share: AuditBindTwoFAViewController = AuditBindTwoFAViewController.loadNib()
    var qrCodeString : String = ""
    @IBOutlet weak var topIconTopConstant: NSLayoutConstraint!
    var emailAccountString : String = ""
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet weak var twoFAInputView: InputStyleView!
    @IBOutlet weak var emailVerifyInputView: InputStyleView!
    @IBOutlet weak var copyInputView: InputStyleView!
    @IBOutlet weak var bindButton: CornerradiusButton!
    @IBOutlet weak var downloadButton: CornerradiusButton!
    let downloadTextLabel: UnderlinedLabel = {
        let tfLabel = UnderlinedLabel()
        tfLabel.contentMode = .center
        tfLabel.backgroundColor = .clear
        tfLabel.font = Fonts.PlusJakartaSansBold(14)
        tfLabel.numberOfLines = 0
        tfLabel.adjustsFontSizeToFitWidth = true
        tfLabel.minimumScaleFactor = 0.8
        tfLabel.isUserInteractionEnabled = true
        tfLabel.isGrayColor = true
        tfLabel.text = "Download Google Authentication"
        return tfLabel
    }()
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton(iconName: "audit-icon-chevron-left")
        btn.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    // MARK: -
    // MARK:Life cycle
    static func instance(emailString : String ) -> AuditBindTwoFAViewController {
        let vc = AuditBindTwoFAViewController.loadNib()
        vc.emailAccountString = emailString
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Google Authentication".localized
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        view.backgroundColor = Themes.black1B2559
        scrollView.backgroundColor = Themes.grayF4F7FE
        setupUI()
        bindButtonAction()
        bindTextfield()
        bindCancelButton()
        setScrollView()
        setNotification()
        bindInputAction()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailVerifyInputView.setMode(mode: .emailVerify(emailAccountString))
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,.font: Fonts.PlusJakartaSansBold(20)]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        verifyResentAutoPressed()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailVerifyInputView.resetTimerAndAll()
    }
    @objc func touch() {
        self.view.endEditing(true)
        copyInputView.tfMaskView.changeBorderWith(isChoose:false)
        emailVerifyInputView.tfMaskView.changeBorderWith(isChoose:false)
        twoFAInputView.tfMaskView.changeBorderWith(isChoose:false)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        copyInputView.tfMaskView.changeBorderWith(isChoose:false)
        emailVerifyInputView.tfMaskView.changeBorderWith(isChoose:false)
        twoFAInputView.tfMaskView.changeBorderWith(isChoose:false)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        qrCodeString = "THFfxoxMtMJGnjar...cXUNbHzry3"
        let image = UIImage().generateQRCode(from: qrCodeString, imageView: codeImageView, logo:nil)
        codeImageView.image = image
        copyInputView.setMode(mode: .copy)
        copyInputView.textField.text = qrCodeString
        emailVerifyInputView.setMode(mode: .emailVerify(emailAccountString))
        twoFAInputView.setMode(mode: .twoFAVerify)

        bindButton.setTitle("Bind".localized, for: .normal)
        bindButton.titleLabel?.font = Fonts.SFProDisplaySemibold(16)
        bindButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        bindButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        bindButton.snp.makeConstraints { (make) in
            make.top.equalTo(twoFAInputView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
        view.addSubview(downloadTextLabel)
        downloadTextLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(bindButton)
            make.top.equalTo(bindButton.snp.bottom).offset(14)
        }
    }
    func bindButtonAction()
    {
        bindButton.rx.tap.subscribeSuccess { [self](_) in
            requestForBindAuth()
        }.disposed(by: dpg)
        downloadTextLabel.rx.click.subscribeSuccess { (_) in
            if let url = URL(string: "itms-apps://apple.com/app/id388497605") {
                UIApplication.shared.open(url)
            }
        }.disposed(by: dpg)
    }
    func bindInputAction()
    {
        emailVerifyInputView.rxSendVerifyAction().subscribeSuccess { (_) in
//            self?.verifyResentPressed()
        }.disposed(by: dpg)
    }
    
    func verifyResentPressed(byVC:Bool = false)
    {
        let loginDto = KeychainManager.share.getLastAccount()
        if let userEmail = loginDto?.account
        {
            Log.v("重發驗證")
            Beans.loginServer.verificationResend(idString: userEmail).subscribe { [self]dto in
                if let dataDto = dto
                {
                    let countTime = (dataDto.nextTimestamp - dataDto.currentTimestamp)/1000
                    resetCountDownNumber(number: countTime,byVC: byVC)
                }
            } onError: { error in
                ErrorHandler.show(error: error)
            }.disposed(by: dpg)
        }
    }
    func resetCountDownNumber(number:Int ,byVC:Bool)
    {
        emailVerifyInputView.setupCountTime(seconds: number)
    }
    func bindTextfield()
    {
        let isEmailCodeValid = emailVerifyInputView.textField.rx.text
            .map { (str) -> Bool in
                guard let acc = str else { return false  }
                return RegexHelper.match(pattern: .otp, input: acc)
        }
        let isTwoFACodeValid = twoFAInputView.textField.rx.text
            .map { (str) -> Bool in
                guard let acc = str else { return false  }
                return RegexHelper.match(pattern: .otp, input: acc)
        }
        isEmailCodeValid.skip(1).bind(to: emailVerifyInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isTwoFACodeValid.skip(1).bind(to: twoFAInputView.invalidLabel.rx.isHidden).disposed(by: dpg)

        Observable.combineLatest(isTwoFACodeValid, isEmailCodeValid)
            .map { return $0.0 && $0.1 } //reget match result
            .bind(to: bindButton.rx.isEnabled)
            .disposed(by: dpg)
        copyInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            copyInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
            emailVerifyInputView.tfMaskView.changeBorderWith(isChoose:false)
            twoFAInputView.tfMaskView.changeBorderWith(isChoose:false)
        }.disposed(by: dpg)
        emailVerifyInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            copyInputView.tfMaskView.changeBorderWith(isChoose:false)
            emailVerifyInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
            twoFAInputView.tfMaskView.changeBorderWith(isChoose:false)
        }.disposed(by: dpg)
        twoFAInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            copyInputView.tfMaskView.changeBorderWith(isChoose:false)
            emailVerifyInputView.tfMaskView.changeBorderWith(isChoose:false)
            twoFAInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
    }
    func bindCancelButton()
    {
//        let _ =  twoFAView.textField.rx.text.map({$0 ?? ""})
//            .map({$0.isEmpty})
//            .bind(to: twoFAView.cancelRightButton.rx.isHidden)
//            .disposed(by: dpg)
    }
    func verifyResentAutoPressed()
    {
        emailVerifyInputView.emailSendVerify()
    }
    func setScrollView()
    {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)
    }
    func setNotification()
    {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    func requestForBindAuth()
    {
        //網路
        //假設成功
        let finishVC = AuditTwoFAFinishViewController.loadNib()
        self.navigationController?.pushViewController(finishVC, animated: true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            var showKeyBoard = false
            var maxY:CGFloat = 0.0
            if ((twoFAInputView?.textField.isFirstResponder) == true)
            {
                showKeyBoard = true
                maxY = twoFAInputView.frame.maxY
            }else if ((emailVerifyInputView?.textField.isFirstResponder) == true)
            {
                showKeyBoard = true
                maxY = emailVerifyInputView.frame.maxY
            }
            if showKeyBoard == true
            {
                let diffHeight = Views.screenHeight - maxY
                if diffHeight < (keyboardHeight + 50)
                {
                    let upHeight = (keyboardHeight + 50) - diffHeight
                    topIconTopConstant.constant -= upHeight
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
//        if ((twoFAView?.textField.isFirstResponder) == true)
//        {
//            topIconTopConstant.constant = -200
//        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        topIconTopConstant.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    override var preferredStatusBarStyle:UIStatusBarStyle {
        if #available(iOS 13.0, *) {
#if Approval_PRO || Approval_DEV || Approval_STAGE
            return .lightContent
#else
            return .darkContent
#endif
        } else {
            return .default
        }
    }
    
}
// MARK: -
// MARK: 延伸
