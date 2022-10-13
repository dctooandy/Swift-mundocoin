//
//  ForgetPasswordViewController.swift
//  betlead
//
//  Created by Victor on 2019/6/19.
//  Copyright © 2019 Andy Chen. All rights reserved.
//

import UIKit
import RxSwift

enum ForgetPwdStep {
    case inputAccount
    case inputVerifyCode
    case inputNewPassword
    case success
    
    var title: String {
        switch self {
        case .inputAccount:
            return "STEP1 验证信息"
        case .inputVerifyCode:
            return "STEP2 身分验证"
        case .inputNewPassword:
            return "STEP3 重置密码"
        case .success:
            return "修改成功"
        }
    }
    
    var subtitle: String {
        switch self {
        case .inputAccount:
            return ""
        case .inputVerifyCode:
            return "以发送验证码至"
        default:
            return ""
        }
    }
    
    func placeHolder(tfTag: Int) -> String {
        switch self {
        case .inputAccount:
            return "请输入手机或邮箱"
        case .inputVerifyCode:
            return "请输入验证码"
        case .inputNewPassword:
            if tfTag == 1 {
                return "请输入新密码"
            }
            return "再次确认密码"
        default:
            return ""
        }
        
    }
    
    var rightBtnHidden: Bool {
        switch self {
        case .inputAccount:
            return true
        default:
            return false
        }
    }
    
    var isSecure: Bool {
        switch self {
        case .inputNewPassword:
            return true
        default:
            return false
        }
    }
    
    mutating func next() {
        switch self {
        case .inputAccount:
            self = .inputVerifyCode
        case .inputVerifyCode:
            self = .inputNewPassword
        case .inputNewPassword:
            self = .success
        case .success:
            break
        }
    }

    
    func invalidText(tfTag: Int) -> String {
        switch self {
        case .inputAccount:
            return "请输入正确手机或邮箱"
        case .inputVerifyCode:
            return "请输入正确验证码"
        case .inputNewPassword:
            if tfTag == 1 {
                return "输入8～20位英文和数字"
            }
            return "请确认密码是否相同"
        default:
            return ""
        }
        
    }
}

class ForgetPasswordViewController: BaseViewController {
    
    private let navImgView = UIImageView()
    private let dimissBtn = UIButton()
    private let titleLb = UILabel()
    private let subtitleLb = UILabel()
    
    private let inputContent = UIView()
    private let inputTf = UITextField()
    private let tfRightBtn = TfRightButton()
    private let invalidLb = UILabel()
    
    private let inputContent2 = UIView()
    private let inputTf2 = UITextField()
    private let tfRightBtn2 = TfRightButton()
    private let invalidLb2 = UILabel()
    
    private let submitBtn = ImagetTextButton(title: "下一步", image: nil)
    
