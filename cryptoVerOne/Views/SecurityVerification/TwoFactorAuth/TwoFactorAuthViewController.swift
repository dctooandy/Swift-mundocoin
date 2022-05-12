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
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet var twoFAInputView: UIView!
    @IBOutlet var copyInputView: UIView!
    
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Google Authentication".localized
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
        qrCodeString = "THFfxoxMtMJGnjar...cXUNbHzry3"
        let image = generateQRCode(from: qrCodeString)
        codeImageView.image = image
        let copyView = InputStyleView(inputMode: .copy)
        copyView.textField.text = qrCodeString
        let twoFAView = InputStyleView(inputMode: .twoFA)
        copyInputView.addSubview(copyView)
        twoFAInputView.addSubview(twoFAView)
        copyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        twoFAView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
//        view.addSubview(copyInputView)
//        view.addSubview(twoFAInputView)
//        copyInputView.snp.remakeConstraints { (make) in
//            make.top.equalTo(codeImageView.snp.bottom).offset(height(80/812))
//            make.leading.equalToSuperview().offset(32)
//            make.trailing.equalToSuperview().offset(-32)
//            make.height.equalTo(height(90/812))
//        }
//        twoFAInputView.snp.remakeConstraints { (make) in
//            make.top.equalTo(twoFAInputView.snp.bottom).offset(height(20/812))
//            make.leading.equalToSuperview().offset(32)
//            make.trailing.equalToSuperview().offset(-32)
//            make.height.equalTo(height(90/812))
//        }
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
    @objc override func popVC() {
        let securityVC = SecurityViewController.share
        _ = self.navigationController?.popToViewController(securityVC, animated:true )
    }
}
// MARK: -
// MARK: 延伸
