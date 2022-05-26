//
//  TwoFactorAuthViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/12.
//

import Foundation
import RxCocoa
import RxSwift

class TwoFactorAuthViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    static let share: TwoFactorAuthViewController = TwoFactorAuthViewController.loadNib()
    var qrCodeString : String = ""
    @IBOutlet weak var topIconTopConstant: NSLayoutConstraint!
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet var twoFAInputView: UIView!
    @IBOutlet var copyInputView: UIView!
    @IBOutlet weak var bindButton: CornerradiusButton!
    @IBOutlet weak var downloadButton: CornerradiusButton!
    var copyView : InputStyleView!
    var twoFAView : InputStyleView!
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Google Authentication".localized
        view.backgroundColor = #colorLiteral(red: 0.9552231431, green: 0.9678531289, blue: 0.994515121, alpha: 1)
        setupUI()
        bindButtonAction()
        bindTextfield()
        bindCancelButton()
        setScrollView()
        setNotification()
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
    @objc func touch() {
        self.view.endEditing(true)
        copyView.tfMaskView.changeBorderWith(isChoose:false)
        twoFAView.tfMaskView.changeBorderWith(isChoose:false)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        copyView.tfMaskView.changeBorderWith(isChoose:false)
        twoFAView.tfMaskView.changeBorderWith(isChoose:false)
    }
    // MARK: -
    // MARK:業務方法
    func setupUI()
    {
        qrCodeString = "THFfxoxMtMJGnjar...cXUNbHzry3"
        let image = generateQRCode(from: qrCodeString)
        codeImageView.image = image
        copyView = InputStyleView(inputViewMode: .copy)
        copyView.textField.text = qrCodeString
        twoFAView = InputStyleView(inputViewMode: .twoFAVerify)
        copyInputView.addSubview(copyView)
        twoFAInputView.addSubview(twoFAView)
        copyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        twoFAView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        bindButton.setTitle("Bind".localized, for: .normal)
        bindButton.titleLabel?.font = Fonts.pingFangTCMedium(16)
        bindButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        bindButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        bindButton.snp.makeConstraints { (make) in
            make.top.equalTo(twoFAInputView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.065)
        }
        downloadButton.setTitle("Download APP".localized, for: .normal)
        downloadButton.setTitleColor(UIColor(rgb: 0x656565), for: .normal)
        downloadButton.titleLabel?.font = Fonts.pingFangTCMedium(16)
        downloadButton.setBackgroundImage(UIImage(color: .white) , for: .disabled)
        downloadButton.setBackgroundImage(UIImage(color: #colorLiteral(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)) , for: .normal)
        downloadButton.layer.borderColor = UIColor(rgb: 0x656565).cgColor
        downloadButton.layer.borderWidth = 1
        downloadButton.snp.makeConstraints { (make) in
            make.top.equalTo(bindButton.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.065)
        }
    }
    func bindButtonAction()
    {
        bindButton.rx.tap.subscribeSuccess { [self](_) in
            requestForBindAuth()
        }.disposed(by: dpg)
        downloadButton.rx.tap.subscribeSuccess { (_) in
            if let url = URL(string: "itms-apps://apple.com/app/id388497605") {
                UIApplication.shared.open(url)
            }
        }.disposed(by: dpg)
    }
    func bindTextfield()
    {
        let isTwoFACodeValid = twoFAView.textField.rx.text
//        let isAccountValid = accountTextField.rx.text
            .map { [weak self] (str) -> Bool in
                guard let strongSelf = self, let acc = str else { return false  }
                return RegexHelper.match(pattern: .otp, input: acc)
        }
        isTwoFACodeValid.skip(1).bind(to: twoFAView.invalidLabel.rx.isHidden).disposed(by: dpg)
        isTwoFACodeValid.bind(to: bindButton.rx.isEnabled)
            .disposed(by: dpg)
        copyView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            copyView.tfMaskView.changeBorderWith(isChoose:isChoose)
            twoFAView.tfMaskView.changeBorderWith(isChoose:false)
        }.disposed(by: dpg)
        twoFAView.rxChooseClick().subscribeSuccess { [self](isChoose) in
            copyView.tfMaskView.changeBorderWith(isChoose:false)
            twoFAView.tfMaskView.changeBorderWith(isChoose:isChoose)
        }.disposed(by: dpg)
    }
    func bindCancelButton()
    {
        let _ =  twoFAView.textField.rx.text.map({$0 ?? ""})
            .map({$0.isEmpty})
            .bind(to: twoFAView.cancelRightButton.rx.isHidden)
            .disposed(by: dpg)
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
        let finishVC = TFFinishReViewController.loadNib()
        finishVC.viewMode = .back
        self.navigationController?.pushViewController(finishVC, animated: true)
    }
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    @objc func keyboardWillShow(notification: NSNotification) {

        if ((twoFAView?.textField.isFirstResponder) == true)
        {
            topIconTopConstant.constant = -200
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        topIconTopConstant.constant = 0
    }
    @objc override func popVC() {
        let securityVC = SecurityViewController.share
        _ = self.navigationController?.popToViewController(securityVC, animated:true )
    }
}
// MARK: -
// MARK: 延伸
