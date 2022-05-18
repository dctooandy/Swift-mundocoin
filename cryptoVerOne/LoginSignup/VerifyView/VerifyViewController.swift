//
//  VerifyViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.

import UIKit
import Parchment
import RxSwift
import RxCocoa
import Toaster
import AVFoundation
import AVKit
class VerifyViewController: BaseViewController {
    // MARK:業務設定
    private let cancelImg = UIImage(named: "icon-close")!
    private let onClick = PublishSubject<String>()
    private let dpg = DisposeBag()
    private var inputMode: LoginMode = .emailPage
    private var timer: Timer?
    private var countTime = 60
    var loginDto : LoginPostDto?  {
        didSet {

        }
    }
    var signupDto : SignupPostDto?  {
        didSet {

        }
    }
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var sentToLabel: UILabel!
    @IBOutlet weak var userAccountLabel: UILabel!
    @IBOutlet weak var backgroundImageView: CustomImageView!
    fileprivate let idVerifiVC = IDVerificationViewController.loadNib()
    fileprivate let resetPWVC = ResetPasswordViewController.loadNib()
    var verifyInputView : InputStyleView!
//    let verifyTopLabel: UILabel = {
//        let lb = UILabel()
//        lb.textAlignment = .left
//        lb.textColor = .black
//        lb.text = "Security Verification".localized
//        lb.font = Fonts.pingFangSCRegular(16)
//        return lb
//    }()
//    let verifyTextField: UITextField = {
//        let tf = UITextField()
//        tf.borderStyle = .none
//        tf.font = Fonts.pingFangSCRegular(16)
//        tf.keyboardType = .numberPad
//        return tf
//    }()
//
//    let verifyInvalidLabel: UILabel = {
//        let lb = UILabel()
//        lb.textAlignment = .left
//        lb.font = Fonts.pingFangSCRegular(14)
//        lb.textColor = Themes.grayA3AED0
//        lb.text = "Enter the 6-digit code".localized
//        lb.isHidden = true
//        return lb
//    }()
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton()
        btn.addTarget(self, action:#selector(popVC), for:.touchUpInside)
        return btn
    }()
    let verifyResentLabel: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = .black
        lb.text = "Resend Email".localized
        lb.font = Fonts.pingFangSCRegular(14)
        return lb
    }()
    let underLineView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
//    let verifyCancelRightButton = UIButton()
    let verifyButton = CornerradiusButton()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:backBtn)
        timer?.invalidate()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        bindPwdButton()
        bindTextfield()
//        bindCancelButton()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        backgroundImageView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(Views.topOffset + 12.0)
        }
        view.backgroundColor = #colorLiteral(red: 0.9552231431, green: 0.9678531289, blue: 0.994515121, alpha: 1)
        backgroundImageView.layer.cornerRadius = 25
        backgroundImageView.layer.contents = UIImage(color: .white)?.cgImage
        backgroundImageView.layer.addShadow()
        
        let verify = InputStyleView(inputViewMode: .securityVerification)
        verifyInputView = verify
        view.addSubview(verifyInputView)
//        view.addSubview(verifyTopLabel)
//        view.addSubview(verifyTextField)
//        view.addSubview(verifyInvalidLabel)
//        view.addSubview(verifyCancelRightButton)
        view.addSubview(verifyButton)
        view.addSubview(verifyResentLabel)
        view.addSubview(underLineView)
//        verifyInputView.textField.delegate = self
//        verifyCancelRightButton.tintColor = .black
//        let textFieldMulH = height(48.0/812.0)
//        let invalidH = height(20.0/812.0)
//        let tfWidth = width(361.0/414.0) - 40

        verifyInputView.snp.makeConstraints { (make) in
            make.top.equalTo(userAccountLabel.snp.bottom).offset(80)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerX.equalTo(userAccountLabel)
            make.height.equalTo(Themes.inputViewDefaultHeight)
        }
//        verifyTextField.snp.makeConstraints { (make) in
//            make.top.equalTo(userAccountLabel.snp.bottom).offset(80)
//            make.height.equalTo(textFieldMulH)
//            make.centerX.equalTo(userAccountLabel)
//            make.width.equalTo(tfWidth)
//        }
//        verifyTopLabel.snp.makeConstraints { (make) in
//            make.bottom.equalTo(verifyTextField.snp.top).offset(-17)
//            make.left.equalTo(verifyTextField).offset(-10)
//            make.height.equalTo(17)
//        }
//        verifyInvalidLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(verifyTextField.snp.bottom).offset(5)
//            make.left.equalTo(verifyTextField)
//            make.height.equalTo(invalidH)
//        }
//        verifyTextField.setMaskView()
//        verifyTextField.setPlaceholder(inputMode.verifyPlaceholder(), with: Themes.grayA3AED0)
        //設定文字刪除