    private var step: ForgetPwdStep = .inputAccount
    private let displayPwdImg = UIImage(named: "eye-solid")!.withRenderingMode(.alwaysTemplate)
    private let undisplayPwdImg =  UIImage(named: "eye-slash-solid")!.withRenderingMode(.alwaysTemplate)
    private var account = ""
    private var otpCert = ""
    private var timer: Timer?
    private var countTime = 120
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        bindTextfield()
        
    }
    
    // MARK: - UI
    func setupUI() {
        view.backgroundColor = .white
        
        navImgView.image = UIImage(named: "navigation-bg")
        view.addSubview(navImgView)
        navImgView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.11)
        }
        
        let titleLabel = UILabel(title: "忘记密码", textColor: .white, font: Fonts.pingFangTCRegular(20))
        navImgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topOffset(55/812))
            make.centerX.equalToSuperview()
            make.height.equalTo(height(20/812))
        }
        
        view.addSubview(dimissBtn)
        dimissBtn.setBackgroundImage(UIImage(named: "icon-close")!, for: .normal)
        dimissBtn.snp.makeConstraints { (make) in
            
            make.size.equalTo(titleLabel.snp.height)
            make.left.equalToSuperview().offset(leftRightOffset(26/375))
            make.centerY.equalTo(titleLabel)
        }
        
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.top.equalTo(navImgView.snp.bottom).offset(topOffset(40/812))
            make.centerX.equalToSuperview()
        }
        
        contentView.addSubview(titleLb)
        titleLb.textAlignment = .center
        titleLb.font = Fonts.pingFangSCSemibold(20)
        titleLb.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        contentView.addSubview(subtitleLb)
        subtitleLb.textAlignment = .center
        subtitleLb.font = Fonts.pingFangSCSemibold(16)
        subtitleLb.textColor = Themes.grayBase
        subtitleLb.snp.makeConstraints { (make) in
            make.top.equalTo(titleLb.snp.bottom).offset(topOffset(24/812))
            make.left.right.equalToSuperview()
        }
        
        
        inputContent.addSubview(inputTf)
        inputTf.tag = 1
        inputTf.addBottomSeparator(color: Themes.grayBase)
        inputTf.snp.makeConstraints { (make) in
            make.height.equalTo(height(48/812))
            make.top.left.right.equalToSuperview()
        }
        
        inputContent.addSubview(invalidLb)
        invalidLb.isHidden = true
        invalidLb.snp.makeConstraints { (make) in
            make.top.equalTo(inputTf.snp.bottom)
            make.left.bottom.equalToSuperview()
        }
        
        inputContent.addSubview(tfRightBtn)
        tfRightBtn.tintColor = Themes.grayLight
        tfRightBtn.snp.makeConstraints { (make) in
            make.right.height.equalToSuperview()
            make.centerY.equalTo(inputTf)
        }
        
        inputContent2.addSubview(inputTf2)
        inputTf2.tag = 2
        inputTf2.addBottomSeparator(color: Themes.grayBase)
        inputTf2.snp.makeConstraints { (make) in
            make.height.equalTo(height(48/812))
            make.top.left.right.equalToSuperview()
        }
        
        inputContent2.addSubview(invalidLb2)
        invalidLb2.isHidden = true
        invalidLb2.snp.makeConstraints { (make) in
            make.top.equalTo(inputTf2.snp.bottom)
            make.left.bottom.equalToSuperview()
        }
        
        inputContent2.addSubview(tfRightBtn2)
        tfRightBtn2.tintColor = Themes.grayLight
        inputContent2.isHidden = true
        tfRightBtn2.snp.makeConstraints { (make) in
            make.right.height.equalToSuperview()
            make.centerY.equalTo(inputTf2)
        }
        
        successView()
        
        let stackView = UIStackView(arrangedSubviews: [inputContent, inputContent2, successContentView])
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 40
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(subtitleLb.snp.bottom).offset(topOffset(48/812))
            make.left.right.equalToSuperview()
        }
        contentView.addSubview(submitBtn)
        submitBtn.setBackgroundColor(Themes.primaryBase, isEnable: true)
        submitBtn.setBackgroundColor(Themes.grayBase, isEnable: false)
        submitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(stackView.snp.bottom).offset(topOffset(48/812))
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(height(48/812))
        }
        
        resetUI()
    }
    
    private let successContentView = UIView()
    
    func successView() {
        successContentView.isHidden = true
        let img = UIImage(named: "check-circle")
        let successImv = UIImageView(image: img)
        successContentView.addSubview(successImv)
        successImv.contentMode = .scaleAspectFit
        successImv.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(sizeFrom(scale: 96/375))
        }
        
        let bottomLabel = UILabel(title: "请重新使用新的密码登录", textColor: Themes.grayBase, font: Fonts.PlusJakartaSansMedium(16))
        bottomLabel.textAlignment = .center
        successContentView.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { (make) in
            make.top.equalTo(successImv.snp.bottom).offset(topOffset(45/812))
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    func resetUI() {
        
        titleLb.text = step.title
        subtitleLb.text = step.subtitle
        
        if step == .success {
            submitBtn.isEnabled = true
            inputContent.isHidden = true
            inputContent2.isHidden = true
            successContentView.isHidden = false
            submitBtn.setTitle(text: "确认")
            return
        }
        if step == .inputVerifyCode {
            subtitleLb.text = subtitleLb.text! + account
            setupTimer()
            tfRightBtn.isEnabled = false
        }
        
        if step == .inputNewPassword {
            inputContent2.isHidden = false
            tfRightBtn.isEnabled = true
            timer?.invalidate()
        }
        
        inputTf.text = ""
        inputTf.placeholder = step.placeHolder(tfTag: inputTf.tag)
        inputTf.isSecureTextEntry = step.isSecure
        invalidLb.text = step.invalidText(tfTag: inputTf.tag)
        invalidLb.textColor = .red
        tfRightBtn.setImageTitle(image: rightBtnImage(), title: rightBtnTitle())
        tfRightBtn.isHidden = step.rightBtnHidden
        
        inputTf2.text = ""
        inputTf2.placeholder = step.placeHolder(tfTag: inputTf2.tag)
        inputTf2.isSecureTextEntry = step.isSecure
        invalidLb2.text = step.invalidText(tfTag: inputTf2.tag)
        invalidLb2.textColor = .red
        tfRightBtn2.setImage(displayPwdImg, for: .normal)
        tfRightBtn2.isHidden = step.rightBtnHidden
       
        submitBtn.isEnabled = false
    }
    
    func rightBtnImage() -> UIImage? {
        switch step {
        case .inputNewPassword:
            return displayPwdImg
        default:
            return nil
        }
    }
    
    func rightBtnTitle() -> String? {
        switch step {
        case .inputVerifyCode:
            return "发送验证码"
        default:
            return nil
        }
    }
    
    // MARK: - binding
    func bind() {
        
        dimissBtn.rx.tap
            .subscribeSuccess { [weak self] in
                DispatchQueue.main.async {
                    self?.timer?.invalidate()
                    self?.timer = nil
                    self?.dismiss(animated: true, completion: nil)
                }
            }.disposed(by: disposeBag)
        
        tfRightBtn.rx.tap
            .subscribeSuccess { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tfRightBtnPressed(strongSelf.tfRightBtn)
            }.disposed(by: disposeBag)
        
        tfRightBtn2.rx.tap
            .subscribeSuccess { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tfRightBtnPressed(strongSelf.tfRightBtn2)
            }.disposed(by: disposeBag)
        
        submitBtn.rx.tap
            .subscribeSuccess { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.submitBtnPressed()
            }.disposed(by: disposeBag)
        
    }
    
    func bindTextfield() {
        
        let isInputTf = inputTf.rx.text.map({$0 ?? ""})
            .map { [weak self] (str) -> (Bool,String) in
                
                guard let strongSelf = self else { return (false, "")}
                
                switch strongSelf.step {
                    
                case .inputAccount:
                    
                    let isMail = RegexHelper.match(pattern: .mail, input: str)
                    let isPhone = RegexHelper.match(pattern: .phone, input: str)
                    let set = isMail || isPhone
                    return (set, str)
                    
                case .inputVerifyCode:
                    
                    return (RegexHelper.match(pattern: .otp, input: str), str)
                case .inputNewPassword:
                    return (RegexHelper.match(pattern: .password, input: str), str)
                default:
                    return (true, str)
                }
                
                
        }
        
        let isInputTf2 = inputTf2.rx.text.map({$0 ?? ""})
            .map { [weak self] (str) -> (Bool,String) in
                guard let strongSelf = self else { return (false, "")}
                if  strongSelf.step == .inputNewPassword {
                    let isPwd = RegexHelper.match(pattern: .password, input: str)
                    let isEqual = str == strongSelf.inputTf.text!
                    return (isPwd && isEqual, str)
                }
                return (true,str)
        }
        
        isInputTf
            .subscribeSuccess { [weak self] (isValid,str) in
                guard let strongSelf = self else { return }
                if !isValid && str.isEmpty {
                    strongSelf.invalidLb.isHidden = true
                    return
                }
                strongSelf.invalidLb.isHidden = isValid
            }.disposed(by: disposeBag)
        
        isInputTf2
            .subscribeSuccess { [weak self] (isValid,str) in
                guard let strongSelf = self else { return }
                if !isValid && str.isEmpty {
                    strongSelf.invalidLb2.isHidden = true
                    return
                }
                strongSelf.invalidLb2.isHidden = isValid
                
            }.disposed(by: disposeBag)
        
        Observable.combineLatest([isInputTf,isInputTf2])
            .map { [weak self] (isvalid) -> Bool in
                guard let strongSelf = self else { return false }
                switch strongSelf.step {
                case .inputAccount:
                    return isvalid[0].0
                case .inputVerifyCode:
                    return isvalid[0].0
                case .inputNewPassword:
                    let isValid = isvalid[0].0 && isvalid[1].0
                    return isValid
                case .success:
                    return true
                }
            }
            .bind(to: submitBtn.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func sendVerifyCode() {
        getOtp()
    }
   
    @objc func tfRightBtnPressed(_ sender: TfRightButton) {
        
        switch step {
        case .inputVerifyCode:
            self.sendVerifyCode()
        
        case .inputNewPassword:
            if sender == tfRightBtn {
                inputTf.isSecureTextEntry = !inputTf.isSecureTextEntry
                sender.setImage(inputTf.isSecureTextEntry ? displayPwdImg : undisplayPwdImg)
            } else {
                inputTf2.isSecureTextEntry = !inputTf2.isSecureTextEntry
                sender.setImage(inputTf2.isSecureTextEntry ? displayPwdImg : undisplayPwdImg)
            }
            
        default:
            break
        }
    }
    
    func submitBtnPressed() {
        
        switch step {
        case .inputAccount:
            print("post account api")
            account = inputTf.text!
            getOtp()
        case .inputVerifyCode:
            print("post verify code api")
            postOtp()
        case .inputNewPassword:
            print("post new pwd api")
            postNewPwd()
        case .success:
            print("success")
            timer?.invalidate()
            timer = nil
            self.dismiss(animated: true, completion: nil)
        }
    }
   
    func setupTimer() {
        timer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
    }
   
    @objc func countDown(){
        print("count timer: \(countTime)")
        countTime -= 1
        if countTime == 0 {
            tfRightBtn.setImageTitle(image: nil, title: rightBtnTitle())
            tfRightBtn.isEnabled = true
            timer?.invalidate()
            return
        }
        tfRightBtn.setImageTitle(image: nil, title: "重发送(\(countTime))")
    }
    
    // MARK: - API
    func postNewPwd() {
//        LoadingViewController.show()
//        let p1 = inputTf.text!
//        let p2 = inputTf2.text!
//        Beans.memberServer
//            .postForgetPassChange(acc: account, otpCert: otpCert, p1: p1, p2: p2)
//            .subscribeSuccess { [weak self] (dto) in
//                guard let strongSelf = self else { return }
//                LoadingViewController.dismiss()
//                strongSelf.nextStep()
//            }.disposed(by: disposeBag)
    }
    
    func postOtp() {
//        LoadingViewController.show()
//        let otp = inputTf.text!
//        Beans.memberServer
//            .postForgetPassCert(acc: account, otp: otp)
//            .subscribeSuccess { [weak self] (dto) in
//                LoadingViewController.dismiss()
//                guard let strongSelf = self else { return }
//                guard let otpCert = dto?.otpCert else { return }
//                strongSelf.otpCert = otpCert
//                strongSelf.nextStep()
//        }.disposed(by: disposeBag)
    }
    
    func getOtp() {
//        LoadingViewController.show()
//        Beans.memberServer
//            .getForgetPassOtp(acc: account)
//            .subscribeSuccess { [weak self](otp) in
//                LoadingViewController.dismiss()
//                guard let strongSelf = self else { return }
//                strongSelf.nextStep()
//                #if DEBUG
//                strongSelf.inputTf.text = otp?.otp ?? ""
//                strongSelf.inputTf.sendActions(for: .valueChanged)
//                #endif
//            }.disposed(by: disposeBag)
    }
    
    func nextStep() {
        step.next()
        resetUI()
    }
}
