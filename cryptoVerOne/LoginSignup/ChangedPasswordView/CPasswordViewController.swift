//
//  CPasswordViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/6.
//

import Foundation
import RxCocoa
import RxSwift

class CPasswordViewController: BaseViewController {
    // MARK:業務設定
    private let onClick = PublishSubject<Any>()
    private let dpg = DisposeBag()
    // MARK: -
    // MARK:UI 設定
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    private lazy var backBtn:TopBackButton = {
        let btn = TopBackButton()
        btn.addTarget(self, action:#selector(returnToLoginVC), for:.touchUpInside)
        return btn
    }()
    let returnButton = CornerradiusButton()
    // MARK: -
    // MARK:Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verification"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:backBtn)
        setupUI()
        bindButton()
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
        topLabel.text = "You’ve already change password".localized
        view.addSubview(returnButton)
        returnButton.titleLabel?.font = Fonts.PlusJakartaSansRegular(16)
        returnButton.setTitle("Return to log in".localized, for: .normal)
        returnButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0xD9D9D9)) , for: .disabled)
        returnButton.setBackgroundImage(UIImage(color: UIColor(rgb: 0x656565)) , for: .normal)
        returnButton.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(50)
            make.centerX.equalTo(topLabel)
            make.width.equalToSuperview().multipliedBy(311.0/415.0)
            make.height.equalTo(50)
        }
    }
    func bindButton()
    {
        returnButton.rx.tap
            .subscribeSuccess { [self] in
                returnButtonPressed()
            }.disposed(by: dpg)
    }
    func returnButtonPressed()
    {
        returnToLoginVC()
    }
    func backgroundImageViewHidden()
    {
        backgroundImageView.isHidden = true
    }
    @objc func returnToLoginVC()
    {
        DeepLinkManager.share.handleDeeplink(navigation: .login)
    }
}
// MARK: -
// MARK: 延伸