//        verifyCancelRightButton.setBackgroundImage(cancelImg, for: .normal)
//        verifyCancelRightButton.backgroundColor = .black
//        verifyCancelRightButton.layer.cornerRadius = 7
//        verifyCancelRightButton.layer.masksToBounds = true
//        verifyCancelRightButton.snp.makeConstraints { (make) in
//            make.right.equalTo(verifyTextField).offset(-5)
//            make.centerY.equalTo(verifyTextField)
//            make.width.height.equalTo(14)
//        }
        verifyButton.setTitle("Verify".localized, for: .normal)
        verifyButton.snp.makeConstraints { (make) in
            make.top.equalTo(verifyInputView.snp.bottom).offset(20)
            make.centerX.equalTo(userAccountLabel)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(50)
        }
        verifyResentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(verifyButton.snp.bottom).offset(10)
            make.centerX.equalTo(userAccountLabel)
            make.height.equalTo(view).multipliedBy(0.05)
        }
        underLineView.snp.makeConstraints { (make) in
            make.top.equalTo(verifyResentLabel.snp.bottom).offset(-10)
            make.width.centerX.equalTo(verifyResentLabel)
            make.height.equalTo(1)
        }
        if let loginDto = self.loginDto
        {
            switch loginDto.loginMode {
            case .emailPage:
                self.sentToLabel.text = "We have sent an email to".localized
                self.userAccountLabel.text = loginDto.account
            case .phonepPage:
                self.sentToLabel.text = "We have sent messages to".localized
                self.userAccountLabel.text = loginDto.account
            }
        }else if let signupDto = self.signupDto
        {
            switch signupDto.signupMode {
            case .emailPage:
                self.sentToLabel.text = "We have sent an email to".localized
                self.userAccountLabel.text = signupDto.account
            case .phonepPage:
                self.sentToLabel.text = "We have sent messages to".localized
                self.userAccountLabel.text = signupDto.account
            }
        }
    }
    func bindPwdButton()
    {
        verifyResentLabel.rx.click
            .subscribeSuccess { [weak self] in
                self?.verifyResentPressed()
            }.disposed(by: dpg)
//        verifyCancelRightButton.rx.tap
//            .subscribeSuccess { [weak self] in
//                self?.verifyCancelRightButtonPressed()
//            }.disposed(by: dpg)
        verifyButton.rx.tap
            .subscribeSuccess { [weak self] in
                self?.verifyButtonPressed()
            }.disposed(by: dpg)
    }
    func bindTextfield()
    {
        verifyInputView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            verifyInputView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
        let isValid = verifyInputView.textField.rx.text
            .map {  (str) -> Bool in
                guard  let acc = str else { return false  }
                return RegexHelper.match(pattern:. otp, input: acc)
        }
        isValid.skip(1).bind(to: verifyInputView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isValid.bind(to: verifyButton.rx.isEnabled)
            .disposed(by: dpg)
    }
//    func bindCancelButton()
//    {
//        let isEmpty = verifyTextField.rx.text.map({$0 ?? ""})
//            .map({$0.isEmpty})
//        isEmpty.bind(to: verifyCancelRightButton.rx.isHidden)
//            .disposed(by: dpg)
//    }
//    private func verifyCancelRightButtonPressed()
//    {
//        verifyTextField.text = ""
//        verifyCancelRightButton.isHidden = true
//        verifyTextField.sendActions(for: .valueChanged)
//    }
    func verifyButtonPressed()
    {
    // 登入 驗證完畢直接登入
    // 註冊 驗證完畢跳出國碼選擇
    // 忘記密碼 驗證完畢 跳出密碼輸入頁
        if let loginDto = self.loginDto
        {
            if loginDto.currentShowMode != .forgotPW
            {
                Log.v("登入驗證完畢,直接登入")
//                self.popVC(isAnimation: false)
                if let dto = self.loginDto
                {
                    popVC()
                    LoginSignupViewController.share.login(dto: dto,
                                                          checkBioList: true ,
                                                          route: .wallet,
                                                          showLoadingView: true)
                }
            }else
            {
                Log.v("忘記密碼驗證完畢,輸入密碼")
                self.navigationController?.pushViewController(resetPWVC, animated: true )
            }
        }else if let _ = self.signupDto
        {
            Log.v("註冊驗證完畢,直接登入")
            if let dto = self.signupDto
            {
                LoginSignupViewController.share.signup(dto: dto)
            }
            // 目前不用選擇國別
//            Log.v("註冊驗證完畢,國碼選擇")
//            idVerifiVC.isModalInPopover = true
//            idVerifiVC.rxSkipAction().subscribeSuccess { (_) in
//                if let dto = self.signupDto
//                {
//                    LoginSignupViewController.share.signup(dto: dto)
//                }
//            }.disposed(by: dpg)
//            idVerifiVC.rxGoAction().subscribeSuccess { [self](countryString) in
//                if let dto = self.signupDto
//                {
//                    self.dismiss(animated: true) {
//                        popVC()
//                        LoginSignupViewController.share.signup(dto: dto)
//                    }
//                }
//            }.disposed(by: dpg)
//            self.present(idVerifiVC, animated: true) {
//            }
        }
    }
    func verifyResentPressed()
    {
        Log.v("重發驗證")
        if self.timer == nil
        {
            verifyResentLabel.isUserInteractionEnabled = false
            setupTimer()
            underLineView.isHidden = true
        }
    }
    func setupTimer()
    {
        timer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
    }
    @objc func countDown()
    {
        print("count timer: \(countTime)")
        countTime -= 1
        if countTime == 0 {
//            tfRightBtn.setImageTitle(image: nil, title: rightBtnTitle())
//            tfRightBtn.isEnabled = true
            verifyResentLabel.text = "Resend Email".localized
            verifyResentLabel.textColor = .black
            underLineView.isHidden = false
            timer?.invalidate()
            timer = nil
            verifyResentLabel.isUserInteractionEnabled = true
            countTime = 60
            return
        }
        verifyResentLabel.text = "Resend in ".localized + "\(countTime) s"
        verifyResentLabel.textColor = UIColor(rgb: 0xB5B5B5)
    }
    @objc func popVC(isAnimation : Bool = true)
    {
        _ = self.navigationController?.popToRootViewController(animated: isAnimation)
    }
}
// MARK: -
// MARK: 延伸
//extension VerifyViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//       if let x = string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) {
//          return true
//       } else {
//        if string == ""
//        {
//            return true
//        }else
//        {
//            return false
//        }
//       }
//    }
//}
